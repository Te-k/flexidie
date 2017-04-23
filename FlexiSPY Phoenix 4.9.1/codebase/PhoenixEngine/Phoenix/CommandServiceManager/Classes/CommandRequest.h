//
//  CommandRequest.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 7/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "CommandDelegate.h"
#import "CommandPriorityEnum.h"

@class CommandMetaData;

@interface CommandRequest : NSObject {
	id<CommandData> commandData;
	id<CommandDelegate> delegate;
	CommandMetaData *metaData;
	CommandPriority priority;
}

@property (nonatomic, retain) id<CommandData> commandData;
@property (nonatomic, retain) id<CommandDelegate> delegate;
@property (nonatomic, retain) CommandMetaData *metaData;
@property (nonatomic, assign) CommandPriority priority;

@end
