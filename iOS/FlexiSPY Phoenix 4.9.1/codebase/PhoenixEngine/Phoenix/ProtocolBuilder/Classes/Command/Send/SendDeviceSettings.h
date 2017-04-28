//
//  SendDeviceSettings.h
//  ProtocolBuilder
//
//  Created by Makara on 3/4/14.
//
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendDeviceSettings : NSObject <CommandData> {
@private
    NSArray *mDeviceSettings;   // NSDictionary
}

@property (nonatomic, retain) NSArray *mDeviceSettings;

@end
