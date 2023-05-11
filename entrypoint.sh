#!/bin/sh

set -e

COMMAND=ash

# Add $COMMAND if needed
if [ "${1:0:1}" = '-' ]; then
	set -- $COMMAND "$@"
fi

BLUE='\e[1;34m'
NC='\e[0m'

# Configure the AD DC
if [ ! -f /samba/etc/smb.conf ]; then
    mkdir -p /samba/etc /samba/lib /samba/log
    echo "${DOMAIN} - Begin Domain Provisioning"
    samba-tool domain provision --domain="${DOMAIN}" \
        --adminpass="${ADMIN_PASSWD}" \
        --server-role=dc \
        --realm="${REALM}" \
        --option="dns forwarder=8.8.8.8" \
        --option="bind interfaces only = no" \
        --option="log level = 1 auth_audit:3"
    echo ""
    echo -e "Domain: ${BLUE}${DOMAIN}${NC} - Domain Provisioned Successfully"
fi

# Wait for network interface
until ip a | grep 'scope global' >/dev/null 2>&1; do
  echo 'Waiting for network interface..'
  sleep 1
done

SERVER_IP=$(ip a | grep 'scope global' | head -n1 | awk '{print $2}' | awk -F / '{print $1}')
SEARCH_DOMAIN=$(echo "${REALM}" | tr [:upper:] [:lower:])
SEARCH_BASE=$(echo dc=${SEARCH_DOMAIN} | sed "s/\./,dc=/g")

# Change resolv.conf based on current network info
if ! grep -q "${SEARCH_DOMAIN}" /etc/resolv.conf; then
  echo -e "search ${SEARCH_DOMAIN}\nnameserver ${SERVER_IP}" >/etc/resolv.conf
fi

# Change /etc/hosts file with current hostname and domain
if ! grep -q "${SEARCH_DOMAIN}" /etc/hosts; then
  echo -e "${SERVER_IP} $(hostname).${SEARCH_DOMAIN} $(hostname)" >>/etc/hosts
fi

# Change krb5 file with compiled files
if ! grep -q "${SEARCH_DOMAIN}" /usr/share/samba/setup/krb5.conf; then
  # The krb5.conf location is different from mirror and compiled from source files
  cat /samba/lib/private/krb5.conf > /usr/share/samba/setup/krb5.conf
fi

# Allow insecure LDAP requests
if ! grep -q "ldap server require strong auth" /etc/samba/smb.conf; then
  sed -i 's/\[global\]/[global]\n\tldap server require strong auth = No/' /etc/samba/smb.conf
fi

if [ ! -z "${USER_COUNT}" ]; then
  echo ""
  noofusers=$((USER_COUNT))
  counter=$(( 0 ))
  while [ $counter -lt ${noofusers} ]; do
    samba-tool user create johndoe${counter} --given-name John${counter} --surname Doe${counter} \
      --mail-address johndoe${counter}@test.example.com --random-password
    samba-tool user setpassword johndoe${counter} --newpassword=${ADMIN_PASSWD} >/dev/null 2>&1
    counter=$((counter + 1))
  done
  echo -e "All user password: ${BLUE}${ADMIN_PASSWD}${NC}"
fi

if [ "$1" = 'samba' ]; then
    # We will also create a user which can be used for binding user
    samba-tool user create admin --given-name Admin --mail-address admin@test.example.com --random-password
    samba-tool user setpassword admin --newpassword=${ADMIN_PASSWD} >/dev/null 2>&1
    samba-tool group addmembers "Domain Admins" admin >/dev/null 2>&1
    echo -e "bindDN: ${BLUE}cn=Admin,cn=users,${SEARCH_BASE}${NC}"
    echo -e "email: ${BLUE}admin@test.example.com${NC}"
    echo -e "userPrincipalName: ${BLUE}admin@${SEARCH_DOMAIN}${NC}"
    echo ""
    exec /usr/sbin/samba -i  >/dev/null 2>&1
fi

# Assume that user wants to run their own process,
# for example a `bash` shell to explore this image
exec "$@"