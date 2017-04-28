//
//  GetConfigurationResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/1/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetConfigurationResponse : ResponseData {
	int configID;
	NSData *md5;
}

@property (nonatomic, assign) int configID;
@property (nonatomic, retain) NSData *md5;

@end
