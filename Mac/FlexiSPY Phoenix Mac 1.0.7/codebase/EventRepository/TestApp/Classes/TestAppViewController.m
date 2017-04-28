//
//  TestAppViewController.m
//  TestApp
//
//  Created by Makara Khloth on 8/19/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TestAppViewController.h"

#import "EventRepositoryManager.h"
#import "EventQueryPriority.h"
#import "FxCallLogEvent.h"
#import "FxSystemEvent.h"
#import "FxLocationEvent.h"
#import "FxPanicEvent.h"
#import "FxSmsEvent.h"
#import "FxRecipient.h"
#import "FxMmsEvent.h"
#import "FxAttachment.h"
#import "FxEmailEvent.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxCallTag.h"
#import "FxGPSTag.h"
#import "EventCount.h"
#import "QueryCriteria.h"
#import "EventResultSet.h"
#import "EventKeys.h"
#import "RepositoryChangePolicy.h"
#import "EventRepositoryListenerDelegate.h"
#import "EventKeys.h"

@implementation TestAppViewController

@synthesize mTestResultSetButton;
@synthesize mTestInsertEventButton;
@synthesize mTestCountEventButton;
@synthesize mTestSelectThumbnailEvent;
@synthesize mTestSelectUpdateActualEvent;
@synthesize mTestSelectMediaNoThumbnailEvent;
@synthesize mTestSelectRegularEvent;
@synthesize mTestDeleteRegularEvent;
@synthesize mTestDeleteActualEvent;
@synthesize mTestRemoveEventRepositoryListener;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"viewDidLoad enter");
	EventQueryPriority* eventQueryPriority = [[EventQueryPriority alloc] init];
	mEventRepositoryManager = [[EventRepositoryManager alloc] initWithEventQueryPriority:eventQueryPriority];
	[mEventRepositoryManager openRepository];
	[mEventRepositoryManager dropRepository];
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
	NSLog(@"viewDidLoad end");
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mTestInsertEventButton release];
	[mTestCountEventButton release];
	[mTestSelectThumbnailEvent release];
	[mTestSelectUpdateActualEvent release];
	[mTestSelectMediaNoThumbnailEvent release];
	[mTestSelectRegularEvent release];
	[mTestDeleteRegularEvent release];
	[mTestDeleteActualEvent release];
	[mTestRemoveEventRepositoryListener release];
	[mEventRepositoryManager release];
	[mEventRepositoryListenerDelegate release];
    [super dealloc];
}

