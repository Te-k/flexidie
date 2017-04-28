//
//  CallRecordManager.h
//  CallRecordManager
//
//  Created by Makara Khloth on 11/30/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventCapture.h"
#import "SocketIPCReader.h"

@protocol PreferenceManager;

@interface CallRecordManager : NSObject <EventCapture, SocketIPCDelegate> {
    id <EventDelegate> mEventDelegate;
    id <PreferenceManager> mPreferenceManager;
    
    SocketIPCReader *mSocketReader;
}

- (id) initWithPreferenceManager: (id <PreferenceManager>) aPreferenceManager;

@end
