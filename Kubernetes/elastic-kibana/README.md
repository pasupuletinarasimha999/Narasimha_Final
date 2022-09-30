1) Label all Nodes using below command
kubectl label nodes ip-172-20-37-189.ec2.internal beta.kubernetes.io/fluentd-ds-ready=true
kubectl label nodes ip-172-20-68-245.ec2.internal beta.kubernetes.io/fluentd-ds-ready=true

2) Change the zone of EBS to create in storage.yaml

3) Apply all yamls