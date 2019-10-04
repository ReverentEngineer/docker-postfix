# docker-postfix

A docker image running a postfix that connects to an LDAP server

# Configuration

The image can be configured using the following bullets:

* **MAIL_HOSTNAME** - Hostname of the mail server
* **MAIL_D0MAIN**  - Primary domain of the mail server
* **RSPAMD_ADDR** (optional) - The address (host:port) of the Rspamd server
* **DOVECOT_SASL_ADDR** - The address of Dovecot SASL authentication service
* **DOVECOT_LMTP_ADDR** - The address of Dovecot LMTP mail transport service
* **LDAP_HOST** - The LDAP host URI
* **LDAP_BASE** - THe LDAP base DN
* **LDAP_DN** - The LDAP DN to use for lookups
* **LDAP_DNPASS** - The password for LDAP_DN
* **TLS_CERT** - The location of the TLS certificate
* **TLS_KEY** - The location of the TLS certificate private key
