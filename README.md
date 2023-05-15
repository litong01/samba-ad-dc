# samba-ad-dc

[![gh-actions](https://github.com/tongli01/samba-ad-dc/actions/workflows/multi-arch-image.yml/badge.svg)](https://github.com/litong01/samba-ad-dc/actions/workflows/multi-arch-image.yml)

Samba Active Directory Domain Controller container image

Provision a new domain and create 5 users:
```
docker run -d --privileged --name samba-ad  \
  -e REALM='example.org' \
  -e DOMAIN='EXAMPLE' \
  -e ADMIN_PASSWD='Passw0rd' \
  -e USER_COUNT=5  'tli551/samba-ad:v0.1.0'
```

Show logs (Ctrl+c to exit):
```
docker logs samba-ad -f
```

Run tests and list current users
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

Notes: Generated users will have the following characters:
``` 
sAMAccountName(logon name):  johndoe<num>    ex. johndoe1, johndoe2
user given name: John<num>    ex. John1, John2
user sur name: Doe<num>    ex. Doe1, Doe2
user email: johndoe<num>@mail.<REALM>   ex. johndoe1@mail.example.org
user PrincipalName: johndoe<num>@<REALM>   ex. johndoe1@example.org
```

You may choose to customize the realm by specify different REALM when create the docker container
or Kubernetes pod. You can may further customize users by following how users get created in script
/usr/sbin/ad-users. With this container image, you can create any realm and any number of users as
you like.
