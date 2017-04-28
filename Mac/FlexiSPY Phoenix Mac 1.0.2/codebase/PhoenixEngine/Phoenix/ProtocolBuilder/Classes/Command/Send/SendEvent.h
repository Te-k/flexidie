//
//  SendEvent.h
//  PhoenixPorting1
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "DataProvider.h"

@interface SendEvent : NSObject <CommandData>{
	id<DataProvider> eventProvider;
	int eventCount;
}

@property (nonatomic, retain) id<DataProvider> eventProvider;
@property (nonatomic, assign) int eventCount;

@end
