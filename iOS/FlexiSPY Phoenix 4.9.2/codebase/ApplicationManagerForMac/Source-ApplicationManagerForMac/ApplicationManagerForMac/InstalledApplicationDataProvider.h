//
//  InstalledApplicationDataProvider.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@class InstalledAppHelper;

@interface InstalledApplicationDataProvider : NSObject <DataProvider> {
 	NSArray			*mInstalledAppArray;
	NSInteger		mInstalledAppCount;
	NSInteger		mInstalledAppIndex;
    
    InstalledAppHelper *mInstalledAppHelper;
    
    NSMetadataQuery *mQuery;
}

- (BOOL) hasNext;	// DataProvider protocol
- (id) getObject;	// DataProvider protocol

- (id) commandData;

@end
