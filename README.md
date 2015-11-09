# Authentication
Muul reads a file pointed to by $MUUL_BASIC_AUTH_FILE. It is expected to contain valid htpasswd entries like `username:password`. If omitted or not found, Muul simply ignores it.
Also Muuls reads $MUUL_LDAP_URL and tries to authenticate users with it. Example: `ldaps://ldap.acme.com/uid/ou=users,dc=acme,dc=com`

# Running
```
DEBUG=yes MUUL_MARATHON_URL=http://marathon1.acme.com:8080 MUUL_LDAP_URL=ldaps://ldap.acme.com/uid?ou=users,dc=sinnerschrader,dc=com MUUL_BASIC_AUTH_FILE=./test/examples/htpasswd unicorn -l 127.0.0.1:8080
```

# Notes on dependencies
As much as we like it running with puma, as of right now, only single threaded webservers are supported.
