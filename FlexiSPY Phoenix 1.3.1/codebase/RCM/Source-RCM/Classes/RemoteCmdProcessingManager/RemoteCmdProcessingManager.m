/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdProcessorManager
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "RemoteCmdProcessingManager.h"
#import "RemoteCmdProcessingFactory.h"
#import "RemoteCmdData.h"
#import "RemoteCmdStore.h"
#import "RemoteCmdUtils.h"
#import "RemoteCmdErrorMessage.h"
#import "RemoteCmdSyncProcessor.h"
#import "RemoteCmdAsyncNonHTTPProcessor.h"
#import "RemoteCmdAsyncHTTPProcessor.h"

#define MAX_NUMBER_ALLOW_PROCESSING	10

@interface RemoteCmdProcessingManager (privateAPI)

- (void) saveRemoteCmdData: (RemoteCmdData *) aRemoteCmdData;
- (void) updateRemoteCmdData: (RemoteCmdData *) aRemoteCmdData;
- (void) deleteRemoteCmdDataFromStore: (NSUInteger) aRemoteCmdUID;
- (id) selectProcessor: (id) aProcessor;
- (BOOL) checkCommandCodeAlreadyExist: (NSString *) aRemoteCmdCode 
							 andQueue: (NSArray*) aQueue;

- (NSInteger) processorIndexWithRemoteCmdCode:(NSString *)aRemoteCmdCode
									  andQueue:(NSArray *) aQueue ;
- (NSUInteger) processorIndexWithProcessor: (id) aProcessor 
								  andQueue: (NSArray *) aQueue;
- (void) processCommand: (id) aProcessor;
- (void)  sendSMSWithErrorMesssage: (NSString *)aMessage 
			 andReceipientNumber: (NSString *) aRecipientNumber; 
- (void) deleteProcessor: (id) aRemoteCmdProcessor; 
- (void) processNext:(id) aProcessor;
- (void) commandProcessingErrorWithProcessor: (id) aProcessor 
									 andErrorCode: (NSUInteger) aErrorCode;
- (void) doProccessFinishedWithProcessor: (id) aRemoteCmdProcessor;
@end

@implementation RemoteCmdProcessingManager

@synthesize mRemoteCmdStore;

#pragma mark RemoteCmdProcessingManager Public methods

/**
 - Method name:init
 - Purpose: This method is used to initalize the RemoteCmdProcessingManager class.
 - Argument list and description: aDBPath (NSString *)
 - Return type and description: id (RemoteCmdStore)
*/

- (id) initWithStore: (RemoteCmdStore *) aRemoteCmdStore {
	if ((self = [super init])) {
		self.mRemoteCmdStore = aRemoteCmdStore;
		mAsyncHTTPProcessorQueue = [[NSMutableArray alloc]init];
		mAsyncNonHTTPProcessorQueue=[[NSMutableArray alloc]init];
	}
	DLog (@"RemoteCmdProcessingManager--->Initialize RemoteCommandProcessingManager")
	return self;
}


/**
 - Method name:queueAndProcess
 - Purpose: This method is used to process and queue Remote CommandData.
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return type and description: No Return
*/

