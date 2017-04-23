//
//  CDDAO.h
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyncCD;

@interface CDDAO : NSObject {

}

+ (void) saveSyncCD: (SyncCD *) aSyncCD;
+ (SyncCD *) syncCD;

+ (void) clearSyncCD;

@end
