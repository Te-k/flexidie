//
//  AppStateNotifier.h
//  AppScreenShotManager
//
//  Created by Makara Khloth on 1/4/17.
//  Copyright © 2017 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface AppStateNotifier : NSObject <MessagePortIPCDelegate> {
    MessagePortIPCReader *mMessagePortReader;
    
    id mDelegate;
    SEL mSelector;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startNotify;
- (void) stopNotify;

@end
