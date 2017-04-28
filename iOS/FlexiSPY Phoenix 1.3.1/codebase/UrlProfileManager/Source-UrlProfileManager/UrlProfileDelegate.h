//
//  UrlProfileDelegate.h
//  UrlProfileManager
//
//  Created by Makara Khloth on 7/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UrlProfileDelegate <NSObject>
@optional
- (void) deliverUrlProfileDidFinished: (NSError *) aError;
- (void) syncUrlProfileDidFinished: (NSError *) aError;
@end
