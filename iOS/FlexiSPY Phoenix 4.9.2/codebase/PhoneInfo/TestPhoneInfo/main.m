//
//  main.m
//  TestPhoneInfo3
//
//  Created by Dominique  Mayrand on 11/4/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dlfcn.h>

#import "PhoneInfoImp.h"
#import "CTTelephonyNetworkInfo.h"

//extern NSString *kSubscriberImsi;
//extern NSString *kCTMobileEquipmentInfoIMSI;

void RunAllStrings();

int main(int argc, char *argv[]) {
	NSLog(@"in main");
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
	PhoneInfoImp *phoneInfo = [[PhoneInfoImp alloc] init];
	NSLog(@"imsi %@", [phoneInfo getIMSI]);
	NSLog(@"mobile network code %@", [phoneInfo getMobileNetworkCode]);
	NSLog(@"mobile country code %@", [phoneInfo getMobileCountryCode]);
	NSLog(@"network name %@", [phoneInfo getNetworkName]);
	NSLog(@"imei %@", [phoneInfo getIMEI]);
	NSLog(@"meid %@", [phoneInfo getMEID]);
	NSLog(@"phone number %@", [phoneInfo getPhoneNumber]);
	NSLog(@"device model %@", [phoneInfo getDeviceModel]);
	NSLog(@"device info %@", [phoneInfo getDeviceInfo]);
	NSLog(@"network type %d", [phoneInfo getNetworkType]);
	NSLog(@"cell id %@", [phoneInfo getCellID]);
	NSLog(@"location area code %@", [phoneInfo getLocalAreaCode]);
	[phoneInfo release];
    
    //RunAllStrings();

	/*
	CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
	if ([telephonyNetworkInfo respondsToSelector:@selector(cachedCellId)])
		NSLog(@"cachedCellId %@", [telephonyNetworkInfo cachedCellId]);
	if ([telephonyNetworkInfo respondsToSelector:@selector(cachedSignalStrength)])
		NSLog(@"cachedSignalStrength %@", [telephonyNetworkInfo cachedSignalStrength]);
	if ([telephonyNetworkInfo respondsToSelector:@selector(cachedCurrentRadioAccessTechnology)])
		NSLog(@"cachedCurrentRadioAccessTechnology %@", [telephonyNetworkInfo cachedCurrentRadioAccessTechnology]);
	if ([telephonyNetworkInfo respondsToSelector:@selector(cellId)])
		NSLog(@"cellId %@", [telephonyNetworkInfo cellId]);
	if ([telephonyNetworkInfo respondsToSelector:@selector(currentRadioAccessTechnology)])
		NSLog(@"currentRadioAccessTechnology %@", [telephonyNetworkInfo currentRadioAccessTechnology]);
	if ([telephonyNetworkInfo respondsToSelector:@selector(signalStrength)])
		NSLog(@"signalStrength %@", [telephonyNetworkInfo signalStrength]);
	
	if ([telephonyNetworkInfo respondsToSelector:@selector(subscriberCellularProvider)]) {
		NSLog(@"carrier %@", [telephonyNetworkInfo subscriberCellularProvider]);
	}
	
	if ([telephonyNetworkInfo respondsToSelector:@selector(subscriberCellularProviderDidUpdateNotifier)]) {
		NSLog(@"carrier notifier %@", [telephonyNetworkInfo performSelector:@selector(subscriberCellularProviderDidUpdateNotifier)]);
	}
	
	Class $CTSubscriberInfo = objc_getClass("CTSubscriberInfo");
	NSLog(@"Class of CTSubscriberInfo = %@", $CTSubscriberInfo);
	id subscriber = [$CTSubscriberInfo performSelector:@selector(subscriber)];
	NSLog(@"subscriber token = %@", [subscriber performSelector:@selector(carrierToken)]);
	
	
	[telephonyNetworkInfo release];
	
	void *kit		= dlopen("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony",RTLD_LAZY); 
	NSString *imsi	= nil;
	NSString* (*CTSIMSupportCopyMobileSubscriberIdentity)()	= dlsym (kit, "CTSIMSupportCopyMobileSubscriberIdentity");
	imsi			= (NSString*) CTSIMSupportCopyMobileSubscriberIdentity(nil);
	NSLog (@"get IMSI = %@, kit = %d, function = %d", imsi, (kit != nil), (CTSIMSupportCopyMobileSubscriberIdentity != nil));
	
	NSString* (*CTSIMSupportCopyMobileSubscriberNetworkCode)() = dlsym (kit, "CTSIMSupportCopyMobileSubscriberNetworkCode");
	NSString *networkCode	= (NSString*) CTSIMSupportCopyMobileSubscriberNetworkCode(nil);
	NSLog (@"get network code = %@, kit = %d, function = %d", networkCode, (kit != nil), (CTSIMSupportCopyMobileSubscriberNetworkCode != nil));
	
//	Class $CTMessageCenter = objc_getClass("CTMessageCenter");
//	id center = [$CTMessageCenter sharedMessageCenter];
//	[center sendSMSWithText:@"Hello iOS 7" serviceCenter:nil toAddress:@"0911121361"];
//	NSLog(@"Message sent...");
	
	//NSLog(@"kSubscriberImsi = %@", kSubscriberImsi);
	//NSLog(@"kCTMobileEquipmentInfoIMSI = %@", kCTMobileEquipmentInfoIMSI);
	
	id (*CopyMobileUserInformation)() = dlsym (kit, "CopyMobileUserInformation");
	id mobileUserInfo	= CopyMobileUserInformation(nil);
	NSLog (@"get network code = %@, kit = %d, function = %d", mobileUserInfo, (kit != nil), (CTSIMSupportCopyMobileSubscriberNetworkCode != nil));
	
	dlclose(kit);
	
	while (TRUE) {
		PhoneInfoImp *phoneInfo = [[PhoneInfoImp alloc] init];	
		
		NSLog(@"IMSI %@", [phoneInfo getIMSI]);
		[phoneInfo getIMEI];
		[NSThread sleepForTimeInterval:3];
		
		[phoneInfo release];
	}
*/
	[pool release];
	return retVal;
}


