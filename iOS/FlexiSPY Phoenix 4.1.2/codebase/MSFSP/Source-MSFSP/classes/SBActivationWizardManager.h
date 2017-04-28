//
//  SBActivationWizardManager.h
//  MSFSP
//
//  Created by Makara Khloth on 6/11/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessagePortIPCReader.h"

@interface SBActivationWizardManager : NSObject <MessagePortIPCDelegate> {
@private
	MessagePortIPCReader	*mMessagePortReader;
	
	BOOL	mSBFinishLaunching;
}

@property (assign) BOOL mSBFinishLaunching;

+ (id) sharedSBActivationWizardManager;

- (void) _test;

@end
