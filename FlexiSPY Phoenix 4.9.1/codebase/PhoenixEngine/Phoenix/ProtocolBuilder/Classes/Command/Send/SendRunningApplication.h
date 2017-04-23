//
//  SendRunningApplication.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "DataProvider.h"

@interface SendRunningApplication : NSObject <CommandData> {
	id <DataProvider>	mRunningAppsProvider;
	NSInteger			mRunningAppsCount;
}

@property (nonatomic, retain) id <DataProvider> mRunningAppsProvider;
@property (nonatomic, assign) NSInteger mRunningAppsCount;

@end
