//
//  SettingCell.h
//  Apricot
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

-(void) setValues:(NSString*) aName: (NSString*) aValue: (NSArray*) aSubSettings;

- (BOOL) isLablesTextOverlapCellFrame;

@end
