//
//  InstalledApplicationDataProvider.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"


@interface InstalledApplicationDataProvider : NSObject <DataProvider> {
 	NSArray			*mInstalledAppArray;
	NSInteger		mInstalledAppCount;
	NSInteger		mInstalledAppIndex;
}


@property (nonatomic, retain) NSArray *mInstalledAppArray;

- (BOOL) hasNext;	// DataProvider protocol
- (id) getObject;	// DataProvider protocol

- (id) commandData;

@end