- (IBAction) testInsertEventButtonPressed: (id) aSender {
	NSString* const kEventDateTime  = @"11:11:11 2011-11-11";
	NSString* const kContactName    = @"Mr. Makara KHLOTH";
	NSString* const kContactNumber  = @"+66860843742";
	NSString* const kMessage = @"This is common message ; \"Pack my box with five dozen liquor jugs\"";
	
	id <EventRepository> eventRepos = mEventRepositoryManager;
	
	// Call log
	FxCallLogEvent* callLogEvent = [[FxCallLogEvent alloc] init];
	callLogEvent.dateTime = kEventDateTime;
    callLogEvent.contactName = kContactName;
    callLogEvent.contactNumber = kContactNumber;
    callLogEvent.direction = kEventDirectionIn;
    callLogEvent.duration = 399;
	
	[eventRepos insert:callLogEvent];
	[callLogEvent release];
	
	// System
	FxSystemEvent* systemEvent = [[FxSystemEvent alloc] init];
	systemEvent.dateTime = kEventDateTime;
    [systemEvent setSystemEventType:kSystemEventTypeSmsCmd];
    systemEvent.direction = kEventDirectionOut;
    [systemEvent setMessage:kMessage];
	[eventRepos insert:systemEvent];
	[systemEvent release];
	
	// Location
	FxLocationEvent* locationEvent = [[FxLocationEvent alloc] init];
    locationEvent.dateTime = kEventDateTime;
    [locationEvent setLongitude:101.2384383];
    [locationEvent setLatitude:13.3847332];
    [locationEvent setAltitude:92.23784];
    [locationEvent setHorizontalAcc:0.3493];
    [locationEvent setVerticalAcc:0.87348];
    [locationEvent setSpeed:0.63527];
    [locationEvent setHeading:11.87];
    [locationEvent setDatumId:5];
    [locationEvent setNetworkId:@"512"];
    [locationEvent setNetworkName:@"DTAC"];
    [locationEvent setCellId:12211];
    [locationEvent setCellName:@"Paiyathai"];
    [locationEvent setAreaCode:@"12342"];
    [locationEvent setCountryCode:@"53"];
    [locationEvent setCallingModule:kGPSCallingModuleCoreTrigger];
    [locationEvent setMethod:kGPSTechAssisted];
    [locationEvent setProvider:kGPSProviderUnknown];
	[eventRepos insert:locationEvent];
	[locationEvent release];
	
	// Panic
	FxPanicEvent* panicEvent = [[FxPanicEvent alloc] init];
    panicEvent.dateTime = kEventDateTime;
    [panicEvent setPanicStatus:TRUE];
	[eventRepos insert:panicEvent];
	[panicEvent release];
	
	// Sms
	FxSmsEvent* smsEvent = [[FxSmsEvent alloc] init];
    [smsEvent setDateTime:kEventDateTime];
    [smsEvent setDirection:kEventDirectionOut];
    [smsEvent setSenderNumber:@"+85511773337"];
    [smsEvent setContactName:@"Mr. A and MR M'c B"];
    [smsEvent setSmsSubject:@"Hello B, introduction"];
    [smsEvent setSmsData: @"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General 'Public License', and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    FxRecipient* recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [smsEvent addRecipient:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [smsEvent addRecipient:recipient];
    [recipient release];
	[eventRepos insert:smsEvent];
	[smsEvent release];
	
	// Mms
	FxMmsEvent* mmsEvent = [[FxMmsEvent alloc] init];
    [mmsEvent setDateTime:kEventDateTime];
    [mmsEvent setDirection:kEventDirectionOut];
    [mmsEvent setSenderNumber:@"08608563286"];
    [mmsEvent setSenderContactName:@"Mr. A and MR M'c B"];
    [mmsEvent setSubject:@"Hello B, introduction"];
    [mmsEvent setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    
    FxAttachment* attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [mmsEvent addAttachment:attachment];
    [attachment release];
	attachment = [[FxAttachment alloc] init];
	[attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.jpg"];
    [mmsEvent addAttachment:attachment];
    [attachment release];
    
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [mmsEvent addRecipient:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [mmsEvent addRecipient:recipient];
    [recipient release];
	[eventRepos insert:mmsEvent];
	[mmsEvent release];
	
	// Email
	FxEmailEvent* emailEvent = [[FxEmailEvent alloc] init];
    [emailEvent setDateTime:kEventDateTime];
    [emailEvent setDirection:kEventDirectionOut];
    [emailEvent setSenderEmail:@"helloworld@apple.com"];
    [emailEvent setSenderContactName:@"Mr. A and MR M'c B"];
    [emailEvent setSubject:@"Hello B, introduction"];
    [emailEvent setMessage:@"GNU gdb 6.3.50-20050815 (Apple version gdb-1518) (Sat Feb 12 02:52:12 UTC 2011)"
     "Copyright 2004 Free Software Foundation, Inc."
     "GDB is free software, covered by the GNU General Public License, and you are"
     "welcome to change it and/or distribute copies of it under certain conditions."
     "Type \"show copying\" to see the conditions."];
    [emailEvent setHtml:FALSE];
    
    attachment = [[FxAttachment alloc] init];
    [attachment setFullPath:@"/hello/world/application/documents/Test/112112-thumbnail.gif"];
    [emailEvent addAttachment:attachment];
    [attachment release];
    
    // @todo back to test [add the same recipient object but change the value after added, and see what happen?]
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 007"];
    [recipient setRecipNumAddr:@"jame@porn.com"];
    [recipient setRecipType:kFxRecipientTO];
    [emailEvent addRecipient:recipient];
    [recipient release];
    recipient = [[FxRecipient alloc] init];
    [recipient setRecipContactName:@"Mr. Jame 069"];
    [recipient setRecipNumAddr:@"jame@pornxx.com"];
    [recipient setRecipType:kFxRecipientCC];
    [emailEvent addRecipient:recipient];
    [recipient release];
	[eventRepos insert:emailEvent];
	[emailEvent release];
	
	// Media
	MediaEvent* mediaEvent = [[MediaEvent alloc] init];
    mediaEvent.dateTime = kEventDateTime;
    [mediaEvent setFullPath:@"/Users/Makara/Projects/test/heroine.png"];
    [mediaEvent setEventType:kEventTypeCameraImage];
	
    ThumbnailEvent* thumbnail = [[ThumbnailEvent alloc] init];
	[thumbnail setEventType:kEventTypeCameraImageThumbnail];
    [thumbnail setActualSize:20008];
    [thumbnail setActualDuration:0];
    [thumbnail setFullPath:@"/Applications/UnitestApp/private/thumbnails/heroine-thumb.jpg"];
    
    [mediaEvent addThumbnailEvent:thumbnail];
    [thumbnail release];
    
    FxGPSTag* gpsTag = [[FxGPSTag alloc] init];
    [gpsTag setLatitude:93.087760];
    [gpsTag setLongitude:923.836398];
    [gpsTag setAltitude:62.98];
    [gpsTag setCellId:345];
    [gpsTag setAreaCode:@"342"];
    [gpsTag setNetworkId:@"45"];
    [gpsTag setCountryCode:@"512"];
    
    [mediaEvent setMGPSTag:gpsTag];
    [gpsTag release];
    
    FxCallTag* callTag = [[FxCallTag alloc] init];
    [callTag setDirection:(FxEventDirection)kEventDirectionOut];
    [callTag setDuration:23];
    [callTag setContactNumber:@"0873246246823"];
    [callTag setContactName:@"R. Mr'cm ""CamKh"];
    
    [mediaEvent setMCallTag:callTag];
    [callTag release];
	
	[eventRepos insert:mediaEvent];
	[mediaEvent release];
	
	// Panic image
	mediaEvent = [[MediaEvent alloc] init];
    mediaEvent.dateTime = kEventDateTime;
    [mediaEvent setFullPath:@"/Users/Makara/Projects/test/heroine.bmp"];
    [mediaEvent setEventType:kEventTypePanicImage];
	[eventRepos insert:mediaEvent];
	[mediaEvent release];
}

- (IBAction) testCountEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	NSInteger eventCount = [[eventRepos eventCount] totalEventCount];
	NSString* alertMessage = [NSString stringWithFormat:@"Total event count is: %d", eventCount];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction) testSelectThumbnailEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderNewestFirst];
	[criteria addQueryEventType:kEventTypeCameraImageThumbnail];
	[criteria addQueryEventType:kEventTypeVideoThumbnail];
	[criteria addQueryEventType:kEventTypeAudioThumbnail];
	EventResultSet* eventResultSet = [eventRepos mediaThumbnailEvents:criteria];
	NSArray* cameraImageThumbnailArray = [eventResultSet events:kEventTypeCameraImageThumbnail];
	NSString* alertMessage = [NSString stringWithFormat:@"Total camera image thumbnail event count is: %d", [cameraImageThumbnailArray count]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[criteria release];
}

- (IBAction) testSelectUpdateActualEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderNewestFirst];
	[criteria addQueryEventType:kEventTypeCameraImageThumbnail];
	[criteria addQueryEventType:kEventTypeVideoThumbnail];
	[criteria addQueryEventType:kEventTypeAudioThumbnail];
	EventResultSet* eventResultSet = [eventRepos mediaThumbnailEvents:criteria];
	NSArray* cameraImageThumbnailArray = [eventResultSet events:kEventTypeCameraImageThumbnail];
	if ([cameraImageThumbnailArray count]) {
		MediaEvent* mediaEvent = [cameraImageThumbnailArray objectAtIndex:0];
		ThumbnailEvent* thumbnailEvent = [[mediaEvent thumbnailEvents] objectAtIndex:0];
		MediaEvent* tmpMedia = (MediaEvent*)[eventRepos actualMedia:[thumbnailEvent pairId]];
		[eventRepos updateMediaThumbnailStatus:[thumbnailEvent pairId] withStatus:TRUE];
		NSString* alertMessage = [NSString stringWithString:@"Total camera image deliver status updated"];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[criteria release];
}

- (IBAction) testSelectMediaNoThumbnailEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderOldestFirst];
	[criteria addQueryEventType:kEventTypePanicImage];
	EventResultSet* eventResultSet = [eventRepos mediaNoThumbnailEvents:criteria];
	NSArray* eventArray = [eventResultSet events:kEventTypePanicImage];
	NSString* alertMessage = [NSString stringWithFormat:@"Total panic image event count is: %d", [eventArray count]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[criteria release];
}

