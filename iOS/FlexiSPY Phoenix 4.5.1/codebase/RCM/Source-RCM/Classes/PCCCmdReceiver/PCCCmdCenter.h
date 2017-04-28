//
//  PCCCmdCenter.h
//  RCM
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RemoteCommandPCC.h"

@protocol RemoteCmdManager;

@interface PCCCmdCenter : NSObject <RemoteCommandPCC> {
@private
	id <RemoteCmdManager>	mRCM;
}

- (id) initWithRCM: (id <RemoteCmdManager>) aRCM;

@end
