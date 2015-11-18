PLATFORM                := $(strip $(shell echo `uname -m`))
TARGET                  := $(strip $(TARGET))
SUFFIX                  := $(suffix $(TARGET))
MFLAGS                  := $(strip $(MFLAGS))

ifeq ($(PLATFORM),x86_64)
        MFLAGS          := 64
else
        MFLAGS          := 32
endif		

VERSION_MAJOR  := 1
VERSION_MINOR  := 0
VERSION_PATCH  := 0
VERSION_PATCH_MINOR := 0
HAF_VERSION    := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH).$(VERSION_PATCH_MINOR)

HAFLIB_PATH	:= ${TOPDIR}/lib/
LIB      	+= -L${HAFLIB_PATH} -lpthread

INCLUDE     	+= -I${TOPDIR}/include

LOCAL_SRC   	+= $(sort $(wildcard *.cpp *.c))
LOCAL_OBJ   	+= $(patsubst %.cpp,%.o, $(patsubst %.c,%.o, $(LOCAL_SRC)))
DEP_FILE    	:= $(foreach obj, $(LOCAL_OBJ), $(dir $(obj)).$(basename $(notdir $(obj))).d)

CC          	= gcc
CXX         	= g++
CFLAGS      	+= -g -fPIC -Wno-deprecated -Wall -DHAF_VERSION=\"$(HAF_VERSION)\"

#----------------------------------------------------------------------------------

copyfile = if test -z "$(APP)" || test -z "$(TARGET)"; then \
               echo "['APP' or 'TARGET' option is empty.]"; exit 1; \
           	else \
		       	if test ! -d $(2); then \
              		echo "[No such dir:$(2), now we create it.]";\
    				mkdir -p $(2);\
				fi; \
         		echo "[Copy file $(1) -> $(2)]"; \
         		cp -v $(1) $(2); \
			fi;
#----------------------------------------------------------------------------------

all : $(LOCAL_OBJ) $(TARGET)

$(filter %.a,$(TARGET)) : $(LOCAL_OBJ)
	ar r $@ $(LOCAL_OBJ)

$(filter %.so,$(TARGET)) : $(LOCAL_OBJ)
	$(CC) -m$(MFLAGS) $(LFLAGS) -shared -o $@ $(LOCAL_OBJ) $(LIB)

$(filter-out %.so %.a,$(TARGET)) : $(LOCAL_OBJ)
	$(CXX) -m$(MFLAGS) $(CFLAGS) -o $@ $^ $(INCLUDE) $(LIB)

clean:
	rm -vf $(LOCAL_OBJ) $(TARGET) $(DEP_FILE)

release:
	@$(call copyfile, *.a, $(HAFLIB_PATH))

.%.d: %.cpp
	@echo "update $@ ..."; \
	echo -n $< | sed s/\.cpp/\.o:/ > $@; \
	$(CC) $(INCLUDE) -MM $< | sed '1s/.*.://' >> $@;

%.o: %.cpp
	$(CXX) -m$(MFLAGS) $(CFLAGS) $(INCLUDE) -o $@ -c $<

.%.d: %.c
	@echo "update $@ ..."; \
	echo -n $< | sed s/\.c/\.o:/ > $@; \
	$(CC) $(INCLUDE) -MM $< | sed '1s/.*.://' >> $@;

%.o: %.c
	$(CC) -m$(MFLAGS) $(CFLAGS) $(INCLUDE) -o $@ -c $<
