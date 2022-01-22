# ![NGINX logo](https://raw.github.com/eugenmayer/nginx-ldap/master/images/NginxLogo.gif)

## Introduction

The intention to create this Dockerfile was to provide an [NGINX web server](https://github.com/nginx/nginx) with builtin [LDAP support](https://github.com/eugenmayer/nginx-auth-ldap) and SSL.

The main difference with the [original h3nrik/nginx-ldap image](https://registry.hub.docker.com/u/h3nrik/nginx-ldap/) is that this is based on Alpine Linux 3.15, which greatly reduces the size of the image. It uses a multi-stage build to keep the resulting image as clean as possible.

The sources including the configuration sample files can be found at [GitHub](https://github.com/eugenmayer/nginx-ldap).

The docker image can be downloaded from [Github](https://github.com/EugenMayer/docker-image-nginx-ldap/pkgs/container/nginx-ldap).

## Usage

### Static page without authentication

The following container will provide the NGINX static default page:

    docker run --name nginx -d -p 80:80 ghcr.io/eugenmayer/nginx-ldap

To run an instance with your own static page run:

    docker run --name nginx -v /some/content:/usr/share/nginx/html:ro -d -p 80:80 ghcr.io/eugenmayer/nginx-ldap

### Static page with LDAP authentication

The following instructions create an NGINX container that provides a static page authenticating against LDAP:

1.  Create an NGINX Docker container with an nginx.conf file that has LDAP authentication enabled. You can find a sample [nginx.conf](https://github.com/g17/nginx-ldap/blob/master/config/basic/nginx.conf) file in the config folder that provides the static default NGINX welcome page.

        docker run --name nginx --link ldap:ldap -d -v `pwd`/config/basic/nginx.conf:/nginx.conf:ro -p 80:80 ghcr.io/eugenmayer/nginx-ldap

2.  When you now access the NGINX server via port 80 you will get an authentication dialog. The user name for the test user is _test_ and the password is _t3st_.

Further information about how to configure NGINX with ldap can be found at the [nginx-auth-ldap module site](https://github.com/kvspb/nginx-auth-ldap).

## Debugging

The NGINX web server has been compiled with _debug_ support. You can add the following line to your NGINX configuration to get debug output:

    error_log /var/log/nginx/error.log debug;

Then the debug log can be read with the following command:

    docker exec -i -t nginx less /var/log/nginx/error.log

You will then see debug output like:

    ...
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Username is "test"
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=0, iteration=0)
    2015/02/14 17:57:10 [debug] 5#0: *2 event timer add: 3: 10000:1423936640056
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: request_timeout=10000
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=1, iteration=0)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Wants a free connection to "ldapserver"
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Search filter is "(&(objectClass=person)(uid=test))"
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: ldap_search_ext() -> msgid=4
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Waking authentication request "GET / HTTP/1.1"
    2015/02/14 17:57:10 [debug] 5#0: *2 access phase: 6
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=1, iteration=1)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=2, iteration=1)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: User DN is "uid=test,ou=users,dc=example,dc=com"
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=3, iteration=0)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Comparing user group with "cn=docker,ou=groups,dc=example,dc=com"
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: ldap_compare_ext() -> msgid=5
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Waking authentication request "GET / HTTP/1.1"
    2015/02/14 17:57:10 [debug] 5#0: *2 access phase: 6
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=3, iteration=1)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=4, iteration=0)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: ldap_sasl_bind() -> msgid=6
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Waking authentication request "GET / HTTP/1.1"
    2015/02/14 17:57:10 [debug] 5#0: *2 access phase: 6
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=4, iteration=1)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: User bind successful
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=5, iteration=0)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Rebinding to binddn
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: ldap_sasl_bind() -> msgid=7
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Waking authentication request "GET / HTTP/1.1"
    2015/02/14 17:57:10 [debug] 5#0: *2 access phase: 6
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=5, iteration=1)
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: binddn bind successful
    2015/02/14 17:57:10 [debug] 5#0: *2 http_auth_ldap: Authentication loop (phase=6, iteration=1)
    ...

## Release

```
./build.sh && ./push.sh
```

## Licenses

This docker image contains compiled binaries for:

1. The NGINX web server. Its license can be found on the [NGINX website](http://nginx.org/LICENSE).
2. The nginx-auth-ldap module. Its license can be found on the [nginx-auth-ldap module project site](https://github.com/eugenmayer/nginx-auth-ldap/blob/master/LICENSE).
