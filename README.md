# libwgetaddrinfo

Preliminary questions:

* **IPv6 enabled on non-IPv6-enabled network?**
* **Applications (browsers) suffer from delays?**

If the answer to the above questions is "YES", then this repo
is for you.

**What is the issue?**

As discussed [here](https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/417757?comments=all),
when an application on IPv6 enabled hosts tries to look up an address
for a host, the following happens:

1. The application asks for a AAAA record with `getaddrinfo()`
2. The DNS resolver sees the request for the AAAA record, goes "uhmmm I dunno what it is, lets throw it away"
3. DNS client (`getaddrinfo()` in libc) waits for a response..... has
  to time out as there is no response. (THIS IS THE DELAY)
4. No records received yet, thus getaddrinfo() goes for a the A record
  request. This works.
5. Program gets the A records and uses those.

:warning: This library is to be used at your own risk.

It should prevent you from having `AAAA` queries. Please understand
this is due to applications using `AF_UNSET` for `ai_family`, and DNS
servers not handling `AAAA` records correctly.

## Purpose

By using the `LD_PRELOAD=libwgetaddrinfo.so`, a system avoids making
IPv6 lookups. However, `getaddrinfo()` will perform IPv4 and IPv6
lookups when using `AF_UNSET`.

For example, this is the trace of DNS queries without `LD_PRELOAD=libwgetaddrinfo.so` set:

```
Capturing on eth0
   0.000000  10.10.56.5 -> 172.16.52.6 DNS Standard query AAAA xxx.yyy.redhat.com
   0.003102 172.16.52.6 -> 10.10.56.5  DNS Standard query response
   0.004262  10.10.56.5 -> 172.16.52.6 DNS Standard query AAAA xxx.yyy.redhat.com.zzzzz.yyy.redhat.com
   0.005721 172.16.52.6 -> 10.10.56.5  DNS Standard query response, No such name
   0.005801  10.10.56.5 -> 172.16.52.6 DNS Standard query A xxx.yyy.redhat.com
   0.007776 172.16.52.6 -> 10.10.56.5  DNS Standard query response A 10.11.5.7
```

With `LD_PRELOAD=libwgetaddrinfo.so` set:

```
Capturing on eth0
   0.000000  10.10.56.5 -> 172.16.52.6 DNS Standard query A xxx.yyy.redhat.com
   0.000967 172.16.52.6 -> 10.10.56.5  DNS Standard query response A 10.11.5.7
```

## Building from Source

The following sequence of commands builds the library:

```bash
git clone https://github.com/greenpau/libwgetaddrinfo.git
cd libwgetaddrinfo && make
```

## Installation

Once you have `libwgetaddrinfo.so.1.0`, run the following commant.
It creates `/etc/ld.so.conf.d/libwgetaddrinfo.conf`. The file points
to the library directory `/usr/local/lib/libwgetaddrinfo/lib/`.

```bash
make install
```

The directory contains the `libwgetaddrinfo.so.1.0` and two symbolic links:

```bash
$ ls -alh /usr/local/lib/libwgetaddrinfo/lib/
total 12K
.
..
libwgetaddrinfo.so -> /usr/local/lib/libwgetaddrinfo/lib/libwgetaddrinfo.so.1
libwgetaddrinfo.so.1 -> /usr/local/lib/libwgetaddrinfo/lib/libwgetaddrinfo.so.1.0
libwgetaddrinfo.so.1.0
```

## References

* [The LD_PRELOAD trick](http://www.goldsborough.me/c/low-level/kernel/2016/08/29/16-48-53-the_-ld_preload-_trick/)
* [https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/417757/comments/98](https://bugs.launchpad.net/ubuntu/+source/eglibc/+bug/417757/comments/98)
