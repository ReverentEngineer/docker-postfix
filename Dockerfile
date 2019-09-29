FROM alpine:3.10
ENV MAIL_HOSTNAME mail.example.org
ENV DOVECOT_SASL_ADDR dovecot:12345
ENV DOVECOT_LMTP_ADDR dovecot:24
ENV LDAP_HOST openldap
ENV LDAP_BASE dc=example,dc=org
ENV LDAP_DN cn=readonly,dc=example,dc=org
ENV LDAP_DNPASS readonly
RUN apk update && apk add postfix postfix-ldap && mkdir /var/mail
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