- (IBAction) testSelectRegularEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderOldestFirst];
	[criteria addQueryEventType:kEventTypeCallLog];
	[criteria addQueryEventType:kEventTypeSms];
	[criteria addQueryEventType:kEventTypeMms];
	[criteria addQueryEventType:kEventTypeMail];
	[criteria addQueryEventType:kEventTypePanic];
	[criteria addQueryEventType:kEventTypeSystem];
	[criteria addQueryEventType:kEventTypeLocation];
	EventResultSet* eventResultSet = [eventRepos regularEvents:criteria];
	NSArray* eventArray = [eventResultSet events:kEventTypePanic];
	NSString* alertMessage = [NSString stringWithFormat:@"Total panic event count is: %d", [eventArray count]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[criteria release];
}

- (IBAction) testDeleteRegularEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderOldestFirst];
	[criteria addQueryEventType:kEventTypeCallLog];
	[criteria addQueryEventType:kEventTypeSms];
	[criteria addQueryEventType:kEventTypeMms];
	[criteria addQueryEventType:kEventTypeMail];
	[criteria addQueryEventType:kEventTypePanic];
	[criteria addQueryEventType:kEventTypeSystem];
	[criteria addQueryEventType:kEventTypeLocation];
	EventResultSet* eventResultSet = [eventRepos regularEvents:criteria];
	EventKeys* eventKeys = [eventResultSet shrink];
	[eventRepos deleteEvent:eventKeys];
	NSString* alertMessage = [NSString stringWithFormat:@"Total panic event deleted is: %d", [[eventKeys eventIdArray:kEventTypePanic] count]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	[criteria release];
}

