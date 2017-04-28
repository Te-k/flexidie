//
//  ResumeRequest.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "RequestTypeEnum.h"
#import "CommandDelegate.h"

@class SessionInfo;

@interface ResumeRequest : Request {
	id<CommandDelegate> delegate;
	SessionInfo *session;
}

@property (nonatomic, retain) id<CommandDelegate> delegate; 
@property (nonatomic, retain) SessionInfo *session;

- (RequestType) getRequestType;

@end
