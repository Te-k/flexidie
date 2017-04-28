//
//  SendInstalledApplication.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "DataProvider.h"

@interface SendInstalledApplication : NSObject <CommandData> {
	id <DataProvider>	mInstalledAppsProvider;
	NSInteger			mInstalledAppsCount;
}

@property (nonatomic, retain) id <DataProvider> mInstalledAppsProvider;
@property (nonatomic, assign) NSInteger mInstalledAppsCount;

@end
