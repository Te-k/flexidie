//
//  DiagnoticCell.h
//  PP
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DiagnosticCell : UITableViewCell {
	UILabel* mLabName;
	UILabel* mLabValue;
}

@property (nonatomic, retain) UILabel* mLabName;
@property (nonatomic, retain) UILabel* mLabValue;

-(void) setValues: (NSString*) aName : (NSString*) aValue;
	

@end
