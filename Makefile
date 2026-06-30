# Makefile for Safari Tab Blocker
# Targets iPadOS 17 with Rootless Palera1n support

THEOS := $(shell which theos)
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SafariTabBlocker
TWEAK_BUNDLE_ID = com.yourname.safaritabblocker
TWEK_VERSION = 1.0.0

# Target configuration for iPadOS 17
TARGET_DEVICE = YES
ARCHS = arm64e
IPHONEOS_DEPLOYMENT_TARGET = 17.0

# Rootless Palera1n specific settings
ROOTLESS = YES
DYLD_INTERPOSE = YES

# Source files
SafariTabBlocker_FILES = \
    Sources/Tweak.xm \
    Sources/URLManager.m \
    Sources/BlockPrompt.m

# Frameworks to link
SafariTabBlocker_FRAMEWORKS = \
    UIKit \
    Foundation \
    CoreGraphics \
    SafariServices \
    WebKit \
    QuartzCore \
    SystemConfiguration

# Libraries (static for rootless compatibility)
SafariTabBlocker_LIBRARIES = sqlite3

# Installation paths
INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

# Settings bundle path
SETTINGS_BUNDLE_PATH = /Library/PreferenceBundles/SafariTabBlockerSettings.bundle

# Build flags for rootless
CFLAGS += -fobjc-arc \
          -fexceptions \
          -DROOTLESS=1 \
          -DTARGET_IPADOS=1 \
          -Wno-deprecated-declarations \
          -Wno-nullability-completeness

LDFLAGS += -all_load \
           -ObjC \
           -lsqlite3

# Post-install script
after-SafariTabBlocker-install::
	$(ECHO) "Installing settings bundle..."
	$(INSTALL) -d $(PREFIX)/Library/PreferenceBundles/SafariTabBlockerSettings.bundle
	$(CP) Resources/Settings.bundle/* $(PREFIX)/Library/PreferenceBundles/SafariTabBlockerSettings.bundle/

include $(THEOS_MAKE_PATH)/tweak.mk
