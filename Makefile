include /var/mobile/theos/makefiles/common.mk

TOOL_NAME = mdeb
mdeb_FILES = main.m

include $(THEOS)/makefiles/tool.mk

after-install::
	install.exec "mkdir -p /var/mobile/Documents/Mdeb/deb"
	install.exec "mkdir -p /var/mobile/Documents/Mdeb/dylib"
	install.exec "mkdir -p /var/mobile/Library/ExtractDylibs"
	install.exec "cp $(THEOS_PROJECT_DIR)/extract_dylibs.sh /var/mobile/Library/ExtractDylibs/"
	install.exec "chmod 755 /var/mobile/Library/ExtractDylibs/extract_dylibs.sh"

package::
	$(THEOS)/bin/tweakpack.sh
