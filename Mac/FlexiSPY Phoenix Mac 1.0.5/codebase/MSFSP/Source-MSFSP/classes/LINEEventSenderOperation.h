//
//  LineEventSenderOperation.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 4/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FxIMEvent;


@interface LINEEventSenderOperation : NSOperation {
@private 
	FxIMEvent	*mIMEvent;
}

- (id) initWithIMEvent: (FxIMEvent *) aIMEvent;

@end
