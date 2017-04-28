//
//  FxIMEventUtils.h
//  FxEvents
//
//  Created by Makara Khloth on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxIMEvent;

@interface FxIMEventUtils : NSObject {

}

+ (NSArray *) digestIMEvent: (FxIMEvent *) aIMEvent;

@end
