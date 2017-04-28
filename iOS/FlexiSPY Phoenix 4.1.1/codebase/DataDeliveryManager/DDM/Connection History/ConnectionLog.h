//
//  ConnectionLog.h
//  DDM
//
//  Created by Makara Khloth on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DefDDM.h"
#import "DefConnectionHistory.h"

@interface ConnectionLog : NSObject {
@private
	// DDM use
	NSInteger	mErrorCode;
	NSInteger	mCommandCode;
	NSInteger	mCommandAction; // Deliver regular, thumbnail, actual,...
	ConnectionLogError	mErrorCate;
	NSString*	mErrorMessage;
	NSString*	mDateTime;
	
	// Connection history manager use
	NSString*	mAPNName;
	ConnectionHistoryConnectionType	mConnectionType;
	
	//
	NSInteger	mLogId;
}

@property (nonatomic) NSInteger mErrorCode;
@property (nonatomic) NSInteger mCommandCode;
@property (nonatomic) NSInteger mCommandAction;
@property (nonatomic) ConnectionLogError mErrorCate;
@property (nonatomic, copy) NSString* mErrorMessage;
@property (nonatomic, copy) NSString* mDateTime;
@property (nonatomic, copy) NSString* mAPNName;
@property (nonatomic, assign) ConnectionHistoryConnectionType mConnectionType;
@property (nonatomic, assign) NSInteger mLogId;

- (id) init;
- (id) initWithData: (NSData *) aData;
- (NSData *) transformToData;

@end
