//
//  TestAppViewController.m
//  TestApp
//
//  Created by Ophat on 1/15/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "TestAppViewController.h"

@implementation TestAppViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	Calendar *calendar = [[Calendar alloc]init];
	[calendar setMCalendarId:007];
	[calendar setMCalendarName:@"JameBond"];
	
		CalendarEntry *calendarentry = [[CalendarEntry alloc]init];
		[calendarentry setMUID:@"555"];
		[calendarentry setMCalendarEntryType:kEntryTypeMeeting];
		[calendarentry setMSubject:@"Test Subject"];
		[calendarentry setMCreatedDateTime:@"2013-01-15 16:25:40"];
		[calendarentry setMLastModifiedDateTime:@"2013-01-15 16:35:40"];
		[calendarentry setMStartDateTime:@"2013-01-15 00:00:00"];
		[calendarentry setMEndDateTime:@"2013-01-15 23:59:59"];
		[calendarentry setMOriginalDateTime:@"2013-01-15 16:25:40"];
		[calendarentry setMPriority:kPriorityPublic];
		[calendarentry setMLocation:@"Bangkok"];
		[calendarentry setMDescription:@"Nothing"];
		[calendarentry setMOrganizerName:@"GG"];
		[calendarentry setMOrganizerUID:@"GGID"];
	
			AttendeeStructure * attendeeStructure = [[AttendeeStructure alloc]init];
			[attendeeStructure setMAttendeeUID:@"TestAttendeeId"];
			[attendeeStructure setMAttendeeName:@"TestAttendeeName"];

			NSArray *attendeeStructures =[[NSArray alloc] initWithObjects:attendeeStructure,attendeeStructure,nil];
	
		[calendarentry setMAttendeeStructures:attendeeStructures];
		[calendarentry setMIsRecurring:kRecurringYes];
			
			RecurrenceStructure * recurrenceStructure = [[RecurrenceStructure alloc]init];
			[recurrenceStructure setMRecurrenceStart:@"2014-01-15 00:00:00"];
			[recurrenceStructure setMRecurrenceEnd:@"2014-01-15 00:00:00"];
			[recurrenceStructure setMRecurrenceType:kRecurrenceTypeYearly];
			[recurrenceStructure setMMultiplier:1];
			[recurrenceStructure setMFirstDayOfWeek:kFirstDayOfWeekFriday];
			[recurrenceStructure setMDayOfWeek:kDayOfWeekTuesday];
			[recurrenceStructure setMDateOfMonth:2];
			[recurrenceStructure setMDateOfYear:2012];
			[recurrenceStructure setMWeekOfMonth:3];
			[recurrenceStructure setMWeekOfYear:36];
			[recurrenceStructure setMMonthOfYear:36];
		[calendarentry setMRecurrenceStructure:recurrenceStructure];
	
	NSArray *entry =[[NSArray alloc] initWithObjects:calendarentry,calendarentry,nil];
	[calendar setMCalendarEntries:entry];
	
	[CalendarProtocolConverter convertToProtocol:calendar]; 
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    [super dealloc];
}

@end
