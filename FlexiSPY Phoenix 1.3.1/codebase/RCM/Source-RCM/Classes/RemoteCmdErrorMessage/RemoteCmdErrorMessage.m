/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdErrorMessage
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  23/11/2011, Makara KH, Vervata Co., Ltd. All rights reserved.
 */

#import "RemoteCmdErrorMessage.h"
#import "RemoteCmdExceptionCode.h"

@implementation RemoteCmdErrorMessage

/**
 - Method name:initWithDatabase
 - Purpose: This method is used to initalize the RemoteCmdDataDAO class.
 - Argument list and description: aDBPath (NSString *)
 - Return type and description: id (NSString)
 */

+(NSString *) errorMessage: (NSUInteger) aErrorCode {
	NSString *errorMsg=@"";
	switch (aErrorCode) {
		case kCmdExceptionErrorAppNotRunning:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorAppNotRunning", @"");
			break;
		case kCmdExceptionErrorNotCmdMessage:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorNotCmdMessage",@"");
			break;
		case kCmdExceptionErrorInvalidCmdFormat:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorInvalidCmdFormat", @"");
			break;
		case kCmdExceptionErrorCmdNotFoundRegistered:
			errorMsg= NSLocalizedString(@"kCmdExceptionErrorCmdNotFoundRegistered", @"");
			break;
		case kCmdExceptionErrorActivationCodeInvalid:
		    errorMsg = NSLocalizedString (@"ActivationCodeInvalid", @"");
			break;
		case kCmdExceptionErrorActivationCodeNotMatch:
			errorMsg = NSLocalizedString( @"kCmdExceptionErrorActivationCodeNotMatch", @"");
			break;
		case kCmdExceptionErrorPhoneNumberNotSpecified:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorPhoneNumberNotSpecified", @"");
			break;
		case kCmdExceptionErrorProductNotActivated:
			errorMsg = NSLocalizedString (@"kCmdExceptionErrorProductNotActivated", @"");
			break;
		case kCmdExceptionErrorUserNotAllowSmsBillableEvent:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorUserNotAllowSmsBillableEvent",@"");
			break;
		case kCmdExceptionErrorUserNotAllowGprsBillableEvent:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorUserNotAllowGprsBillableEvent",  @"");
			break;
		case kCmdExceptionErrorApnAutoRecovery:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorApnAutoRecovery", @"");
			break;
		case kCmdExceptionErrorCmdStillProcessing:
			errorMsg = NSLocalizedString( @"kCmdExceptionErrorCmdStillProcessing", @"");
			break;
		case kCmdExceptionErrorLicenseExpired:
			errorMsg = NSLocalizedString( @"kCmdExceptionErrorLicenseExpired", @"");
			break;
		case kCmdExceptionErrorInvalidNumberToMonitorList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidNumberToMonitorList", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToMonitorList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToMonitorList", @"");
			break;
		case kCmdExceptionErrorInvalidNumberToWatchList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidNumberToWatchList", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToWatchList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToWatchList", @"");
			break;
		case kCmdExceptionErrorInvalidKeywordToKeywordList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidKeywordToKeywordList", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToKeywordList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToKeywordList", @"");
			break;
		case kCmdExceptionErrorInvalidUrlToUrlList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidUrlToUrlList", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToUrlList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToUrlList", @"");
			break;
		case kCmdExceptionErrorMonitorNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorMonitorNumberExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorWatchNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorWatchNumberExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorKeywordExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorKeywordExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorConstruct:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorConstruct", @"");
			break;
		case kCmdExceptionErrorTransport:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorTransport", @"");
			break;
		case kCmdExceptionErrorServer:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorServer", @"");
			break;
		case kCmdExceptionErrorInvalidHomeNumberToHomeList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidHomeNumberToHomeList", @"");
			break;
		case kCmdExceptionErrorHomeNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorHomeNumberExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToHomeList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToHomeList", @"");
			break;
		case kCmdExceptionErrorInvalidNotificationNumber:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidNotificationNumber", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToNotificationList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToNotificationList", @"");
			break;
		case kCmdExceptionErrorNotificationNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorNotificationNumberExceedListCapacity", "");
			break;
		case kCmdExceptionErrorInvalidNumberToHomeXXXList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidNumberToHomeXXXList", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToHomeXXXList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToHomeXXXList", @"");
			break;
		case kCmdExceptionErrorHomeXXXNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorHomeXXXNumberExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorInvalidCisNumberToCisList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidCisNumberToCisList", @"");
			break;
		case kCmdExceptionErrorCisNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCisNumberExceedListCapacity", @"");
			break;
		case kCmdExceptionErrorCannotAddDuplicateToCisList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToCisList", @"");
			break;
		case kCmdExceptionErrorLicenseDisabled:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorLicenseDisabled", @"");
			break;
		case kCmdExceptionErrorInvalidNumberToEmergencyList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorInvalidNumberToEmergencyList", @"");			
			break;					
		case kCmdExceptionErrorEmergencyNumberExceedListCapacity:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorEmergencyNumberExceedListCapacity", @"");			
			break;
		case kCmdExceptionErrorCannotAddDuplicateToEmergencyList:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorCannotAddDuplicateToEmergencyList", @"");
			break;
		case kServerStatusLicenseNotFound:
		    errorMsg = NSLocalizedString ( @"kServerStatusLicenseNotFound", @"");	
			break;
		case kServerStatusLicenseAlreadyInUseByDevice:
		    errorMsg = NSLocalizedString ( @"kServerStatusLicenseAlreadyInUseByDevice", @"");	
			break;	
		case kServerStatusLicenseExpired:
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseExpired", @"");
			break;	
		case kServerStatusLicenseNotAssignedToAnyDevice:
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseNotAssignedToAnyDevice", @"");
			break;
		case kServerStatusLicenseNotAssignedToUser:	
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseNotAssignedToUser", @"");
			break;	
		case kServerStatusLicenseCorrupt:
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseCorrupt", @"");
			break;	
		case kServerStatusLicenseDisabled:
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseDisabled", @"");
			break;	
		case kServerStatusInvalidHostForLicense:
			errorMsg = NSLocalizedString ( @"kServerStatusInvalidHostForLicense", @"");
			break;	
		case kServerStatusLicenseFixedCannotReassigned:	
			errorMsg = NSLocalizedString ( @"kServerStatusLicenseFixedCannotReassigned", @"");
			break;	
		case kServerStatusProductNotCompatible:	
			errorMsg = NSLocalizedString ( @"kServerStatusProductNotCompatible", @"");
			break;	
		case kServerStatusAutoActivationNotAllowed:
			errorMsg = NSLocalizedString ( @"kServerStatusAutoActivationNotAllowed", @"");
			break;	
		case kServerStatusNoLicenseAvailableOnServer:	
			errorMsg = NSLocalizedString ( @"kServerStatusNoLicenseAvailableOnServer", @"");
			break;
		case kCmdExceptionErrorCmdCannotLockDeviceIfPanicIsActive:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorCmdCannotLockDeviceIfPanicIsActive", @"");
			break;
		case kCmdExceptionErrorCmdNotAllowToActivateOnActivatedProduct:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorCmdNotAllowToActivateOnActivatedProduct", @"");
			break;
		case kServerStatusUnspecifyError:
			errorMsg = NSLocalizedString(@"kServerStatusUnspecifyError", @"");
			break;
		case kLocationError:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorOnLocationCapture", @"");
			break;
		case kLocationServiceDisabled:
			errorMsg = NSLocalizedString ( @"kCmdExceptionErrorOnLocationCaptureLocationServiceDisabled", @"");
			break;
		case kNoHomeNumber:
			errorMsg = NSLocalizedString ( @"kNoHomeNumber", @"");
			break;
		case kPairingIDNotFound:
			errorMsg = NSLocalizedString ( @"kPairingIDNotFound", @"");
			break;
		case kOnDemandRecordFailToStart:
			errorMsg = NSLocalizedString ( @"kOnDemandRecordFailToStart", @"");
			break;
		case kOnDemandRecordNotComplete:
			errorMsg = NSLocalizedString ( @"kOnDemandRecordNotComplete", @"");
			break;
		case kOnDemandRecordCallInProgress:
			errorMsg = NSLocalizedString (@"kOnDemandRecordCallInProgress", @"");
			break;
		case kCmdExceptionErrorCmdBeingRetried:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorCmdBeingRetried", @"");
			break;
		case kCmdExceptionErrorPhoneNumberInvalid:
			errorMsg = NSLocalizedString(@"kCmdExceptionErrorPhoneNumberInvalid", @"");
			break;
	}		

	return errorMsg;
}

@end
