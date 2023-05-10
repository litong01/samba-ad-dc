# samba-ad-dc

[![gh-actions](https://github.com/tongli01/samba-ad-dc/actions/workflows/ubuntu-image.yml/badge.svg)](https://github.com/litong01/samba-ad-dc/actions/workflows/ubuntu-image.yml)

Samba Active Directory Domain Controller Docker Image

Provision a new domain and create 5 users:
```
docker run -d --privileged --name samba-ad  \
  -e REALM='corp.example.net' \
  -e DOMAIN='EXAMPLE' \
  -e ADMIN_PASSWD='Passw0rd' \
  -e USER_COUNT=4  'tli551/samba-ad:v0.1.0'
```

Show logs (Ctrl+c to exit):
```
docker logs samba-ad -f
```
