//
//  SendRunningApplicationPayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendRunningApplication;

@interface SendRunningApplicationPayloadBuilder : NSObject {

}

+ (NSData *) buildPayloadWithCommand: (SendRunningApplication *) aCommand;

@end
