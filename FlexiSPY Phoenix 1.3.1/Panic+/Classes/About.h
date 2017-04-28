//
//  About.h
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface AboutSection : NSObject {
	NSString* mSectionName;
	NSMutableArray* mSectionRows;
}

@property(nonatomic, retain) NSString* mSectionName;
@property(nonatomic, retain) NSMutableArray* mSectionRows;

-(id)initWithName:(NSString*) aName;
-(void)addRow:(NSString*) aRowItem;
-(void)dealloc;

@end



@interface About : UIViewController <UITableViewDelegate, UITableViewDataSource, AppUIConnectionDelegate>{
	UITableView* mTableView;
	
	NSMutableArray* mSections;
}

@property(nonatomic, retain) IBOutlet UITableView* mTableView;
@property(nonatomic, retain) NSMutableArray* mSections;

@end
