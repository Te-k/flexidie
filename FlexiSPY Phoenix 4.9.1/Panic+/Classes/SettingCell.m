//
//  SettingCell.m
//  PP
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingCell.h"


@implementation SettingCell

@synthesize mLabName, mLabValue, mSubSettings;

#define NAME_LEFT_MARGIN 5
#define NAME_RIGHT_MARGIN 20
#define VALUE_LEFT_MARGIN 20


-(void) setValues:(NSString*) aName: (NSString*) aValue: (NSArray*) aSubSettings
{
	/*if(!mLabName){
		mLabName = [[UILabel alloc] init];
		mLabName.font =  [UIFont boldSystemFontOfSize:mLabName.font.pointSize];
		mLabName.frame = CGRectMake(NAME_LEFT_MARGIN, 0, self.frame.size.width - (NAME_LEFT_MARGIN +NAME_RIGHT_MARGIN ) , 20);
		[self addSubview:mLabName];
	}
	[mLabName setText:aName];
	*/
	if(!mLabValue){
		mLabValue = [[UILabel alloc] init];
		mLabValue.frame = CGRectMake(VALUE_LEFT_MARGIN, 15, self.frame.size.width - (VALUE_LEFT_MARGIN + NAME_RIGHT_MARGIN), 20);
		[self addSubview:mLabValue];
	}
	[mLabValue setText:aValue];
	
	[self setMSubSettings:aSubSettings];
}

- (BOOL) isLablesTextOverlapCellFrame {
	return ([[mLabValue text] sizeWithFont:[mLabValue font]].width > [mLabValue frame].size.width);
}

-(void) dealloc{
	[mLabName release];
	[mLabValue release];
	[mSubSettings release];
	
	[super dealloc];
}

@end
