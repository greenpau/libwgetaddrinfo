/* source > getaddrinfo_w.c
 *.targoet > library to workaround AAAA records to be looked up via getaddrinfo.
 *
 * Copyright 2008 Red Hat, Inc.
 * Jose Plans <jplans@redhat.com>
 * <include GPL>
 */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <syslog.h>
#include <netdb.h>

#define MODPROMPT "libwgetaddrinfo.so: "

static int (*libc_getaddrinfo)(const char *hostname, const char *servname,
			const struct addrinfo *hints, struct addrinfo **res);

int getaddrinfo (const char *node, const char *service,
		const struct addrinfo *hints,
		struct addrinfo **res)
{
#ifdef DEBUG
    fprintf(stderr, MODPROMPT "Received getaddrinfo():\n");
#endif
	int getaddr_ret;
	char *errval;
	struct addrinfo _nhints;
	const struct addrinfo *nhints = &_nhints;

	libc_getaddrinfo = dlsym(RTLD_NEXT, "getaddrinfo");
	if (NULL == libc_getaddrinfo || (errval = dlerror()) != NULL) {
		syslog(LOG_ERR, MODPROMPT "dlsym: %s.", errval);
		fprintf(stderr, MODPROMPT "dlsym: %s.", errval);
		return EAI_SYSTEM;
	}

	/* Wokaround wrt RFC2553, if AF_UNSPEC is set, we will lookup
	   both IPv4 and IPv6. Some software can do this, and some routers
        won't allow AAAA DNS requests. */

	if (hints != NULL) {
        if ((hints->ai_family == AF_UNSPEC)) {
	        _nhints = *hints;
		    _nhints.ai_family = AF_INET;
		    if (!(hints->ai_flags & AI_ADDRCONFIG)) {
			    _nhints.ai_flags |= AI_ADDRCONFIG;
		    }
        }
	} 
	else	
		nhints = hints;

#ifdef DEBUG
    fprintf(stderr, MODPROMPT "node: %s.\n", node);
    fprintf(stderr, MODPROMPT "service: %s.\n", service);
    fprintf(stderr, MODPROMPT "hints: %s.\n", hints);
    fprintf(stderr, MODPROMPT "ai family: %x\n", &hints->ai_family);
#endif
	return libc_getaddrinfo(node, service, nhints, res);
}
