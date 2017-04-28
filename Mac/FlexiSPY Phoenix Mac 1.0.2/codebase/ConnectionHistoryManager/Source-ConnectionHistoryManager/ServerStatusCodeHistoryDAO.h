//
//  ServerStatusCodeHistoryDAO.h
//  ConnectionHistoryManager
//
//  Created by Makara on 2/23/14.
//
//

#import <Foundation/Foundation.h>

@class FMDatabase, ConnectionLog;

@interface ServerStatusCodeHistoryDAO : NSObject {
@private
    FMDatabase*		mDatabase;
}

- (id) initWithDatabase: (FMDatabase*) aDatabase;

- (BOOL) deleteAllServerStatusHistory;
- (BOOL) deleteServerStatusHistory: (NSInteger) aRowId;
- (BOOL) insertServerStatusHistory: (ConnectionLog*) aServerStatusLog;
- (NSArray*) selectServerStatusHistory: (NSInteger) aNumberOfServerStatusHistory;
- (NSInteger) countServerStatusHistory;

@end
