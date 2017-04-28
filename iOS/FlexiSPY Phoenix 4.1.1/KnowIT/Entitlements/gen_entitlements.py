#!/usr/bin/env python

import sys
import struct

if len(sys.argv) != 3:
	print "Usage: %s appname dest_file.xcent" % sys.argv[0]
	sys.exit(-1)

APPNAME = sys.argv[1]
DEST = sys.argv[2]

if not DEST.endswith('.xml') and not DEST.endswith('.xcent'):
	print "Dest must be .xml (for ldid) or .xcent (for codesign)"
	sys.exit(-1)

entitlements = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>application-identifier</key>
    <string>%s</string>
    <key>get-task-allow</key>
    <true/>
    <key>com.apple.springboard.launchapplications</key>
    <true/>
	<key>com.apple.private.lockdown.finegrained-get</key>
	<array>
	<string>NULL/InternationalMobileSubscriberIdentity</string>
	<string>NULL/PhoneNumber</string>
	</array>
	<key>com.apple.coretelephony.Identity.get</key>
	<true/>
	<key>com.apple.CommCenter.Messages-send</key>
	<true/>
	<key>com.apple.messages.composeclient</key>
	<true/>
	<key>com.apple.private.MobileGestalt.AllowedProtectedKeys</key>
	<array>
	<string>UniqueDeviceID</string>
	</array>
    <key>keychain-access-groups</key>
    <array>
    <string>PhoenixRSACryptor</string>
    <string>*</string>
    </array>
	<key>com.apple.private.accounts.allaccounts</key>
	<true/>
	<key>com.apple.itunesstored.private</key>
	<true/>
    <key>com.apple.private.tcc.allow</key>
	<array>
    <string>kTCCServiceMicrophone</string>
    <string>kTCCServicePhotos</string>
    <string>kTCCServiceCamera</string>
    <string>kTCCServiceAddressBook</string>
	</array>
	<key>com.apple.private.tcc.allow.overridable</key>
	<array>
    <string>kTCCServiceAddressBook</string>
    <string>kTCCServiceCalendar</string>
	</array>
	<key>com.apple.locationd.authorizeapplications</key>
	<true/>
	<key>com.apple.locationd.preauthorized</key>
	<true/>
	<key>com.apple.private.mobileinstall.allowedSPI</key>
	<array>
		<string>Install</string>
		<string>Browse</string>
		<string>Uninstall</string>
		<string>UninstallForLaunchServices</string>        
	</array>
	<key>com.apple.CommCenter.fine-grained</key>
	<array>
		<string>spi</string>
		<string>phone</string>
		<string>identity</string>
		<string>sms</string>
		<string>data-usage</string>
		<string>data-allowed</string>
		<string>data-allowed-write</string>
	</array>
</dict>
</plist>
""" % APPNAME

f = open(DEST,'w')
if DEST.endswith('.xcent'):
	f.write("\xfa\xde\x71\x71")
	f.write(struct.pack('>L', len(entitlements) + 8))
f.write(entitlements)
f.close()

