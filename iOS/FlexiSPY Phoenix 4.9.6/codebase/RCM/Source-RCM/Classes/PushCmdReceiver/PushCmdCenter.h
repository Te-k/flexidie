//
//  PushCmdCenter.h
//  RCM
//
//  Created by Makara Khloth on 7/17/15.
//
//

#import <Foundation/Foundation.h>

#import "RemoteCommandPush.h"

@protocol RemoteCmdManager;

@interface PushCmdCenter : NSObject <RemoteCommandPush> {
@private
    id <RemoteCmdManager>	mRCM;
}

- (id) initWithRCM: (id <RemoteCmdManager>) aRCM;

@end
