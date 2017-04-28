//
//  RemoteCommandPush.h
//  PushNotificationManager
//
//  Created by Makara Khloth on 7/17/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

@protocol RemoteCommandPush <NSObject>

- (void) remoteCommandPushRecieved: (id) aPushCommand;

@end
