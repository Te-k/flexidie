//
//  SendNotePayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"

@class CommandMetaData, SendNote;

@interface SendNotePayloadBuilder : NSObject {

}

+ (void) buildPayloadWithCommand:(SendNote *)aCommand
					withMetaData:(CommandMetaData *)aMetaData
			 withPayloadFilePath:(NSString *)aPayloadFilePath
				   withDirective:(TransportDirective)aDirective;

@end
