.PHONY: clean

all: clean libs

libs: getaddrinfo_w.c
	gcc -D_GNU_SOURCE -fPIC -lm -ldl -shared -Wl,-soname,libwgetaddrinfo.so.1 -o libwgetaddrinfo.so.1.0 getaddrinfo_w.c
	ln -s libwgetaddrinfo.so.1.0 libwgetaddrinfo.so.1 2>/dev/null
	ln -s libwgetaddrinfo.so.1 libwgetaddrinfo.so 2>/dev/null
	@echo "export LD_PRELOAD=libwgetaddrinfo.so"
	@echo "export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH"

clean:
	rm -f *.o
	rm -f libwgetaddrinfo.so*
