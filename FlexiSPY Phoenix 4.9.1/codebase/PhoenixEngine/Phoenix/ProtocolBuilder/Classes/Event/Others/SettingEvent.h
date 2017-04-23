//
//  SettingEvent.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/15/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Event.h"

@interface SettingEvent : Event {
@private
	NSArray		*mSettingIDs;
	NSArray		*mSettingValues;
}

@property (nonatomic, retain) NSArray *mSettingIDs;
@property (nonatomic, retain) NSArray *mSettingValues;

@end
