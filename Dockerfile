FROM alpine
RUN apk update && \
  apk add postfix postfix-ldap supervisor rsyslog
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
ADD supervisord.conf /etc/supervisord.conf
CMD ["/docker-entrypoint.sh"]
