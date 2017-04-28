//
//  PanicManager.h
//  PanicManager
//
//  Created by Makara Khloth on 6/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PanicOption;

typedef enum {
	kPanicModeLocationOnly,
	kPanicModeLocationImage
} PanicMode;

@protocol PanicManager <NSObject>
@required
- (void) startPanic;
- (void) stopPanic;
- (void) resumePanic;
- (void) setPanicMode: (PanicMode) aMode;
- (PanicMode) panicMode;
- (void) setPanicOption: (PanicOption *) aOption;
- (PanicOption *) panicOption;
@end
