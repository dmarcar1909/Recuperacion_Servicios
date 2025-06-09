FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y \
    proftpd-basic \
    proftpd-mod-ldap \
    proftpd-mod-tls \
    openssl \
    quota \
    && apt-get clean

COPY proftpd.conf /etc/proftpd/proftpd.conf
COPY tls.conf /etc/proftpd/tls.conf
COPY mod_ldap.conf /etc/proftpd/ldap.conf
COPY certs/ /etc/ssl/private/
EXPOSE 21 20 30000-30009
CMD ["/usr/sbin/proftpd", "-n"]