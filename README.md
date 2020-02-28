# libwgetaddrinfo

Preliminary questions:

* **IPv6 enabled on non-IPv6-enabled network?**
* **Applications (browsers) suffer from delays?**

If the answer to the above questions is "YES", then this repo
is for you.

:note: This library is to be used at your own risk.

It should prevent you from having `AAAA` queries. Please understand
this is due to applications using `AF_UNSET` for `ai_family`, and DNS
servers not handling `AAAA` records correctly.

## Purpose

IPv6 lookup avoidance by `LD_PRELOAD=libwgetaddrinfo.so`.

`getaddrinfo()` will perform IPv4 and IPv6 lookups when using `AF_UNSET`.

Without `LD_PRELOAD`:

```
Capturing on eth0
   0.000000  10.10.56.5 -> 172.16.52.6 DNS Standard query AAAA xxx.yyy.redhat.com
   0.003102 172.16.52.6 -> 10.10.56.5  DNS Standard query response
   0.004262  10.10.56.5 -> 172.16.52.6 DNS Standard query AAAA xxx.yyy.redhat.com.zzzzz.yyy.redhat.com
   0.005721 172.16.52.6 -> 10.10.56.5  DNS Standard query response, No such name
   0.005801  10.10.56.5 -> 172.16.52.6 DNS Standard query A xxx.yyy.redhat.com
   0.007776 172.16.52.6 -> 10.10.56.5  DNS Standard query response A 10.11.5.7
```

With `LD_PRELOAD`:

```
Capturing on eth0
   0.000000  10.10.56.5 -> 172.16.52.6 DNS Standard query A xxx.yyy.redhat.com
   0.000967 172.16.52.6 -> 10.10.56.5  DNS Standard query response A 10.11.5.7
```

References:

* [The LD_PRELOAD trick](http://www.goldsborough.me/c/low-level/kernel/2016/08/29/16-48-53-the_-ld_preload-_trick/)
* [https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/417757/comments/98](https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/417757/comments/98)
