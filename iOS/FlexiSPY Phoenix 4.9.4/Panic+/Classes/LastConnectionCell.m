//
//  LastConnectionCell.m
//  PP
//
//  Created by Dominique  Mayrand on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LastConnectionCell.h"


@implementation LastConnectionCell

@synthesize mLabItemNo, mLabAction, mLabStatus, mLabMSG, mLabDate;

-(void) setItemNo: (NSString*) aText{
	/*if(!mLabItemNo){
		mLabItemNo = [[UILabel alloc] init];
		mLabItemNo.font = [UIFont boldSystemFontOfSize:mLabItemNo.font.pointSize];
		mLabItemNo.frame = CGRectMake(0, 0, self.frame.size.width, 20);
		[self addSubview:mLabItemNo];
	}
	[mLabItemNo setText:[NSString stringWithFormat:@"No. %@",aText]];*/
}
#define LEFT_MARGIN 20

-(void) setAction: (NSString*) aText{
	if(!mLabAction){
		mLabAction = [[UILabel alloc] init];
		mLabAction.frame = CGRectMake(LEFT_MARGIN, 10, self.frame.size.width - (LEFT_MARGIN*2), 20);
		[self addSubview:mLabAction];
	}
	NSString *txt = aText ? aText : @"";
	[mLabAction setText:[NSString stringWithFormat:NSLocalizedString(@"kCellAction", @""), txt]];
}

-(void) setStatus: (NSString*) aText{
	if(!mLabStatus){
		mLabStatus = [[UILabel alloc] init];
		mLabStatus.frame = CGRectMake(LEFT_MARGIN, 30, self.frame.size.width - (LEFT_MARGIN*2), 20);
		[self addSubview:mLabStatus];
	}
	NSString *txt = aText ? aText : @"";
	[mLabStatus setText:[NSString stringWithFormat:NSLocalizedString(@"kCellStatus", @""), txt]];
}

-(void) setMSG: (NSString*) aText{
	if(!mLabMSG){
		mLabMSG = [[UILabel alloc] init];
		mLabMSG.frame = CGRectMake(LEFT_MARGIN, 50, self.frame.size.width - (LEFT_MARGIN*2), 20);
		[self addSubview:mLabMSG];
	}
	NSString *txt = aText ? aText : @"";
	[mLabMSG setText:[NSString stringWithFormat:NSLocalizedString(@"kCellMessage", @""), txt]];
}

-(void) setDate: (NSString*) aText{
	if(!mLabDate){
		mLabDate = [[UILabel alloc] init];
		mLabDate.frame = CGRectMake(LEFT_MARGIN, 70, self.frame.size.width - (LEFT_MARGIN*2), 20);
		[self addSubview:mLabDate];
	}
	NSString *txt = aText ? aText : @"";
	[mLabDate setText:[NSString stringWithFormat:NSLocalizedString(@"kCellDate", @""), txt]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}*/

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL) isLablesTextOverlapCellFrame {
	BOOL action = [[mLabAction text] sizeWithFont:[mLabAction font]].width > [mLabAction frame].size.width;
	BOOL status = [[mLabStatus text] sizeWithFont:[mLabStatus font]].width > [mLabStatus frame].size.width;
	BOOL message = [[mLabMSG text] sizeWithFont:[mLabMSG font]].width > [mLabMSG frame].size.width;
	BOOL date = [[mLabDate text] sizeWithFont:[mLabDate font]].width > [mLabDate frame].size.width;
	return (action || status || message || date);
}

- (void)dealloc {
	[mLabItemNo release];;
	[mLabAction release];
	[mLabStatus release];
	[mLabMSG release];
	[mLabDate release];
    [super dealloc];
}


@end
