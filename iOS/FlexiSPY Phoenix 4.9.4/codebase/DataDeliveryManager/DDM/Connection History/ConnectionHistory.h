//
//  ConnectionHistory.h
//  DDM
//
//  Created by Makara Khloth on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionLog;

@protocol ConnectionHistory <NSObject>
@required
- (void) connectionLogAdded: (ConnectionLog*) aConnLog;

@optional
- (void) serverStatusLogAdded: (ConnectionLog *) aServerStatusLog;

@end
