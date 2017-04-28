//
//  SendCalendarPayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransportDirectiveEnum.h"

@class CommandMetaData, SendCalendar;

@interface SendCalendarPayloadBuilder : NSObject {

}

+ (void) buildPayloadWithCommand:(SendCalendar *)aCommand
					withMetaData:(CommandMetaData *)aMetaData
			 withPayloadFilePath:(NSString *)aPayloadFilePath
				   withDirective:(TransportDirective)aDirective;

@end
