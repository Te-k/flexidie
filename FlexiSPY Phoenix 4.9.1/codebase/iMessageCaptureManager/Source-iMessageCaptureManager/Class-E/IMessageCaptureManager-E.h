//
//  IMessageCaptureManager.h
//  iMessageCaptureManager
//
//  Created by Makara Khloth on 2/1/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventDelegate;

@interface IMessageCaptureManager : NSObject  {
@private
	id <EventDelegate>		mEventDelegate;
}

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate;
- (void)captureiMessage;

// -- Historical iMessage

+ (NSArray *) alliMessages;
+ (NSArray *) alliMessagesWithMax: (NSInteger) aMaxNumber;
+ (void)clearCapturedData;

@end