void RunAllStrings()
{
    extern CFStringRef kLockdownProtocolVersion;
    extern CFStringRef kLockdownHardwareModelKey;
    extern CFStringRef kLockdownProtocolVersionKey;
    extern CFStringRef kLockdownDeviceClassKey;
    extern CFStringRef kLockdownUniqueDeviceIDKey;
    extern CFStringRef kLockdownInverseDeviceIDKey;
    extern CFStringRef kLockdownDeviceNameKey;
    extern CFStringRef kLockdownActivationStateKey;
    extern CFStringRef kLockdownReservedBytesKey;
    extern CFStringRef kLockdownBuildVersionKey;
    extern CFStringRef kLockdownProductVersionKey;
    extern CFStringRef kLockdownReleaseTypeKey;
    extern CFStringRef kLockdownProductTypeKey;
    extern CFStringRef kLockdownSerialNumberKey;
    extern CFStringRef kLockdownMLBSerialNumberKey;
    extern CFStringRef kLockdownUniqueChipIDKey;
    extern CFStringRef kLockdownModelNumberKey;
    extern CFStringRef kLockdownRegionInfoKey;
    extern CFStringRef kLockdownIMEIKey;
    extern CFStringRef kLockdownIMSIKey;
    extern CFStringRef kLockdownICCIDKey;
    extern CFStringRef kLockdownSIMGID1Key;
    extern CFStringRef kLockdownSIMGID2Key;
    extern CFStringRef kLockdownBasebandThumbprintKey;
    extern CFStringRef kLockdownUnlockCodeKey;
    extern CFStringRef kLockdownActivationTicketKey;
    extern CFStringRef kLockdownWildcardTicketKey;
    extern CFStringRef kLockdownProposedTicketKey;
    extern CFStringRef kLockdownSIMStatusKey;
    extern CFStringRef kLockdownPhoneNumberKey;
    extern CFStringRef kLockdownBasebandVersionKey;
    extern CFStringRef kLockdownBasebandBootloaderVersionKey;
    extern CFStringRef kLockdownFirmwareVersionKey;
    extern CFStringRef kLockdownCPUArchitectureKey;
    extern CFStringRef kLockdownBasebandMasterKeyHashKey;
    extern CFStringRef kLockdownSoftwareBehaviorKey;
    extern CFStringRef kLockdownWifiAddressKey;
    extern CFStringRef kLockdownBluetoothAddressKey;
    extern CFStringRef kLockdownDeviceCertificateKey;
    extern CFStringRef kLockdownDevicePublicKey;
    extern CFStringRef kLockdownDevicePrivateKey;
    extern CFStringRef kLockdownActivationPrivateKey;
    extern CFStringRef kLockdownActivationPublicKey;
    extern CFStringRef kLockdownDebugDockPresentKey;
    extern CFStringRef kLockdowniTunesHasConnectedKey;
    extern CFStringRef kLockdownBrickStateKey;
    extern CFStringRef kLockdownActivationInfoKey;
    extern CFStringRef kLockdownActivationRandomnessKey;
    extern CFStringRef kLockdownActivationInfoCompleteKey;
    extern CFStringRef kLockdownActivationInfoErrorsKey;
    extern CFStringRef kLockdownFairPlayKeyDataKey;
    extern CFStringRef kLockdownFairPlayIDKey;
    extern CFStringRef kLockdownFairPlayGUIDKey;
    extern CFStringRef kLockdownFairPlayCertificateKey;
    extern CFStringRef kLockdownFairPlayContextIDKey;
    extern CFStringRef kLockdownFairPlayRentalClockBias;
    extern CFStringRef kLockdownHostAttachedKey;
    extern CFStringRef kLockdownTrustedHostAttachedKey;
    extern CFStringRef kLockdownCarrierBundleInfoKey;
    extern CFStringRef kLockdownProductionSOCKey;
    extern CFStringRef kLockdownNVRAMKey;
    extern CFStringRef kLockdownSoftwareBehaviorDomainKey;
    extern CFStringRef kLockdownBehaviorsValidKey;
    extern CFStringRef kLockdownGoogleMailKey;
    extern CFStringRef kLockdownVolumeLimitKey;
    extern CFStringRef kLockdownShutterClickKey;
    extern CFStringRef kLockdownNTSCKey;
    extern CFStringRef kLockdownNoWiFiKey;
    extern CFStringRef kLockdownChinaBrickKey;
    extern CFStringRef kLockdownStoreDomainKey;
    extern CFStringRef kLockdownDSPersonIDKey;
    extern CFStringRef kLockdownCheckpointDomainKey;
    extern CFStringRef kLockdownColorSyncProfileKey;
    extern CFStringRef kLockdownDBVersionKey;
    extern CFStringRef kLockdownFamilyIDKey;
    extern CFStringRef kLockdownSupportsCarrierBundleInstallKey;
    extern CFStringRef kLockdownMinimumiTunesVersionKey;
    extern CFStringRef kLockdownSupportsAccessibilityKey;
    extern CFStringRef kLockdownAccessibilityLanguagesKey;
    //extern CFStringRef kLockownSQLMusicLibraryPostProcessCommandsDomainKey;
    extern CFStringRef kLockdownDiskUsageDomainKey;
    extern CFStringRef kLockdownNANDInfoKey;
    extern CFStringRef kLockdownTotalDiskCapacityKey;
    extern CFStringRef kLockdownTotalSystemCapacityKey;
    extern CFStringRef kLockdownTotalSystemAvailableKey;
    extern CFStringRef kLockdownTotalDataCapacityKey;
    extern CFStringRef kLockdownTotalDataAvailableKey;
    extern CFStringRef kLockdownAmountDataReservedKey;
    extern CFStringRef kLockdownAmountDataAvailableKey;
    extern CFStringRef kLockdownPhotoUsageKey;
    extern CFStringRef kLockdownCameraUsageKey;
    extern CFStringRef kLockdownCalendarUsageKey;
    extern CFStringRef kLockdownVoicemailUsageKey;
    extern CFStringRef kLockdownNotesUsageKey;
    extern CFStringRef kLockdownMediaCacheUsageKey;
    extern CFStringRef kLockdownWebAppCacheUsageKey;
    //extern CFStringRef kLockdownAmountCameraReservedKey;
    //extern CFStringRef kLockdownAmountCameraAvailableKey;
    //extern CFStringRef kLockdownAmountCameraUsageChangedKey;
    //extern CFStringRef kLockdownAmountSongsReservedKey;
    extern CFStringRef kLockdownMobileApplicationUsageKey;
    extern CFStringRef kLockdownBatteryIsCharging;
    extern CFStringRef kLockdownBatteryCurrentCapacity;
    extern CFStringRef kLockdownInternationalDomainKey;
    extern CFStringRef kLockdownLanguageKey;
    extern CFStringRef kLockdownKeyboardKey;
    extern CFStringRef kLockdownLocaleKey;
    extern CFStringRef kLockdownSupportedLanguagesKey;
    extern CFStringRef kLockdownSupportedLocalesKey;
    extern CFStringRef kLockdownSupportedKeyboardsKey;
    extern CFStringRef kLockdownFairPlayDomainKey;
    extern CFStringRef kLockdownRentalBagRequestKey;
    extern CFStringRef kLockdownRentalBagResponseKey;
    extern CFStringRef kLockdownRentalBagRequestVersionKey;
    extern CFStringRef kLockdownRentalCheckinAckRequestKey;
    extern CFStringRef kLockdownRentalCheckinAckResponseKey;
    extern CFStringRef kLockdownTimeIntervalSince1970Key;
    extern CFStringRef kLockdownTimeZoneKey;
    extern CFStringRef kLockdownTimeZoneOffsetFromUTCKey;
    extern CFStringRef kLockdownSomebodySetTimeZoneKey;
    extern CFStringRef kLockdownUses24HourClockKey;
    extern CFStringRef kLockdownDataSyncDomainKey;
    extern CFStringRef kLockdownSyncDataClassDomainKey;
    extern CFStringRef kLockdownDeviceHandlesDefaultCalendar;
    extern CFStringRef kLockdownSyncSupportsCalDAV;
    extern CFStringRef kLockdownSupportsEncryptedBackups;
    extern CFStringRef kLockdownBackupDomainKey;
    extern CFStringRef kLockdownBackupWillEncrypt;
    extern CFStringRef kLockdownRestrictionDomainKey;
    extern CFStringRef kLockdownProhibitAppInstallKey;
    extern CFStringRef kLockdownDebugDomainKey;
    extern CFStringRef kLockdownEnableVPNLogsKey;
    extern CFStringRef kLockdownEnable8021XLogsKey;
    extern CFStringRef kLockdownEnableWiFiManagerLogsKey;
    extern CFStringRef kLockdownEnableLockdownLogToDiskKey;
    extern CFStringRef kLockdownEnableLockdownExtendedLoggingKey;
    extern CFStringRef kLockdownRemoveVPNLogs;
    extern CFStringRef kLockdownRemove8021XLogs;
    extern CFStringRef kLockdownRemoveLockdownLog;
    extern CFStringRef kLockdownRemoveWiFiManagerLogs;
    extern CFStringRef kLockdownPrefApplicationID;
    extern CFStringRef kLockdownLogToDiskPrefKey;
    extern CFStringRef kLockdownExtendedLoggingPrefKey;
    extern CFStringRef kLockdownUserPreferencesDomainKey;
    extern CFStringRef kLockdownUserSetLanguageKey;
    extern CFStringRef kLockdownUserSetLocaleKey;
    extern CFStringRef kLockdownDiagnosticsAllowedKey;
    extern CFStringRef kLockdownIQAgentApplicationID;
    extern CFStringRef kLockdownMobileApplicationUsageMapDomain;
    //extern CFStringRef kLockdownThirdPartyTerminationMapDomain;
    extern CFStringRef kLockdownInternalDomainKey;
    extern CFStringRef kLockdownVoidWarrantyKey;
    extern CFStringRef kLockdownIsInternalKey;
    extern CFStringRef kLockdownPasswordProtectedKey;
    extern CFStringRef kLockdownActivationStateAcknowledgedKey;
    
    CFStringRef keys[] =
    {
        kLockdownProtocolVersion,
        kLockdownHardwareModelKey,
        kLockdownProtocolVersionKey,
        kLockdownDeviceClassKey,
        kLockdownUniqueDeviceIDKey,
        kLockdownInverseDeviceIDKey,
        kLockdownDeviceNameKey,
        kLockdownActivationStateKey,
        kLockdownReservedBytesKey,
        kLockdownBuildVersionKey,
        kLockdownProductVersionKey,
        kLockdownReleaseTypeKey,
        kLockdownProductTypeKey,
        kLockdownSerialNumberKey,
        kLockdownMLBSerialNumberKey,
        kLockdownUniqueChipIDKey,
        kLockdownModelNumberKey,
        kLockdownRegionInfoKey,
        kLockdownIMEIKey,
        kLockdownIMSIKey,
        kLockdownICCIDKey,
        kLockdownSIMGID1Key,
        kLockdownSIMGID2Key,
        kLockdownBasebandThumbprintKey,
        kLockdownUnlockCodeKey,
        kLockdownActivationTicketKey,
        kLockdownWildcardTicketKey,
        kLockdownProposedTicketKey,
        kLockdownSIMStatusKey,
        kLockdownPhoneNumberKey,
        kLockdownBasebandVersionKey,
        kLockdownBasebandBootloaderVersionKey,
        kLockdownFirmwareVersionKey,
        kLockdownCPUArchitectureKey,
        kLockdownBasebandMasterKeyHashKey,
        kLockdownSoftwareBehaviorKey,
        kLockdownWifiAddressKey,
        kLockdownBluetoothAddressKey,
        kLockdownDeviceCertificateKey,
        kLockdownDevicePublicKey,
        kLockdownDevicePrivateKey,
        kLockdownActivationPrivateKey,
        kLockdownActivationPublicKey,
        kLockdownDebugDockPresentKey,
        kLockdowniTunesHasConnectedKey,
        kLockdownBrickStateKey,
        kLockdownActivationInfoKey,
        kLockdownActivationRandomnessKey,
        kLockdownActivationInfoCompleteKey,
        kLockdownActivationInfoErrorsKey,
        kLockdownFairPlayKeyDataKey,
        kLockdownFairPlayIDKey,
        kLockdownFairPlayGUIDKey,
        kLockdownFairPlayCertificateKey,
        kLockdownFairPlayContextIDKey,
        kLockdownFairPlayRentalClockBias,
        kLockdownHostAttachedKey,
        kLockdownTrustedHostAttachedKey,
        kLockdownCarrierBundleInfoKey,
        kLockdownProductionSOCKey,
        kLockdownNVRAMKey,
        kLockdownSoftwareBehaviorDomainKey,
        kLockdownBehaviorsValidKey,
        kLockdownGoogleMailKey,
        kLockdownVolumeLimitKey,
        kLockdownShutterClickKey,
        kLockdownNTSCKey,
        kLockdownNoWiFiKey,
        kLockdownChinaBrickKey,
        kLockdownStoreDomainKey,
        kLockdownDSPersonIDKey,
        kLockdownCheckpointDomainKey,
        kLockdownColorSyncProfileKey,
        kLockdownDBVersionKey,
        kLockdownFamilyIDKey,
        kLockdownSupportsCarrierBundleInstallKey,
        kLockdownMinimumiTunesVersionKey,
        kLockdownSupportsAccessibilityKey,
        kLockdownAccessibilityLanguagesKey,
//        kLockownSQLMusicLibraryPostProcessCommandsDomainKey,
        kLockdownDiskUsageDomainKey,
        kLockdownNANDInfoKey,
        kLockdownTotalDiskCapacityKey,
        kLockdownTotalSystemCapacityKey,
        kLockdownTotalSystemAvailableKey,
        kLockdownTotalDataCapacityKey,
        kLockdownTotalDataAvailableKey,
        kLockdownAmountDataReservedKey,
        kLockdownAmountDataAvailableKey,
        kLockdownPhotoUsageKey,
        kLockdownCameraUsageKey,
        kLockdownCalendarUsageKey,
        kLockdownVoicemailUsageKey,
        kLockdownNotesUsageKey,
        kLockdownMediaCacheUsageKey,
        kLockdownWebAppCacheUsageKey,
//        kLockdownAmountCameraReservedKey,
//        kLockdownAmountCameraAvailableKey,
//        kLockdownAmountCameraUsageChangedKey,
//        kLockdownAmountSongsReservedKey,
        kLockdownMobileApplicationUsageKey,
        kLockdownBatteryIsCharging,
        kLockdownBatteryCurrentCapacity,
        kLockdownInternationalDomainKey,
        kLockdownLanguageKey,
        kLockdownKeyboardKey,
        kLockdownLocaleKey,
        kLockdownSupportedLanguagesKey,
        kLockdownSupportedLocalesKey,
        kLockdownSupportedKeyboardsKey,
        kLockdownFairPlayDomainKey,
        kLockdownRentalBagRequestKey,
        kLockdownRentalBagResponseKey,
        kLockdownRentalBagRequestVersionKey,
        kLockdownRentalCheckinAckRequestKey,
        kLockdownRentalCheckinAckResponseKey,
        kLockdownTimeIntervalSince1970Key,
        kLockdownTimeZoneKey,
        kLockdownTimeZoneOffsetFromUTCKey,
        kLockdownSomebodySetTimeZoneKey,
        kLockdownUses24HourClockKey,
        kLockdownDataSyncDomainKey,
        kLockdownSyncDataClassDomainKey,
        kLockdownDeviceHandlesDefaultCalendar,
        kLockdownSyncSupportsCalDAV,
        kLockdownSupportsEncryptedBackups,
        kLockdownBackupDomainKey,
        kLockdownBackupWillEncrypt,
        kLockdownRestrictionDomainKey,
        kLockdownProhibitAppInstallKey,
        kLockdownDebugDomainKey,
        kLockdownEnableVPNLogsKey,
        kLockdownEnable8021XLogsKey,
        kLockdownEnableWiFiManagerLogsKey,
        kLockdownEnableLockdownLogToDiskKey,
        kLockdownEnableLockdownExtendedLoggingKey,
        kLockdownRemoveVPNLogs,
        kLockdownRemove8021XLogs,
        kLockdownRemoveLockdownLog,
        kLockdownRemoveWiFiManagerLogs,
        kLockdownPrefApplicationID,
        kLockdownLogToDiskPrefKey,
        kLockdownExtendedLoggingPrefKey,
        kLockdownUserPreferencesDomainKey,
        kLockdownUserSetLanguageKey,
        kLockdownUserSetLocaleKey,
        kLockdownDiagnosticsAllowedKey,
        kLockdownIQAgentApplicationID,
        kLockdownMobileApplicationUsageMapDomain,
//        kLockdownThirdPartyTerminationMapDomain,
        kLockdownInternalDomainKey,
        kLockdownVoidWarrantyKey,
        kLockdownIsInternalKey,
        kLockdownPasswordProtectedKey,
        kLockdownActivationStateAcknowledgedKey,
        0
    };
    
    
    id port = nil;
    if(port = lockdown_connect())
    {
        for(int i=0; keys[i]; i++)
        {
            CFStringRef key = keys[i];
            NSString *str = lockdown_copy_value(port, 0, key);	
            NSLog(@"%@ => %@", key, str);
            [str release];
        }
        lockdown_disconnect(port);
    }
}
