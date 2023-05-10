#!/usr/bin/sh

_info() {
  local BLUE='\e[1;34m'
  local YELLOW='\e[1;33m'
  local NC='\e[0m'
  local MESSAGE="$*"
  printf "${BLUE}# $(hostname):${YELLOW} ${MESSAGE}${NC}\n"
}

SEARCH_DOMAIN=$(echo "${REALM}" | tr [:upper:] [:lower:])

_info "nslookup \"$(hostname).${SEARCH_DOMAIN}\""
nslookup "$(hostname).${SEARCH_DOMAIN}"

_info 'ldapsearch -xLLL -s base namingContexts'
ldapsearch -xLLL -s base namingContexts

SEARCH_BASE=$(echo dc=${SEARCH_DOMAIN} | sed "s/\./,dc=/g")

_info "ldapsearch -xLLL -b \"cn=administrator,cn=users,${SEARCH_BASE}\" -D \"cn=administrator,cn=users,${SEARCH_BASE}\""
ldapsearch -xLLL -b "cn=administrator,cn=users,${SEARCH_BASE}" -D "cn=administrator,cn=users,${SEARCH_BASE}" -w "${ADMIN_PASSWD}"

noofusers=0
if [ ! -z "${USER_COUNT}" ]; then
  noofusers=$((USER_COUNT))
fi

counter=$(( 0 ))
while [ "$counter" -le ${noofusers} ]; do
  samba-tool user create johndoe${counter} --given-name John${counter} --surname Doe --random-password
  samba-tool user setpassword johndoe0 --newpassword=Passw0rd
  counter=$((counter + 1))
done


echo ""
