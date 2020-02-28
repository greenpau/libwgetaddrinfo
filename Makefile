.PHONY: clean install
LIB_NAME=libwgetaddrinfo
LIB_PATH=/usr/local/lib/libwgetaddrinfo/lib

all: clean libs

libs: getaddrinfo_w.c
	gcc -D_GNU_SOURCE -fPIC -lm -ldl -shared -Wl,-soname,$(LIB_NAME).so.1 -o $(LIB_NAME).so.1.0 getaddrinfo_w.c

clean:
	rm -f *.o
	rm -f $(LIB_NAME).so*

install:
	@sudo mkdir -p $(LIB_PATH)
	@sudo cp $(LIB_NAME).so.1.0 $(LIB_PATH)/
	@sudo cp ld.so.conf.d/$(LIB_NAME).conf /etc/ld.so.conf.d/
	@sudo ln -s $(LIB_PATH)/$(LIB_NAME).so.1.0 $(LIB_PATH)/$(LIB_NAME).so.1 2>/dev/null
	@sudo ln -s $(LIB_PATH)/$(LIB_NAME).so.1 $(LIB_PATH)/$(LIB_NAME).so 2>/dev/null
	@sudo ldconfig
