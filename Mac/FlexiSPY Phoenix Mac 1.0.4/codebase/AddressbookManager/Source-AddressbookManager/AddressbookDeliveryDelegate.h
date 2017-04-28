//
//  AddressbookDeliveryDelegate.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddressbookDeliveryDelegate <NSObject>

- (void) abDeliverySucceeded: (NSNumber *) aEDPType;
- (void) abDeliveryFailed: (NSError *) aError;

@end
