//
//  SendMonitorApplication.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"

@interface SendMonitorApplication : NSObject <CommandData> {
@private
    NSArray *mMonitorApplications; // MonitorApplication
}

@property (nonatomic, retain) NSArray *mMonitorApplications;

@end
