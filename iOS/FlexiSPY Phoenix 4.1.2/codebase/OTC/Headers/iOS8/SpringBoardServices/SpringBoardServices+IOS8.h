/*
* SpringBoardServices framework header.
*
* Borrows work done by KennyTM.
* See https://github.com/kennytm/iphone-private-frameworks/blob/master/SpringBoardServices/SpringBoardServices.h
* for more information.
*
* Copyright (c) 2010 KennyTM~
* Copyright (c) 2013-2014 Cykey (David Murray)
* All rights reserved.
*/
#ifndef SPRINGBOARDSERVICES_H_
#define SPRINGBOARDSERVICES_H_
#include <CoreFoundation/CoreFoundation.h>
#if __cplusplus
extern "C" {
#endif
#pragma mark - API
mach_port_t SBSSpringBoardServerPort();
	void SBSetSystemVolumeHUDEnabled(mach_port_t springBoardPort, const char *audioCategory, Boolean enabled);
	void SBGetScreenLockStatus(mach_port_t port, BOOL *lockStatus, BOOL *passcodeEnabled);
	void SBSOpenNewsstand();
	void SBSSuspendFrontmostApplication();
	CFStringRef SBSCopyStatusBarOperatorName();
	CFStringRef SBSCopyBundlePathForDisplayIdentifier(CFStringRef displayIdentifier);
	CFStringRef SBSCopyExecutablePathForDisplayIdentifier(CFStringRef displayIdentifier);
	CFDataRef SBSCopyIconImagePNGDataForDisplayIdentifier(CFStringRef displayIdentifier);
	CFStringRef SBSCopyNowPlayingAppBundleIdentifier();
	CFSetRef SBSCopyDisplayIdentifiers();
	CFStringRef SBSCopyLocalizedApplicationNameForDisplayIdentifier(CFStringRef identifier);
	CFStringRef SBSCopyFrontmostApplicationDisplayIdentifier();
	CFStringRef SBSCopyDisplayIdentifierForProcessID(pid_t PID);
	CFDictionaryRef SBSCopyInfoForApplicationWithProcessID(pid_t PID);
	CFArrayRef SBSCopyDisplayIdentifiersForProcessID(pid_t PID);
	BOOL SBSProcessIDForDisplayIdentifier(CFStringRef identifier, pid_t *pid);
	// The following need com.apple.backboardd.launchapplications entitlement
	int SBSLaunchApplicationWithIdentifier(CFStringRef identifier, Boolean suspended);
	int SBSLaunchApplicationWithIdentifierAndLaunchOptions(CFStringRef identifier, CFDictionaryRef launchOptions, BOOL suspended);
	CFStringRef SBSApplicationLaunchingErrorString(int error);
	int SBSOpenSensitiveURLAndUnlock(CFURLRef url, char flags); // need com.apple.springboard.opensensitiveurl entitlement
#if __cplusplus
}
#endif
#endif /* SPRINGBOARDSERVICES_H_ */