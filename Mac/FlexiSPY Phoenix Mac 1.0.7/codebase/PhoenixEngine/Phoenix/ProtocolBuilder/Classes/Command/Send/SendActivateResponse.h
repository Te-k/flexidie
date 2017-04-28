//
//  SendActivateResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"
#import "CommandCodeEnum.h"

@interface SendActivateResponse : ResponseData {
	int configID;
	NSData *md5;
}

@property (nonatomic, assign) int configID;
@property (nonatomic, retain) NSData *md5;

@end
