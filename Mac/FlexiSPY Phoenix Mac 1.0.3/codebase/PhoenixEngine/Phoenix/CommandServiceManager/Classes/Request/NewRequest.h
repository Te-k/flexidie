//
//  NewRequest.h
//  CommandServiceManager
//
//  Created by Pichaya Srifar on 8/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"
#import "RequestTypeEnum.h"

@class CommandRequest;

/**
 @ingroup Request
 */
@interface NewRequest : Request {
	NSString *payloadFilePath;
	CommandRequest *request;
}

@property (nonatomic, retain) NSString *payloadFilePath;
@property (nonatomic, retain) CommandRequest *request;

- (RequestType) getRequestType;

@end
