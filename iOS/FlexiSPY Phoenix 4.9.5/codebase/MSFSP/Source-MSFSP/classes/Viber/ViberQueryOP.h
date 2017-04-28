//
//  ViberQueryOP.h
//  MSFSP
//
//  Created by Makara Khloth on 8/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViberUtils;

@interface ViberQueryOP : NSOperation {
	NSArray		*mArguments;
	
	id          mDelegate;
	SEL			mSelector;
	
	NSInteger	mWaitInterval;
}

@property (retain) NSArray *mArguments;
@property (retain) id mDelegate;
@property (assign) SEL mSelector;
@property (assign) NSInteger mWaitInterval;

@end
