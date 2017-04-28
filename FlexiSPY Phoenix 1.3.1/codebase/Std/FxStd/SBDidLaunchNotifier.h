//
//  SBDidLaunchNotifier.h
//  FxStd
//
//  Created by Makara Khloth on 1/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SBDidLaunchNotifier : NSObject {
@private
	id	mDelegate;
	SEL mSelector;
}

@property (nonatomic, assign) id mDelegate;
@property (nonatomic, assign) SEL mSelector;

- (void) start;
- (void) stop;

@end
