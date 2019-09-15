FROM alpine
RUN apk update && \
  apk add postfix postfix-ldap supervisor rsyslog
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
CMD ["/docker-entrypoint.sh"]