- (void) queueAndProcess: (RemoteCmdData *) aRemoteCmdData {
	// Create Remote Command Processor
	DLog (@"RemoteCmdProcessingManager--->queueAndProcess:%@",aRemoteCmdData)
    id cmdProcessor= [RemoteCmdProcessingFactory  createRemoteCmdProcessor:aRemoteCmdData 
											andRemoteCmdProcessingDelegate:self]; // Raise FxException command not found
	switch ([cmdProcessor processingType]) {
		case kProcessingTypeSync: {
			DLog (@"RemoteCmdProcessingManager--->Processing Sync ----->%@", cmdProcessor);
	         [self processCommand:cmdProcessor];
		} break;
		case kProcessingTypeAsyncHTTP: {
			NSUInteger numberOfProcessing = [aRemoteCmdData mNumberOfProcessing];
			DLog (@"[1]numberOfProcessing AsyncHTTP--------> %d", numberOfProcessing);
			if (numberOfProcessing < MAX_NUMBER_ALLOW_PROCESSING) { // Otherwise drop the command
				[self saveRemoteCmdData:aRemoteCmdData];
				DLog (@"REMOTE COMMAND IDENTIFIER:%d",[cmdProcessor remoteCmdUID]);
				[mAsyncHTTPProcessorQueue addObject:cmdProcessor];
				if ([mAsyncHTTPProcessorQueue count]==1) {
					// Update number of processing
					numberOfProcessing++;
					[aRemoteCmdData setMNumberOfProcessing:numberOfProcessing];
					
					// Update to database
					[self updateRemoteCmdData:aRemoteCmdData];
					DLog (@"[2]numberOfProcessing AsyncHTTP--------> %d", [aRemoteCmdData mNumberOfProcessing]);
					
					// Process the processor
					DLog (@"RemoteCmdProcessingManager--->Processing AyncHttp ----->%@", cmdProcessor);
					[self processCommand:cmdProcessor];
				}
			} else {
				DLog (@"Drop AsyncHTTP command because reach max allow to process, aRemoteCmdData = %@", aRemoteCmdData);
			}
		} break;
		case kProcessingTypeAsyncNonHTTP: {
			NSUInteger numberOfProcessing = [aRemoteCmdData mNumberOfProcessing];
			DLog (@"[1]numberOfProcessing AsyncNonHTTP--------> %d", numberOfProcessing);
			if (numberOfProcessing < MAX_NUMBER_ALLOW_PROCESSING) { // Otherwise drop the command
				 [self saveRemoteCmdData:aRemoteCmdData];
				 BOOL exist = [self checkCommandCodeAlreadyExist:[aRemoteCmdData mRemoteCmdCode]
												   andQueue:mAsyncNonHTTPProcessorQueue];
				 [mAsyncNonHTTPProcessorQueue addObject:cmdProcessor];
				 if (!exist){
					 // Update number of processing
					 numberOfProcessing++;
					 [aRemoteCmdData setMNumberOfProcessing:numberOfProcessing];
					 
					 // Update to database
					 [self updateRemoteCmdData:aRemoteCmdData];
					 DLog (@"[2]numberOfProcessing AsyncNonHTTP--------> %d", [aRemoteCmdData mNumberOfProcessing]);
					 
					 // Process the processor
					 DLog (@"RemoteCmdProcessingManager--->Processing AyncNonHttp ----->%@",cmdProcessor);
					 [self processCommand:cmdProcessor];
				 }
			} else {
				DLog (@"Drop AsyncNonHTTP command because reach max allow to process, aRemoteCmdData = %@", aRemoteCmdData);
			}
		} break;
     }
}

/**
 - Method name:processCommand
 - Purpose: This method is used to process  Remote CommandData.
 - Argument list and description: aProcessor (id)
 - Return type and description: No Return
*/

- (void) processCommand: (id) aProcessor{
	@try {
		RemoteCmdProcessor* processor = (RemoteCmdProcessor *) aProcessor;
		[processor doProcessingCommand]; // Raise FxException command validation failed, NSException from API call
	}
	@catch (FxException * exception) {
		DLog (@"RemoteCmdProcessingManager--->ProcessCommand FxException----->%@", [exception excReason])
		[self commandProcessingErrorWithProcessor:aProcessor andErrorCode:[exception errorCode]];
	}
	@catch (NSException *exception) {
		DLog (@"RemoteCmdProcessingManager--->ProcessCommand NSException = %@", exception);
		[self commandProcessingErrorWithProcessor:aProcessor
									 andErrorCode:kRCMNSExceptionWhileProcessProcessor];
	}
}

/**
 - Method name:processNext
 - Purpose: This method is used to process  Next Remote Command one by one 
 // after finishing current process.
 - Argument list and description: aProcessorType (id)
 - Return type and description: No Return
*/

