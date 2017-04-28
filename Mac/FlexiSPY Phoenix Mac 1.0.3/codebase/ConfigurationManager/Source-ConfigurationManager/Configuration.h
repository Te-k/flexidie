//
//  Configuration.h
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject {
@private
	NSInteger	mConfigurationID;
	NSArray*	mSupportedFeatures;
	NSArray*	mSupportedRemoteCmdCodes;
}

@property (nonatomic, assign) NSInteger mConfigurationID;
@property (nonatomic, retain) NSArray* mSupportedFeatures;
@property (nonatomic, retain) NSArray* mSupportedRemoteCmdCodes;

@end
