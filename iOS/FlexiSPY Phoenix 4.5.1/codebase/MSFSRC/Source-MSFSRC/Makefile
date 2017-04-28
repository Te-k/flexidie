ARCHS=armv7 arm64
TARGET=iphone:latest:7.1

include theos/makefiles/common.mk
TWEAK_NAME = CallRec
CallRec_FILES = Tweak.xm PCMMixer.m
CallRec_FRAMEWORKS = QuartzCore CoreGraphics AVFoundation CoreAudio CoreLocation CoreTelephony UIKit CoreFoundation Foundation AudioToolbox
CallRec_LDFLAGS = -lmp3lame -lhttpkit -lresample-arm-apple-darwin9 -lsrtp-arm-apple-darwin9 -lpjnath-arm-apple-darwin9 -lpjsip-simple-arm-apple-darwin9 -lpjsua-arm-apple-darwin9 -lpjsip-arm-apple-darwin9 -lpjmedia-codec-arm-apple-darwin9 -lpjmedia-audiodev-arm-apple-darwin9 -lpjmedia-arm-apple-darwin9  -lpj-arm-apple-darwin9 -lpjlib-util-arm-apple-darwin9
include $(THEOS_MAKE_PATH)/tweak.mk
before-package::
	cp preinst $(THEOS_STAGING_DIR)/DEBIAN/preinst
	chmod 775 $(THEOS_STAGING_DIR)/DEBIAN/preinst
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postinst
	chmod 775 $(THEOS_STAGING_DIR)/DEBIAN/postinst
	cp prerm $(THEOS_STAGING_DIR)/DEBIAN/prerm
	chmod 775 $(THEOS_STAGING_DIR)/DEBIAN/prerm
	cp postrm $(THEOS_STAGING_DIR)/DEBIAN/postrm
	chmod 775 $(THEOS_STAGING_DIR)/DEBIAN/postrm
include $(THEOS_MAKE_PATH)/aggregate.mk