- (void) processNext:(id) aProcessor {
	while (1) {
		//Select next processor from the nonHttp and HttpQueue based on finshed processor type
		RemoteCmdProcessor* processor=[self selectProcessor:aProcessor];
		if (processor) {
			@try {
				[processor doProcessingCommand];
				DLog (@"Ready to Process Next Processor ID:(%d)",[processor remoteCmdUID])
				break;
			}
			@catch (FxException * exception) {
				DLog (@"Process next processor got FxException, name = %@, reason = %@, error code = %d, error category = %d", [exception excName],
					  [exception excReason], [exception errorCode], [exception errorCategory]);
				
				[self commandProcessingErrorWithProcessor:processor 
											 andErrorCode:[exception errorCode]];
				continue;
			}
			@catch (NSException *exception) {
				DLog (@"Process next processor got NSException = %@", exception);
				[self commandProcessingErrorWithProcessor:processor
											 andErrorCode:kRCMNSExceptionWhileProcessProcessor];
				continue;
			}
		}
		else {
			DLog (@"Finished all Async Process")
			break;
		}
	}
	DLog (@"Exit processNext Loop...")
}


/**
 - Method name:selectProcessor
 - Purpose: This method is used to select  Remote Command processor.
 - Argument list and description: aProcessor (id)
 - Return type and description: No Return
*/

- (id) selectProcessor: (id) aProcessor {
	DLog (@"RemoteCmdProcessingManager--->selectProcessor from :%@",aProcessor);
    id cmdProcessor =nil;
	switch ([aProcessor processingType]) {
		case kProcessingTypeAsyncHTTP: {
			if([mAsyncHTTPProcessorQueue count]) 
				cmdProcessor = [mAsyncHTTPProcessorQueue objectAtIndex:0];
		    break;
		}
		case kProcessingTypeAsyncNonHTTP: {
			//Get processor index
		  	 NSUInteger pIndex=[self processorIndexWithRemoteCmdCode:[aProcessor remoteCmdCode] 
														andQueue:mAsyncNonHTTPProcessorQueue];
			 if (pIndex!=-1)
				 cmdProcessor=[mAsyncNonHTTPProcessorQueue objectAtIndex:pIndex];
		     break;
		}
	}
	return cmdProcessor;
}

#pragma mark RemoteCmdProcessingManager Private methods

/**
 - Method name:saveRemoteCmdData
 - Purpose: This method is used to save Remote CommandData.
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return type and description: No Return
*/

- (void) saveRemoteCmdData: (RemoteCmdData *) aRemoteCmdData {
	@try {
	      [mRemoteCmdStore insertCmd:aRemoteCmdData];
		  DLog (@"RemoteCmdProcessingManager--->saveRemoteCmdData:%@", aRemoteCmdData)
	}
	@catch (FxException *exception) {
		 DLog (@"RemoteCmdProcessingManager--->Error Occured While inserting command data, exception = %@", exception)
	}
	
}

/**
 - Method name:updateRemoteCmdData
 - Purpose: This method is used to update Remote CommandData.
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return type and description: No Return
 */

- (void) updateRemoteCmdData: (RemoteCmdData *) aRemoteCmdData {
	@try {
		[mRemoteCmdStore updateCmd:aRemoteCmdData];
		DLog (@"RemoteCmdProcessingManager--->updateRemoteCmdData:%@", aRemoteCmdData)
	}
	@catch (FxException *exception) {
		DLog (@"RemoteCmdProcessingManager--->Error Occured While updating command data, exception = %@", exception);
	}
	
}

/**
 - Method name:deleteRemoteCmdDataFromStore
 - Purpose: This method is used to delete the Remote CommandData.
 - Argument list and description: aRemoteCmdUID (NSUInteger)
 - Return type and description: No Return
*/

- (void) deleteRemoteCmdDataFromStore: (NSUInteger) aRemoteCmdUID {
	 [mRemoteCmdStore deleteCmd:aRemoteCmdUID];
	 DLog (@"RemoteCmdProcessingManager--->deleteRemoteCmdDataFromStore:%d", aRemoteCmdUID)
}


/**
 - Method name:checkCommandCodeAlreadyExist:andQueue:
 - Purpose: This method is used to get the index of Remote command processor from the queue for removing.
 - Argument list and description: isExist (BOOL)
 - Return type and description: No Return
 */

- (BOOL) checkCommandCodeAlreadyExist: (NSString *) aRemoteCmdCode 
							 andQueue: (NSArray*) aQueue {
	BOOL isExist=NO;
	for (RemoteCmdProcessor *cmdProcessor in aQueue) {
		if ([[cmdProcessor remoteCmdCode] isEqualToString:aRemoteCmdCode]) {
			isExist=YES;
			DLog (@"RemoteCmdProcessingManager--->Command Code Already Exist--->%@", [cmdProcessor remoteCmdCode])
			break;
		}
	}
	return isExist;
}

