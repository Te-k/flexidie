//
//  RootViewController.h
//  FlexiSPY
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "AppUIConnection.h"

@interface RootViewController : UITableViewController <AppUIConnectionDelegate> {
	NSMutableArray *mMenuItems;

}

@property (nonatomic, retain) NSMutableArray *mMenuItems;


@end
