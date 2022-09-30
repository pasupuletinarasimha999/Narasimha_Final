# I realize I could use terragrunt here to DRY the creation of the VPC

 # 1. create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    "Name" = "Production"
  }
}
# 2. Create Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}
# 3. Create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
 tags = {
    Name = "prod"
  }
}
resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "main-private-1"
  }
}
# 4. Create a Subnet

 resource "aws_subnet" "publicsubnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}a"

  tags = {
    Name = "publicsubnet-1"
  }
 }
  resource "aws_subnet" "publicsubnet-2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}b"

  tags = {
    Name = "publicsubnet-2"
  }
 }
  resource "aws_subnet" "publicsubnet-3" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.AWS_REGION}c"

  tags = {
    Name = "publicsubnet-3"
  }
 }
  resource "aws_subnet" "privatesubnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "${var.AWS_REGION}a"

  tags = {
    Name = "privatesubnet-1"
  }
 }
  resource "aws_subnet" "privatesubnet-2" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "${var.AWS_REGION}b"

  tags = {
    Name = "privatesubnet-2"
  }
 }
  resource "aws_subnet" "privatesubnet-3" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "${var.AWS_REGION}c"

  tags = {
    Name = "privatesubnet-3"
  }
 }
# 5. Associate Subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsubnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.publicsubnet-2.id
  route_table_id = aws_route_table.prod-route-table.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.publicsubnet-3.id
  route_table_id = aws_route_table.prod-route-table.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.privatesubnet-1.id
  route_table_id = aws_route_table.main-private.id
}
resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.privatesubnet-2.id
  route_table_id = aws_route_table.main-private.id
}
resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.privatesubnet-3.id
  route_table_id = aws_route_table.main-private.id
}

# 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicsubnet-1.id
  depends_on    = [aws_internet_gateway.gw]
}

# 8. Assign an Elastic IP to the network interface crteated in step 7

resource "aws_eip" "nat" {
  vpc                       = true
}

#9 I cheated for now and loaded ubuntu

resource "aws_instance" "web-server-instance" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"
  availability_zone = "${var.AWS_REGION}a"
   # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id
  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  key_name = aws_key_pair.mykey.key_name

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id

  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo sed -i -e 's/\r$//' /tmp/script.sh",  # Remove the spurious CR characters.
      "sudo /tmp/script.sh",
    ]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file(var.PATH_TO_PRIVATE_KEY)
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io -y
            sudo service docker start
            sudo docker pull charlierlee/ethbalance
            echo "${file("${path.module}/docker-compose.tpl")}" > /opt/docker-compose.yml
            sudo docker-compose -f /opt/docker-compose.yml up -d
            EOF

 tags = {
     name = "web-server"
 }
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "${var.AWS_REGION}a"
  size              = 20
  type              = "gp2"
  tags = {
    Name = "extra volume data"
  }
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.ebs-volume-1.id
  instance_id = aws_instance.web-server-instance.id
}

output "instance" {
  value = aws_instance.example.public_ip
}

output "rds" {
  value = aws_db_instance.mariadb.endpoint
}

