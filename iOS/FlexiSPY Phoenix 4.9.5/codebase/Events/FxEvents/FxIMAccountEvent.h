//
//  FxIMAccountEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 1/31/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxIMEvent.h"

@interface FxIMAccountEvent : FxEvent {
@private
	FxIMServiceID	mServiceID;
	NSString		*mAccountID;
	NSString		*mDisplayName;
	NSString		*mStatusMessage;
	NSData			*mPicture;
}

@property (nonatomic, assign) FxIMServiceID mServiceID;
@property (nonatomic, copy) NSString *mAccountID;
@property (nonatomic, copy) NSString *mDisplayName;
@property (nonatomic, copy) NSString *mStatusMessage;
@property (nonatomic, retain) NSData *mPicture;

@end
