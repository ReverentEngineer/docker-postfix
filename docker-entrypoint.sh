#!/bin/sh

if [[ -z $MAIL_HOSTNAME ]]; then
  echo "No MAIL_HOSTNAME provided"
  exit 1
fi

if [[ -z $MAIL_DOMAIN ]]; then
  echo "No MAIL_DOMAIN provided."
  exit
fi

postconf -e "maillog_file = /dev/stdout"
postconf -e "mydomain = $MAIL_DOMAIN"
postconf -e "myhostname = $MAIL_HOSTNAME"  
postconf -e "mydestination = $MAIL_HOSTNAME, localhost.\$mydomain, localhost"
postconf -e 'append_at_myorigin = yes'

postconf -e "mua_client_restrictions = permit_mynetworks, reject_unauth_destination, reject_unknown_client_hostname, reject_rbl_client zen.spamhaus.org, reject_rbl_client bl.spamcop.net, reject_rbl_client cbl.abuseat.org, permit"
postconf -e 'smtpd_client_restrictions = $mua_client_restrictions'

postconf -e "recipient_delimiter = +"

if [[ ! -z $RSPAMD_ADDR ]]; then
  postconf -e "smtpd_milters = inet:${RSPAMD_ADDR}"
  postconf -e "non_smtpd_milters = inet:${RSPAMD_ADDR}"
  postconf -e "milter_mail_macros = i {mail_addr} {client_addr} {client_name} {auth_authen}"
  postconf -e "milter_protocol = 6"
  postconf -e "milter_rcpt_macros = i {rcpt_addr}"
  postconf -e "milter_default_action = accept"
fi

if [[ ! -z $DOVECOT_SASL_ADDR ]]; then 
  postconf -e "smtpd_sasl_auth_enable=yes"
  postconf -e "smtpd_sasl_security_options = noanonymous"
  postconf -e "smtpd_sasl_path = inet:$DOVECOT_SASL_ADDR"
  postconf -e "smtpd_sasl_type = dovecot"
else 
  echo "No DOVECOT_SASL_ADDR provided."
  exit 2
fi

if [[ ! -z $DOVECOT_LMTP_ADDR ]]; then
  postconf -e "virtual_transport = lmtp:inet:$DOVECOT_LMTP_ADDR"
else
  echo "No DOVECOT_LMTP_ADDR provided."
  exit 3
fi

if [[ -z $LDAP_HOST  ]]; then
  echo "No LDAP_HOST"
  exit 4
fi

if [[ -z $LDAP_BASE ]]; then
  echo "No LDAP_BASE"
  exit 5
fi

if [[ -z $LDAP_DN ]]; then
  echo "No LDAP_DN provided."
  exit 6
fi

if [[ -z $LDAP_DNPASS ]]; then
  echo "No LDAP_DNPASS provided."
  exit 7
fi

cat << EOM > /etc/postfix/virtual_domains.cf
server_host = $LDAP_HOST
search_base = $LDAP_BASE
version = 3
bind = yes
bind_dn = $LDAP_DN
bind_pw = $LDAP_DNPASS
query_filter = (&(objectClass=domainRelatedObject)(associatedDomain=%s))
result_attribute = dc
EOM


cat << EOM > /etc/postfix/virtual_aliases.cf
server_host = $LDAP_HOST
search_base = $LDAP_BASE
version = 3
bind = yes
bind_dn = $LDAP_DN
bind_pw = $LDAP_DNPASS
query_filter = (mail=%s)
result_attribute = mail
dereference = 3
leaf_result_attribute = mail
special_result_attribute = mailaliasmember
EOM

if [[ -z $TLS_CERT ]]; then
  echo "No TLS cert provided."
  exit 8
fi

if [[ -z $TLS_KEY ]]; then
  echo "No TLS key provided."
  exit 9
fi

postconf -e "virtual_mailbox_domains = ldap:/etc/postfix/virtual_domains.cf"
postconf -e "virtual_alias_maps = ldap:/etc/postfix/virtual_aliases.cf"

postconf -e "alias_maps = "
postconf -e "alias_database = "

if [[ ! -z $MAIL_ADMIN ]]; then
  echo "Setting root alias to $MAIL_ADMIN";
cat << EOM > /etc/alaises
root: $MAIL_ADMIN
EOM
  postconf -e 'alias_maps = hash:/etc/aliases';
  postconf -e 'alias_database = hash:/etc/aliases';
  newaliases
fi

postconf -e "smtpd_tls_security_level=may"
postconf -e "smtpd_tls_cert_file=$TLS_CERT"
postconf -e "smtpd_tls_key_file=$TLS_KEY"

postconf -M "submission/inet=submission   inet   n   -   n   -   -   smtpd"
postconf -P "submission/inet/syslog_name=postfix/submission"
postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
postconf -P "submission/inet/smtpd_etrn_restrictions=reject"
postconf -P "submission/inet/smtpd_sasl_type=dovecot"
postconf -P "submission/inet/smtpd_sasl_path=inet:$DOVECOT_SASL_ADDR"
postconf -P "submission/inet/smtpd_sasl_security_options=noanonymous"
postconf -P 'submission/inet/smtpd_sasl_local_domain=$myhostname'
postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
postconf -P "submission/inet/milter_macro_daemon_name=ORIGINATING"
postconf -P 'submission/inet/smtpd_client_restrictions=permit_sasl_authenticated,$mua_client_restrictions'
postconf -P "submission/inet/smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject"

postfix start-fg
