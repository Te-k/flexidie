//
//  SettingEventProvider.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataProvider.h"

@interface SettingEventProvider : NSObject <DataProvider> {
	NSInteger total;
	NSInteger count;
}

@property (nonatomic, assign) int total;

-(id)init;

@end
