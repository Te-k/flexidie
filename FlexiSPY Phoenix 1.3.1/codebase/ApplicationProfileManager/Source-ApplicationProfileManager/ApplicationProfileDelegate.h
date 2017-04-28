//
//  ApplicationProfileDelegate.h
//  ApplicationProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ApplicationProfileDelegate <NSObject>
@optional
- (void) deliverAppProfileDidFinished: (NSError *) aError;
- (void) syncAppProfileDidFinished: (NSError *) aError;
@end
