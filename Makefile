include theos/makefiles/common.mk

TWEAK_NAME = UninstallAppSize
UninstallAppSize_FILES = Tweak.xm
UninstallAppSize_PRIVATE_FRAMEWORKS = MobileInstallation

ADDITIONAL_CFLAGS = -I./ios-reversed-headers/

include $(THEOS_MAKE_PATH)/tweak.mk
