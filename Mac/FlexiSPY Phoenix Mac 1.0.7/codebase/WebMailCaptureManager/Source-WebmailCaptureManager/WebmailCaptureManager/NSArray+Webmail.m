//
//  NSArray+Webmail.m
//  WebmailCaptureManager
//
//  Created by Makara Khloth on 11/4/16.
//  Copyright © 2016 ophat. All rights reserved.
//

#import "NSArray+Webmail.h"

@implementation NSArray (Webmail_2ndObj)

- (id) secondObject {
    if (self.count > 1) {
        return [self objectAtIndex:1];
    } else {
        return nil;
    }
}

@end
