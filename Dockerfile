FROM alpine
ENV MAIL_HOSTNAME mail.example.org
ENV DOVECOT_SASL_ADDR dovecot:12345
ENV DOVECOT_LMTP_ADDR dovecot:24
ENV LDAP_HOST openldap
ENV LDAP_BASE dc=example,dc=org
RUN apk update && apk add postfix postfix-ldap
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
