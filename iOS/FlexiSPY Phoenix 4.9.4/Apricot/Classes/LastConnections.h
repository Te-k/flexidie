//
//  LastConnections.h
//  Apricot
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface LastConnectionItem : NSObject{
	NSString* mLabItemNo;
	NSString* mLabAction;
	NSString* mLabStatus;
	NSString* mLabMSG;
	NSString* mLabDate;
}

@property (nonatomic, retain) NSString* mLabItemNo;
@property (nonatomic, retain) NSString* mLabAction;
@property (nonatomic, retain) NSString* mLabStatus;
@property (nonatomic, retain) NSString* mLabMSG;
@property (nonatomic, retain) NSString* mLabDate;

-(id) initWithValues: (NSString*)aLabItemNo: (NSString*)aLabAction: (NSString*)aLabStatus: (NSString*)aLabMSG: (NSString*)aLabDate;

@end

@interface LastConnections : UIViewController <UITableViewDelegate, UITableViewDataSource, AppUIConnectionDelegate> {
	UITableView* mTableView;
	NSMutableArray* mArray;
}

@property (nonatomic, retain) IBOutlet UITableView* mTableView;
@property (nonatomic, retain) NSMutableArray* mArray;

@end
