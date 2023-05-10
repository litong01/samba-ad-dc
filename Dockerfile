FROM alpine:3.17.3

RUN apk add --no-cache samba-dc supervisor openldap-clients \
    # Remove default config data, if any
    && rm -rf /etc/samba/smb.conf \
    && rm -rf /var/lib/samba \
    && rm -rf /var/log/samba \
    && ln -s /samba/etc /etc/samba \
    && ln -s /samba/lib /var/lib/samba \
    && ln -s /samba/log /var/log/samba

# Expose ports
EXPOSE 37/udp 53 88 135/tcp 139 389 

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["samba"]
