//
//  DatabaseViewController.h
//  MediaHistoryTestApp
//
//  Created by Benjawan Tanarattanakorn on 3/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaHistoryDatabase;


@interface DatabaseViewController : UIViewController {
@private
	MediaHistoryDatabase *mMediaHistoryDB;
}

- (IBAction) insertOnePressed: (id) aSender;
- (IBAction) insertTenPressed: (id) aSender;

@end
