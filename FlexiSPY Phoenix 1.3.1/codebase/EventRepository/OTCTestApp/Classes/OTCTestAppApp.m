//
//  OTCTestAppApp.m
//  OTCTestApp
//

#import "OTCTestAppApp.h"
#import "EventRepositoryListenerDelegate.h"

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"
#import "RepositoryChangePolicy.h"

#import "FxCallLogEvent.h"
#import "EventCount.h"

@implementation OTCTestAppApp

@synthesize window;
@synthesize mainView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	NSLog(@"[applicationDidFinishLaunching] Enter");
	
	EventQueryPriority* eventQueryPriority = [[EventQueryPriority alloc] init];
	mEventRepositoryManager = [[EventRepositoryManager alloc] initWithEventQueryPriority:eventQueryPriority];
	[mEventRepositoryManager openRepository];
	mEventRepositoryListenerDelegate = [[EventRepositoryListenerDelegate alloc] init];
	NSLog(@"Constructed event repository manager");
	RepositoryChangePolicy* reposChangePolicy = [[RepositoryChangePolicy alloc] init];
	[reposChangePolicy setMMaxNumber:2];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeAddEvent];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeReachMax];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeAddSystemEvent];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeAddPanicEvent];
	[mEventRepositoryManager addRepositoryListener:self withRepositoryChangePolicy:reposChangePolicy];
	[reposChangePolicy release];
	NSLog(@"Added repository changes policy 1");
	
	reposChangePolicy = [[RepositoryChangePolicy alloc] init];
	[reposChangePolicy setMMaxNumber:1];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeAddSystemEvent];
	[reposChangePolicy addRepositoryChangeEvent:kReposChangeReachMax];
	[mEventRepositoryManager addRepositoryListener:mEventRepositoryListenerDelegate withRepositoryChangePolicy:reposChangePolicy];
	[reposChangePolicy release];
	NSLog(@"Added repository changes policy 1");
	
	[eventQueryPriority release];
	
	NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
	NSString* const kContactName    = @"Mr. Makara KHLOTH";
	NSString* const kContactNumber  = @"+66860843742";
	
	// Call log
	FxCallLogEvent* callLogEvent = [[FxCallLogEvent alloc] init];
	callLogEvent.dateTime = kEventDateTime;
    callLogEvent.contactName = kContactName;
    callLogEvent.contactNumber = kContactNumber;
    callLogEvent.direction = kEventDirectionIn;
    callLogEvent.duration = 399;
	
	[mEventRepositoryManager insert:callLogEvent];
	NSLog(@"One call log event have been added to database");
	[callLogEvent release];
	
	NSInteger eventCount = [[mEventRepositoryManager eventCount] totalEventCount];
	NSLog(@"Total event since installed is: %d", eventCount);
	
	// Create window
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
    
	// Set up content view
	mainView = [[UIView alloc] initWithFrame: [UIHardware fullScreenApplicationContentRect]];
	[window setContentView: mainView];
    
	// Show window
	[window makeKeyAndVisible];
	NSLog(@"[applicationDidFinishLaunching] End");
}


///

- (void) eventAdded: (FxEventType) aEventType {
}

- (void) panicEventAdded {
}

- (void) maxEventReached {
}

- (void) systemEventAdded {
}

- (void)dealloc {
	[mEventRepositoryListenerDelegate release];
	[mEventRepositoryManager release];
	[mainView release];
	[window release];
	[super dealloc];
}

@end
