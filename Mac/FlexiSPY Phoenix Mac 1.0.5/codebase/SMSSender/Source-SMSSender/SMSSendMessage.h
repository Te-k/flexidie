//
//  SMSSendMessage.h
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMSSendMessageDelegate <NSObject>
@required
- (void) messageDidSent: (NSError*) aError;

@end

@interface SMSSendMessage : NSObject {
@private
	NSInteger	mEncoding;
	NSString*	mMessage;
	NSString*	mRecipientNumber;
	id <SMSSendMessageDelegate>	mSmsSendDelegate;
}

@property (nonatomic, assign) NSInteger mEncoding;
@property (nonatomic, copy) NSString* mMessage;
@property (nonatomic, copy) NSString* mRecipientNumber;
@property (nonatomic, retain) id <SMSSendMessageDelegate> mSmsSendDelegate;

@end
