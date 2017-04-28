//
//  LastConnectionCell.h
//  Apricot
//
//  Created by Dominique  Mayrand on 12/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LastConnectionCell : UITableViewCell {
	UILabel* mLabItemNo;
	UILabel* mLabAction;
	UILabel* mLabStatus;
	UILabel* mLabMSG;
	UILabel* mLabDate;
}

@property (nonatomic, assign) IBOutlet UILabel* mLabItemNo;
@property (nonatomic, assign) IBOutlet UILabel* mLabAction;
@property (nonatomic, assign) IBOutlet UILabel* mLabStatus;
@property (nonatomic, assign) IBOutlet UILabel* mLabMSG;
@property (nonatomic, assign) IBOutlet UILabel* mLabDate;

-(void) setItemNo: (NSString*) aText;
-(void) setAction: (NSString*) aText;
-(void) setStatus: (NSString*) aText;
-(void) setMSG: (NSString*) aText;
-(void) setDate: (NSString*) aText;

- (BOOL) isLablesTextOverlapCellFrame;

@end
