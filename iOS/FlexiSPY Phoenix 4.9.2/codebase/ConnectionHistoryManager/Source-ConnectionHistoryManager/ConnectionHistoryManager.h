//
//  ConnectionHistoryManager.h
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionLog;

@protocol ConnectionHistoryManager <NSObject>
@required
- (void) addConnectionHistory: (ConnectionLog*) aConnectionLog;
- (void) clearAllConnectionHistory;
- (NSArray*) selectAllConnectionHistory;
- (NSInteger) countConnectionHistory;
- (void) setMaxConnectionHistory: (NSInteger) aMaxCount;
- (NSData *) transformAllConnectionHistoryToData;

// For other components beside DDM
- (void) addApplicationCategoryConnectionHistoryWithCmdAction: (NSInteger) aCmdAction
												  commandCode: (NSInteger) aCommandCode
													errorCode: (NSInteger) aErrorCode
												 errorMessage: (NSString *) aErrorMessage;

@optional
- (void) addServerStatusHistory: (ConnectionLog *) aServerStatusLog;
- (NSArray *) selectAllServerCodes; // Array of server status codes (NSString *) only

@end

