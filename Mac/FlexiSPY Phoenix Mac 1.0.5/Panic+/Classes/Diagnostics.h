//
//  Diagnostics.h
//  PP
//
//  Created by Dominique  Mayrand on 12/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppUIConnection.h"

@interface Diagnostics : UIViewController<UITableViewDelegate, UITableViewDataSource, AppUIConnectionDelegate>{
	UITableView* mTableView;
	NSMutableArray* mDiagnosticItems;
}

@property (nonatomic, retain) NSMutableArray* mDiagnosticItems;
@property (nonatomic, retain) IBOutlet UITableView* mTableView;


@end
