//
//  SendInstalledApplicationPayloadBuilder.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SendInstalledApplication;

@interface SendInstalledApplicationPayloadBuilder : NSObject {

}

+ (NSData *) buildPayloadWithCommand: (SendInstalledApplication *) aCommand;
+ (NSData *) buildPayloadWithCommandv8: (SendInstalledApplication *) aCommand;

@end
