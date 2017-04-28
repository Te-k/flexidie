//
//  ConfigurationManagerImpl.h
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigurationManager.h"

@interface ConfigurationManagerImpl : NSObject <ConfigurationManager> {
@private
	NSArray*	mSupportedFeatures;
	NSArray*	mSupportedRemoteCmdCodes;	
	NSInteger	mConfigurationID;
}

@property (nonatomic, retain) NSArray* mSupportedFeatures;
@property (nonatomic, retain) NSArray* mSupportedRemoteCmdCodes;

@end
