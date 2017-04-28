//
//  AutoActivationUtils.m
//  AppEngine
//
//  Created by Makara Khloth on 6/10/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "AutoActivationUtils.h"
#import "AppEngineUICmd.h"
#import "ProductActivationData.h"

#import "ActivationResponse.h"
#import "ActivationManagerProtocol.h"

#import "MessagePortIPCSender.h"
#import "DefStd.h"
#import "LicenseManager.h"
#import "LicenseInfo.h"

static AutoActivationUtils *_AutoActivationUtils = nil;

@interface AutoActivationUtils (private)
- (void) notifyDelegate: (NSError *) aError;
@end

@implementation AutoActivationUtils

@synthesize mActivationManager;
@synthesize mLicenseManager;
@synthesize mDelegate, mSelector;

+ (id) sharedAutoActivationUtils {
	if (_AutoActivationUtils == nil) {
		_AutoActivationUtils = [[AutoActivationUtils alloc] init];
	}
	return (_AutoActivationUtils);
}

- (void) requestActivate {
	DLog (@"Request activation.....");
	[mActivationManager requestActivate:self];
}

- (void) onComplete:(ActivationResponse *)aActivationResponse {
	DLog (@"Request activation complete success = %d", [aActivationResponse isMSuccess]);
    NSError *error = nil;
    
	if (![aActivationResponse isMSuccess]) {
		[self performSelector:@selector(requestActivate) withObject:nil afterDelay:60];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aActivationResponse forKey:@"Activation response"];
        error = [NSError errorWithDomain:@"USBAutoActivation error" code:[aActivationResponse mResponseCode] userInfo:userInfo];
	} else {
        DLog (@"onComplete ::");
	}
    
    [self notifyDelegate:error];
}

- (void) notifyDelegate: (NSError *) aError {
    DLog(@"aError : %@", aError);
    
    if ([self.mDelegate respondsToSelector:self.mSelector]) {
        [self.mDelegate performSelector:self.mSelector withObject:aError];
    }
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (void) dealloc {
	_AutoActivationUtils = nil;
	[super dealloc];
}

@end