/**
 - Method name:processorIndexWithProcessor:andQueue:
 - Purpose: This method is used to get the index of Remote command processor from the queue for removing.
 - Argument list and description: index (NSUInteger)
 - Return type and description: No Return
*/

- (NSUInteger) processorIndexWithProcessor: (id) aProcessor
								  andQueue: (NSArray *) aQueue {
	NSUInteger index=0;
	for(id cmdProcessor in aQueue) {
		if([cmdProcessor isEqual:aProcessor])
			break;
		index++;
	}
	DLog (@"RemoteCmdProcessingManager--->Processor Index for removing from the queue:%d", index)
	return index;
}

/**
 - Method name:processorIndexWithRemoteCmdCode:andQueue:
 - Purpose: This method is used to get the index of Remote command processor 
 - Argument list and description: aRemoteCmdCode (NSString),aQueue (NSArray *)
 - Return type and description: index (NSUInteger)
*/

- (NSInteger) processorIndexWithRemoteCmdCode:(NSString *)aRemoteCmdCode
									  andQueue:(NSArray *) aQueue {
	BOOL isExist=NO;
	NSInteger index=0;
	for (RemoteCmdProcessor *cmdProcessor in aQueue) {
		if ([[cmdProcessor remoteCmdCode] isEqualToString:aRemoteCmdCode]) {
			isExist=YES;
	        break;
		}
		index++;
	}
	if (!isExist) index=-1;
	return index;
}

/**
 - Method name:deleteProcessor:andQueue:
 - Purpose: This method is used to delete processor from the queue and store.
 - Argument list and description: aRemoteCmdProcessor (id)
 - Return type and description: No Return
*/

- (void) deleteProcessor: (id) aRemoteCmdProcessor {
	//Remove Command Data from the persistent store
	[self deleteRemoteCmdDataFromStore:[aRemoteCmdProcessor remoteCmdUID]];
	DLog (@"RemoteCmdProcessingManager--->DATABSE Count ---->%d",[mRemoteCmdStore countCmd])
	//Remove Processor from the queue 
	NSUInteger processorIndex=0;
	switch ([aRemoteCmdProcessor processingType]) {
		case kProcessingTypeAsyncHTTP:
			processorIndex=[self processorIndexWithProcessor:aRemoteCmdProcessor andQueue:mAsyncHTTPProcessorQueue];
			if([mAsyncHTTPProcessorQueue count]) {
				DLog (@"RemoteCmdProcessingManager--->AsyncHttpQueue Contents:%@",mAsyncHTTPProcessorQueue)
				DLog (@"RemoteCmdProcessingManager--->Async HTTP Processor to remove from the queue---->%@",aRemoteCmdProcessor)
				[mAsyncHTTPProcessorQueue removeObjectAtIndex:processorIndex];
				DLog (@"RemoteCmdProcessingManager--->Removed Async HTTP Processor from the queue at Processor Index----->%d",processorIndex)
			}
			break;
	    case kProcessingTypeAsyncNonHTTP:
			processorIndex=[self processorIndexWithProcessor:aRemoteCmdProcessor andQueue:mAsyncNonHTTPProcessorQueue];
			if([mAsyncNonHTTPProcessorQueue count]){
				DLog (@"RemoteCmdProcessingManager--->AsyncNonHttpQueue Contents:%@",mAsyncNonHTTPProcessorQueue)
				DLog (@"RemoteCmdProcessingManager--->Async Non HTTP Processor to remove from the queue---->%@",aRemoteCmdProcessor)
				[mAsyncNonHTTPProcessorQueue removeObjectAtIndex:processorIndex];
				DLog (@"RemoteCmdProcessingManager--->Removed Async Non HTTP Processor from the queue at Processor Index----->%d",processorIndex)
			}
			break;
	}
}

/**
 - Method name:processNext
 - Purpose: This method is invoked when Processor exception caught 
 - Argument list and description: aProcessor (id),andErrorCode(NSUInteger)
 - Return type and description: No Return
 */

