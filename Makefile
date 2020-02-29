.PHONY: clean install test
LIB_NAME=libwgetaddrinfo
LIB_PATH=/usr/local/lib/libwgetaddrinfo/lib

all: clean getaddrinfo_w.c
	echo "Building"
	mkdir -p lib
	#gcc -DDEBUG -D_GNU_SOURCE -fPIC -lm -ldl -shared -Wl,-soname,$(LIB_NAME).so.1 -o ./lib/$(LIB_NAME).so.1.0 getaddrinfo_w.c
	gcc -D_GNU_SOURCE -fPIC -lm -ldl -shared -Wl,-soname,$(LIB_NAME).so.1 -o ./lib/$(LIB_NAME).so.1.0 getaddrinfo_w.c
	cd lib && ln -s `pwd`/$(LIB_NAME).so.1.0 `pwd`/$(LIB_NAME).so.1
	cd lib && ln -s `pwd`/$(LIB_NAME).so.1 `pwd`/$(LIB_NAME).so

clean:
	@echo "Performing cleanup"
	rm -rf ./lib/
	rm -f *.o
	rm -f $(LIB_NAME).so*

install:
	sudo rm -rf $(LIB_PATH)
	sudo mkdir -p $(LIB_PATH)
	sudo cp $(LIB_NAME).so.1.0 $(LIB_PATH)/
	sudo ln -s $(LIB_PATH)/$(LIB_NAME).so.1.0 $(LIB_PATH)/$(LIB_NAME).so.1 2>/dev/null
	sudo ln -s $(LIB_PATH)/$(LIB_NAME).so.1 $(LIB_PATH)/$(LIB_NAME).so 2>/dev/null

test:
	#LD_PRELOAD=`pwd`/lib/$(LIB_NAME).so strace nslookup www.google.com
	#LD_PRELOAD=`pwd`/lib/$(LIB_NAME).so strace dig www.google.com ANY
	LD_PRELOAD=`pwd`/lib/$(LIB_NAME).so dig www.google.com AAAA
