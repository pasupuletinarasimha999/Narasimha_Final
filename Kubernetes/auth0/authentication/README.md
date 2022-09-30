# kube authentication resources
kops edit cluster --name=narasimha.k8s.local --state=s3://kops-bucket-narasimha

Add oidc setup to kops cluster:

```
spec:
  kubeAPIServer:
    oidcIssuerURL: https://account.eu.auth0.com/
    oidcClientID: clientid
    oidcUsernameClaim: sub
```

kops update cluster --name=narasimha.k8s.local --state=s3://kops-bucket-narasimha --yes

Create UI:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.6.3.yaml
```

cd /home/ec2-user/advanced-kubernetes-course/kubernetes-auth-server

pip3 install -r requirements-cli.txt

AUTH0_CLIENT_ID=gQQ39y8Ho7ZCcrmRPcO6zvpG8SLhwGDc AUTH0_DOMAIN=dev-8cwc4puz.us.auth0.com APP_HOST=authserver.narasimhakubernetes.xyz ./cli-auth.py

alias kubectl="kubectl --token=\$(AUTH0_CLIENT_ID=gQQ39y8Ho7ZCcrmRPcO6zvpG8SLhwGDc AUTH0_DOMAIN=dev-8cwc4puz.us.auth0.com APP_HOST=authserver.narasimhakubernetes.xyz /home/user2/advanced-kubernetes-course/kubernetes-auth-server/cli-auth.py)"

alias kubectl="kubectl --token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ijh2T3FnMXJQcUVXVG9jLWs5RjlxayJ9.eyJodHRwOi8vYXV0aHNlcnZlci5uYXJhc2ltaGFrdWJlcm5ldGVzLnh5ei9jbGFpbXMvZ3JvdXBzIjpbImRldmVsb3BlcnMiXSwibmlja25hbWUiOiJhZG1pbiIsIm5hbWUiOiJhZG1pbkBuYXJhc2ltaGFrdWJlcm5ldGVzLmNvbSIsInBpY3R1cmUiOiJodHRwczovL3MuZ3JhdmF0YXIuY29tL2F2YXRhci8yNzIzNjBhNzczNzJjYjhkN2RhODk5NjU1MmJlYjljOD9zPTQ4MCZyPXBnJmQ9aHR0cHMlM0ElMkYlMkZjZG4uYXV0aDAuY29tJTJGYXZhdGFycyUyRmFkLnBuZyIsInVwZGF0ZWRfYXQiOiIyMDIyLTA2LTI4VDAyOjE2OjQyLjc2NVoiLCJlbWFpbCI6ImFkbWluQG5hcmFzaW1oYWt1YmVybmV0ZXMuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vZGV2LThjd2M0cHV6LnVzLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw2MmI2YmU4YjRkZDcyMmUwNDJmYTgwZmQiLCJhdWQiOiJnUVEzOXk4SG83WkNjcm1SUGNPNnp2cEc4U0xod0dEYyIsImlhdCI6MTY1NjM4MjYwNCwiZXhwIjoxNjU2NDE4NjA0fQ.fP0BXxV57CHlL1KJbVfLzJiJInaaJUibSigkZyN5l1zPkZbOynzfWpdTE5gFZwqKqggiAvSTVAsHkvMhSlTk9tJ5a2IwGK4F2FD_i3H7ieO3qVKRGN8iCH2se2OwMcW7g6XvLkZI7UMBbRcTypAfwtnsQbA6zeR0By_nK7KIQuMk8RaEKK19-UL--wk5_aejjJbP8cUa86K-XwhFv6R9vc0cZLy1ukpK3mENqUJQXrY6cXojjcGLlCjVtjLaaORls7k8Za2JtG7lBfnj5EslKNIkAYsmXQ1EXi9gK2d_SIGWXxqaVuBdZS0Ff7sJqZcZDCPUPaIKvU6_2ZV6XigUig"