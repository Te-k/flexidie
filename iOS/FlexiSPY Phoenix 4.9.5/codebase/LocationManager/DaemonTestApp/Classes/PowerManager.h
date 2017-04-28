//
//  PowerManager.h
//  Insomania
//
//  Created by admin on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <IOKit/pwr_mgt/IOPMLib.h>
#import "IOPMLib.h"
#import "IOPMKeys.h"


@interface PowerManager : NSObject {

}

- (void)wakeupiPhone;

//static void CallbackPowerNotification( void * refCon, io_service_t service, natural_t aMessageType, void * aMessageArgument );

@end
