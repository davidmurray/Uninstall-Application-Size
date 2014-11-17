ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = UninstallAppSize
UninstallAppSize_FILES = Tweak.xm
UninstallAppSize_FRAMEWORKS = MobileCoreServices
#UninstallAppSize_PRIVATE_FRAMEWORKS = MobileInstallation

ADDITIONAL_CFLAGS = -I./ios-reversed-headers/
#ADDITIONAL_LDFLAGS = -F$(SYSROOT)/System/Library/PrivateFrameworks -weak_framework MobileInstallation

include $(THEOS_MAKE_PATH)/tweak.mk
