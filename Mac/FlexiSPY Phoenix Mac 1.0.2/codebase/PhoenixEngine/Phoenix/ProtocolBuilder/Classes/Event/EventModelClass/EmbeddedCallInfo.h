//
//  EmbededCallInfo.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDirectionEnum.h"

@interface EmbeddedCallInfo : NSObject {
	EventDirection direction;
	uint32_t duration;
	NSString *number;
	NSString *contactName;
}
@property (nonatomic, assign) EventDirection direction;
@property (nonatomic, assign) uint32_t duration;
@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *contactName;

@end
