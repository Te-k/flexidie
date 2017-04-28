//
//  ConnectionHistoryManagerImp.h
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConnectionHistoryManager.h"
#import "ConnectionHistory.h"

@class ConnectionHistoryDatabase;

@interface ConnectionHistoryManagerImp : NSObject <ConnectionHistoryManager, ConnectionHistory> {
@private
	ConnectionHistoryDatabase*	mConnectionHistoryDatabase;
	
	NSInteger	mMaxConnectionCount;
    NSInteger   mMaxServerStatusCount;
}

@property (nonatomic, assign) NSInteger mMaxConnectionCount;
@property (nonatomic, assign) NSInteger mMaxServerStatusCount;

@end
