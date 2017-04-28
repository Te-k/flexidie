//
//  SettingCell.h
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SettingCell :  UITableViewCell {
	UILabel* mLabName;
	UILabel* mLabValue;
	NSArray* mSubSettings;
}

@property(nonatomic, retain) UILabel* mLabName;
@property(nonatomic, retain) UILabel* mLabValue;
@property(nonatomic, retain) NSArray* mSubSettings;

-(void) setName:(NSString*) aName value: (NSString*) aValue subSettings: (NSArray*) aSubSettings;

- (BOOL) isLablesTextOverlapCellFrame;

@end
