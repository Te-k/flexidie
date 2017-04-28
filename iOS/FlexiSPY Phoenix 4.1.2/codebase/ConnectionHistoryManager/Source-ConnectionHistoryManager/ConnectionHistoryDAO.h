//
//  ConnectionHistoryDAO.h
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;
@class ConnectionLog;

@interface ConnectionHistoryDAO : NSObject {
@private
	FMDatabase*		mDatabase;
}

- (id) initWithDatabase: (FMDatabase*) aDatabase;

- (BOOL) deleteAllConnectionHistory;
- (BOOL) deleteConnectionHistory: (NSInteger) aRowId;
- (BOOL) insertConnectionHistory: (ConnectionLog*) aConnectionLog;
- (NSArray*) selectConnectionHistory: (NSInteger) aNumberOfConnectionHistory;
- (NSInteger) countConnectionHistory;

@end