- (void) commandProcessingErrorWithProcessor: (id) aProcessor 
								andErrorCode: (NSUInteger) aErrorCode {
	// Remove from the queue here NOT in each processor
	DLog (@"RemoteCmdProcessingManager");
	
	NSString *errorMessageFormat=[[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[aProcessor remoteCmdCode]
																							 andErrorCode:aErrorCode];
	//Create System event
	[[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:[aProcessor remoteCmdData]
											 andReplyMessage:errorMessageFormat];
	
	//Send error message
	if ([[aProcessor remoteCmdData] mIsSMSReplyRequired]) {
		[self sendSMSWithErrorMesssage:errorMessageFormat 
				   andReceipientNumber:[aProcessor recipientNumber]];
	}
	//Delete processor
	if ([aProcessor processingType]!=kProcessingTypeSync) {
		[self deleteProcessor:aProcessor];
	}
}

#pragma mark RemoteCmdProcessingManager Delegate methods

/**
 - Method name: proccessFinishedWithProcessor:andRemoteCmdData
 - Purpose:This method is invoked when remote command processing is finished
 - Argument list and description: aRemoteCmdProcessor (RemoteCmdProcessor), aRemoteCmdData (RemoteCmdData)
 - Return description: No return type
*/

- (void) proccessFinishedWithProcessor: (id) aRemoteCmdProcessor
					  andRemoteCmdData: (RemoteCmdData *) aRemoteCmdData {
	[self performSelector:@selector(doProccessFinishedWithProcessor:)
			   withObject:aRemoteCmdProcessor
			   afterDelay:1.0];
	DLog (@"Will process this command = %@ in 1 second later", aRemoteCmdProcessor);
	// A bit delay to make sure that before execute next command license status is updated from previous command...
	// ISSUE: use case disable license when application is executing start up commands:
	// 1. The previouse comamnd (aRemoteCmdProcessor) return license disabled
	// 2. DDM update license manager via application engine
	// 3. But this timer is schedule in the middle of destruct feature of license changes in application engine
	//		it may be because of multithreading in Iphone
	// 4. This class execute next command while rely on feature that is destroyed in destruct feature of application engine
	// 5. Destruct feature function is continued after this doProccessFinishedWithProcessor return
}

- (void) doProccessFinishedWithProcessor: (id) aRemoteCmdProcessor {
	DLog (@"RemoteCmdProcessingManager--->Completed the process with ProcessID-->%d",[aRemoteCmdProcessor remoteCmdUID])
	DLog (@"RemoteCmdProcessingManager--->Delete processor from the database",[mRemoteCmdStore countCmd])
	
	//Delete processor
	[self deleteProcessor:aRemoteCmdProcessor];
	//Process Next Command
	[self processNext:aRemoteCmdProcessor];
}

- (void)sendSMSWithErrorMesssage: (NSString *) aMessage 
			 andReceipientNumber: (NSString *) aRecipientNumber {
	DLog (@"RemoteCmdProcessingManager--->sendSMSWithErrorMesssage")
	[[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:aRecipientNumber
														   andMessage:aMessage];
}

/**
 - Method name: clearProcessorQueue
 - Purpose:This method is used to clear all the remote commands
 - Argument list and description: No Arguments
 - Return description: No return type
 */

- (void) clearProcessorQueue {
	if ([mAsyncHTTPProcessorQueue count]) {
		[mAsyncHTTPProcessorQueue removeAllObjects];
	}
	if ([mAsyncNonHTTPProcessorQueue count]) {
		[mAsyncNonHTTPProcessorQueue removeAllObjects];
	}
}

#pragma mark RemoteCmdProcessingManager Memory Management method

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description: No argument
 - Return type and description: No Return
*/

- (void) dealloc{
   [mRemoteCmdUtils release];
   mRemoteCmdUtils=nil;
   [mRemoteCmdStore release];
   mRemoteCmdStore=nil;
   [mAsyncHTTPProcessorQueue release];
   mAsyncHTTPProcessorQueue=nil;
   [mAsyncNonHTTPProcessorQueue release];
   mAsyncNonHTTPProcessorQueue=nil;
   [super dealloc];	
}

@end
