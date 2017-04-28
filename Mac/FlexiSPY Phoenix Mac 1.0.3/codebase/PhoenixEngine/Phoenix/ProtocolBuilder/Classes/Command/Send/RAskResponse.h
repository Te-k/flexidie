//
//  RAskResponse.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 9/20/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface RAskResponse : ResponseData {
	NSInteger numberOfBytesReceived;
}

@property (nonatomic, assign) NSInteger numberOfBytesReceived;

@end
