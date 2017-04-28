//
//  main.m
//  DaemonTestApp
//
//  Created by Benjawan Tanarattanakorn on 5/24/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationClient.h"
//#import <IOKit/pwr_mgt/IOPMLib.h>
//#import <IOKit/IOMessage.h>
//#import "PowerManager.h"

//io_connect_t  root_port; // a reference to the Root Power Domain IOService
//int count;
//io_object_t notifier;
//
//
//static void CallbackPowerNotification( void * refCon, io_service_t service, natural_t aMessageType, void * aMessageArgument ) { 
//	
//	//COMMON_LOG_OPTIMIZED("%s # Preventing the device from going into a deep sleep mode ...\n"_ __func__);
//	
//    switch ( aMessageType )
//    {
//            
//        case kIOMessageCanSystemSleep:
//            /* Idle sleep is about to kick in. This message will not be sent for forced sleep.
//             Applications have a chance to prevent sleep by calling IOCancelPowerChange.
//             Most applications should not prevent idle sleep.
//             
//             Power Management waits up to 30 seconds for you to either allow or deny idle sleep.
//             If you don't acknowledge this power change by calling either IOAllowPowerChange
//             or IOCancelPowerChange, the system will wait 30 seconds then go to sleep.
//             */
//            
//            //Uncomment to cancel idle sleep
//            //IOCancelPowerChange( root_port, (long)messageArgument );
//            // we will allow idle sleep
//			//            COMMON_LOG_OPTIMIZED("%s # count = %d\n"_ __func__ _ count++);
//			//            COMMON_LOG_OPTIMIZED("%s # CanSystemSleep\n" _ __func__);
//			//            COMMON_LOG_OPTIMIZED("%s # Cancel Power Change\n" _ __func__);
//            
//            //Cancelling 10 times
//            if(count<30)
//                IOCancelPowerChange( root_port, (long)aMessageArgument );
//            else {
//                //For the 11th time allow to sleep
//                count=0;//resetting the count to 0
//                IOAllowPowerChange( root_port, (long)aMessageArgument );
//            }
//            break;
//            
//        case kIOMessageSystemWillSleep:
//        {
//            /* The system WILL go to sleep. If you do not call IOAllowPowerChange or
//             IOCancelPowerChange to acknowledge this message, sleep will 			be delayed by 30 seconds.
//             
//             NOTE: If you call IOCancelPowerChange to deny sleep it returns 			kIOReturnSuccess,
//             however the system WILL still go to sleep. */
//            
//            //Scheduling the power on event by calling this method
//            PowerManager *manager=[[PowerManager alloc] init];
//            [manager wakeupiPhone];
//            [manager release];
//            
//            printf( "MessageSystemWillSleep\n");
//            IOAllowPowerChange( root_port, (long)aMessageArgument );
//            
//        }
//            
//        case kIOMessageSystemWillPowerOn:
//			//            COMMON_LOG_OPTIMIZED("%s # SystemWillPowerOn\n" _ __func__);
//            //System has started the wake up process...
//            break;
//            
//        case kIOMessageSystemHasPoweredOn:
//			//            COMMON_LOG_OPTIMIZED("%s # SystemHasPoweredOn\n" _ __func__);
//            //System has finished waking up...
//            break;
//            
//        default:
//            break;
//    }
//}
//

#import "LocationManagerImpl.h"
#import "AppAgentManager.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
//	NSString *string = [NSString stringWithFormat:nil, 23, @""];
//	NSLog (@"string %@", string);
//	LocationClient *locClient = [[LocationClient alloc] init];
//	[locClient startCapture];
	
	/*************************************************
	  This code is for testing PowerManager 
	 *************************************************/
	/*
	IONotificationPortRef aIONotificationPortRef;
	root_port = IORegisterForSystemPower(nil, &aIONotificationPortRef, CallbackPowerNotification, &notifier);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(aIONotificationPortRef), kCFRunLoopCommonModes);
	 */
	
	
//	LocationManagerImpl *locationManager = [[LocationManagerImpl alloc] init];
//	locationManager = [[LocationManagerImpl alloc] init];
//	[locationManager setMCallingModule:kGPSCallingModulePanic];
//	[locationManager setMThreshold:60]; // One minute for interval mode
//	[locationManager setEventDelegate:nil];
//	[locationManager setMIntervalTime:60];
//	[locationManager startTracking];
	
	AppAgentManager *appAgentManager = [[AppAgentManager alloc] initWithEventDelegate:nil];
	[appAgentManager startListenSystemPowerAndWakeIphone];
	
	CFRunLoopRun();
	
	[appAgentManager stopListenSystemPowerAndWakeIphone];
	[appAgentManager release];
	
//	[locationManager stopTracking];
//	[locationManager release];
	
    [pool release];
    return retVal;
}
