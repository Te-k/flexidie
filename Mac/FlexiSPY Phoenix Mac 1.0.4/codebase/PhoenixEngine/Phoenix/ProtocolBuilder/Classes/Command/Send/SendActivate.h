//
//  SendActivate.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendActivate : NSObject <CommandData> {
	NSString *deviceInfo;
	NSString *deviceModel;
}

@property (nonatomic, retain) NSString *deviceInfo;
@property (nonatomic, retain) NSString *deviceModel;
@end
