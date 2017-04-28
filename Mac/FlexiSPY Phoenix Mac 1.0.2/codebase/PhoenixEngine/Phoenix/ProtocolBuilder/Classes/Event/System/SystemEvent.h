//
//  SystemEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"
#import "SystemEventCategoriesEnum.h"
#import "Event.h"

@interface SystemEvent : Event {
	SystemEventCategories category;
	EventDirection direction;
	NSString *message;
}

@property (nonatomic, assign) SystemEventCategories category;
@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, retain) NSString *message;

@end
