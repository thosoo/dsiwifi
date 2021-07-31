ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPro")
endif

export TOPDIR	:=	$(CURDIR)

export DSIWIFI_MAJOR	:= 0
export DSIWIFI_MINOR	:= 1
export DSIWIFI_REVISION	:= 0

VERSION	:=	$(DSIWIFI_MAJOR).$(DSIWIFI_MINOR).$(DSIWIFI_REVISION)

.PHONY: release debug clean all

all: include/dswifi_version.h release debug

include/dswifi_version.h : Makefile
	@echo "#ifndef _dswifi_version_h_" > $@
	@echo "#define _dswifi_version_h_" >> $@
	@echo >> $@
	@echo "#define DSIWIFI_MAJOR    $(DSIWIFI_MAJOR)" >> $@
	@echo "#define DSIWIFI_MINOR    $(DSIWIFI_MINOR)" >> $@
	@echo "#define DSIWIFI_REVISION $(DSIWIFI_REVISION)" >> $@
	@echo >> $@
	@echo '#define DSIWIFI_VERSION "'$(DSIWIFI_MAJOR).$(DSIWIFI_MINOR).$(DSIWIFI_REVISION)'"' >> $@
	@echo >> $@
	@echo "#endif // _dswifi_version_h_" >> $@


#-------------------------------------------------------------------------------
release: lib
#-------------------------------------------------------------------------------
	$(MAKE) -C arm_host BUILD=release
	$(MAKE) -C arm_iop BUILD=release

#-------------------------------------------------------------------------------
debug: lib
#-------------------------------------------------------------------------------
	$(MAKE) -C arm_host BUILD=debug
	$(MAKE) -C arm_iop BUILD=debug

#-------------------------------------------------------------------------------
lib:
#-------------------------------------------------------------------------------
	mkdir lib

#-------------------------------------------------------------------------------
clean:
#-------------------------------------------------------------------------------
	@$(MAKE) -C arm_host clean
	@$(MAKE) -C arm_iop clean
	@$(RM) -r dswifi-src-*.tar.bz2 dswifi-*.tar.bz2 include/dswifi_version.h lib

#-------------------------------------------------------------------------------
dist-src:
#-------------------------------------------------------------------------------
	@tar --exclude=*CVS* --exclude=.svn -cjf dswifi-src-$(VERSION).tar.bz2 arm_iop/source arm_iop/Makefile arm_host/source arm_host/Makefile common include Makefile dswifi_license.txt

#-------------------------------------------------------------------------------
dist-bin: all
#-------------------------------------------------------------------------------
	@tar --exclude=*CVS* --exclude=.svn -cjf dswifi-$(VERSION).tar.bz2 include lib dswifi_license.txt

dist: dist-bin dist-src

#-------------------------------------------------------------------------------
install: dist-bin
#-------------------------------------------------------------------------------
	mkdir -p $(DESTDIR)$(DEVKITPRO)/libnds
	bzip2 -cd dswifi-$(VERSION).tar.bz2 | tar -x -C $(DESTDIR)$(DEVKITPRO)/libnds

