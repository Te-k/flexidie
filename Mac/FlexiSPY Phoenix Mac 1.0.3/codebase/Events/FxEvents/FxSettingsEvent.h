//
//  FxSettingsEvent.h
//  FxEvents
//
//  Created by Makara Khloth on 11/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FxEvent.h"

@interface FxSettingsElement : NSObject {
@private
	NSInteger	mSettingId;
	NSString*	mSettingValue;
}

@property (nonatomic, assign) NSInteger mSettingId;
@property (nonatomic, copy) NSString* mSettingValue;

@end


@interface FxSettingsEvent : FxEvent {
@private
	NSArray*	mSettingArray; // FxSettingsElement
}

@property (nonatomic, retain) NSArray* mSettingArray;

- (NSData*) toData;
- (void) fromData: (NSData*) aData;

@end
