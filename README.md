# samba-ad-dc

[![gh-actions](https://github.com/tongli01/samba-ad-dc/actions/workflows/multi-arch-image.yml/badge.svg)](https://github.com/litong01/samba-ad-dc/actions/workflows/multi-arch-image.yml)

Samba Active Directory Domain Controller Docker Image

Provision a new domain and create 5 users:
```
docker run -d --privileged --name samba-ad  \
  -e REALM='corp.example.net' \
  -e DOMAIN='EXAMPLE' \
  -e ADMIN_PASSWD='Passw0rd' \
  -e USER_COUNT=5  'tli551/samba-ad:v0.1.0'
```

Show logs (Ctrl+c to exit):
```
docker logs samba-ad -f
```

Run tests
```
docker exec samba-ad ad-test
```

Add more users
```
docker exec samba-ad ad-users 10 5
```

Deploy onto k8s as a service
```
kubectl apply -f https://raw.githubusercontent.com/litong01/samba-ad-dc/master/k8s/ad.yaml
```
