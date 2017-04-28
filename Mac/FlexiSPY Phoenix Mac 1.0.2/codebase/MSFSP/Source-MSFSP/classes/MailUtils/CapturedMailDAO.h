//
//  CapturedMailDAO.h
//  MSFSP
//
//  Created by Makara Khloth on 5/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FxDatabase;

@interface CapturedMailDAO : NSObject {
@private
	FxDatabase	*mDatabase;
	NSString	*mCapturedMailDBPath;
}

@property (nonatomic, copy, readonly) NSString *mCapturedMailDBPath;

- (id) initWithDBFileName: (NSString *) aDBFileName;

- (void) insertUID: (NSUInteger) aUID remoteID: (NSString *) aRemoteID;
- (void) insertExternalID: (NSString *) aExternalID;

- (BOOL) isUIDAlreadyCapture: (NSUInteger) aUID;
- (BOOL) isRemoteIDAlreadyCapture: (NSString *) aRemoteID;
- (BOOL) isExternalIDAlreadyCapture: (NSString *) aExternalID;

@end
