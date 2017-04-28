//
//  ResponseData.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandCodeEnum.h"

@interface ResponseData : NSObject {
	unsigned int CSID;
	int extendedStatus;
	NSString *message;
	int serverID;
	int statusCode;
	CommandCode cmdEcho;
	NSMutableArray *PCCArray;
	int PCCCount;
}

@property (nonatomic, assign) unsigned int CSID;
@property (nonatomic, assign) CommandCode cmdEcho;
@property (nonatomic, assign) int extendedStatus;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) int serverID;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, retain) NSMutableArray *PCCArray;
@property (nonatomic, assign) int PCCCount;

@end