- (IBAction) testDeleteActualEventButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	QueryCriteria* criteria = [[QueryCriteria alloc] init];
	[criteria setMMaxEvent:100];
	[criteria setMQueryOrder:kQueryOrderNewestFirst];
	[criteria addQueryEventType:kEventTypeCameraImageThumbnail];
	[criteria addQueryEventType:kEventTypeVideoThumbnail];
	[criteria addQueryEventType:kEventTypeAudioThumbnail];
	EventResultSet* eventResultSet = [eventRepos mediaThumbnailEvents:criteria];
	NSArray* cameraImageThumbnailArray = [eventResultSet events:kEventTypeCameraImageThumbnail];
	if ([cameraImageThumbnailArray count]) {
		MediaEvent* mediaEvent = [cameraImageThumbnailArray objectAtIndex:0];
		ThumbnailEvent* thumbnailEvent = [[mediaEvent thumbnailEvents] objectAtIndex:0];
		MediaEvent* tmpMedia = (MediaEvent*)[eventRepos actualMedia:[thumbnailEvent pairId]];
		[eventRepos updateMediaThumbnailStatus:[thumbnailEvent pairId] withStatus:TRUE];
		EventKeys* eventKeys = [[EventKeys alloc] init];
		[eventKeys put:[tmpMedia eventType] withEventIdArray:[NSArray arrayWithObject:[NSNumber numberWithInt:[tmpMedia eventId]]]];
		[eventRepos deleteEvent:eventKeys];
		NSString* alertMessage = [NSString stringWithFormat:@"Total camera image status updated and deleted is: %d", [[eventKeys eventIdArray:[tmpMedia eventType]] count]];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[eventKeys release];
	}
	[criteria release];
}

- (IBAction) testRemoveEventRepositoryListenerButtonPressed: (id) aSender {
	id <EventRepository> eventRepos = mEventRepositoryManager;
	[eventRepos removeRepositoryChangeListener:self];
	[eventRepos removeRepositoryChangeListener:mEventRepositoryListenerDelegate];
}

- (IBAction) testResultSetButtonPressed: (id) aSender {
	EventResultSet* resultSet = [[EventResultSet alloc] init];
	EventKeys* eventKeys = [resultSet shrink];
	[resultSet release];
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

@end
