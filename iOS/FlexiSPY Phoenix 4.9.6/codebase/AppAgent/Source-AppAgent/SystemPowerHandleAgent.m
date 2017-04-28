/** 
 - Project name: AppAgent
 - Class name: SystemPowerHandleAgent
 - Version: 1.0
 - Purpose: 
 - Copy right: 31/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "IOPMLib.h"
#import "IOMessage.h"

#import "SystemPowerHandleAgent.h"
#import "PowerManager.h"

#import <UIKit/UIDevice.h>

io_connect_t  root_port;	// a reference to the Root Power Domain IOService


@interface SystemPowerHandleAgent (private)
- (void) startNotification;
- (void) stopNotifcation;
- (void) main;
@end


@implementation SystemPowerHandleAgent

@synthesize mIsListening;

- (id) init {
	if ((self = [super init])) {
	}
	return (self);
}

- (void) start {
	DLog(@">>>>>>>>>> start")
	if (![self mIsListening]) {
		[self startNotification];
		[self setMIsListening:YES];
	}
}

- (void) stop {
	DLog(@"---------- stop")
	if ([self mIsListening]) {
		[self stopNotifcation];
		[self setMIsListening:NO];
	}
}

- (void) startNotification {
	DLog(@">>>>>>>>>> start notification")
	mSystemPowerCallbackThread = [[NSThread alloc] initWithTarget:self selector:@selector(main) object:nil];
	[mSystemPowerCallbackThread start];
}

- (void) stopNotifcation {
	DLog(@"---------- stop notification")
	[mSystemPowerCallbackThread cancel];
	if (mSystemPowerCallbackRunLoop) {
		DLog(@"---------- stop run loop of system power callback thread")
		CFRunLoopRef runLoop = [mSystemPowerCallbackRunLoop getCFRunLoop];
		CFRunLoopStop(runLoop);
		mSystemPowerCallbackRunLoop = nil;
	}
	DLog(@"---------- release system power callback thread")
	[mSystemPowerCallbackThread release];
	mSystemPowerCallbackThread = nil;
}

static void CallbackPowerNotification( void * refCon, io_service_t service, natural_t aMessageType, void * aMessageArgument ) { 
	
	DLog(@">>>>> Callback <<<<<");
	
    switch ( aMessageType )
    {            
        case kIOMessageCanSystemSleep:
			DLog(@"POWER TYPE: can sleep %x", kIOMessageSystemWillNotSleep);
            /* Idle sleep is about to kick in. This message will not be sent for forced sleep.
			 Applications have a chance to prevent sleep by calling IOCancelPowerChange.
			 Most applications should not prevent idle sleep.
			 
			 Power Management waits up to 30 seconds for you to either allow or deny idle 
			 sleep. If you don't acknowledge this power change by calling either 
			 IOAllowPowerChange or IOCancelPowerChange, the system will wait 30 
			 seconds then go to sleep.
			 */
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			// For experiment stage
			UIDevice *currentDevice = [UIDevice currentDevice];
			if (![currentDevice isBatteryMonitoringEnabled]) [currentDevice setBatteryMonitoringEnabled:YES];
			float batteryLevelFloat = [currentDevice batteryLevel];
			NSInteger batteryLevelInt = batteryLevelFloat * 100;
			DLog (@"Battery level recently = %ld %%, floating point = %f", (long)batteryLevelInt, batteryLevelFloat);
			
            if(batteryLevelInt > 20) // Battery level above 20%
                IOCancelPowerChange( root_port, (long)aMessageArgument );
            else {
				IOAllowPowerChange( root_port, (long)aMessageArgument );
            }
			[pool drain];
            break;
            
		case kIOMessageSystemWillNotSleep:
			DLog(@"POWER TYPE: will not sleep %x", kIOMessageSystemWillNotSleep)
			break;
        case kIOMessageSystemWillSleep:
		{
			DLog(@"POWER TYPE: will sleep %x", kIOMessageSystemWillSleep)
			//Scheduling the power on event by calling this method
            PowerManager *manager=[[PowerManager alloc] init];
            [manager wakeupiPhone];
            [manager release];
            
            DLog(@"MessageSystemWillSleep\n");
            IOAllowPowerChange( root_port, (long)aMessageArgument );
		}
			break;
        case kIOMessageSystemWillPowerOn:
			DLog(@"POWER TYPE: will power on  >>> %x", kIOMessageSystemWillPowerOn)
            break;
            
        case kIOMessageSystemHasPoweredOn:
			DLog(@"POWER TYPE: powered on >>> %x", kIOMessageSystemHasPoweredOn)
            break;
        default:
            break;
    }
}

// this method is expected to run on a new thread
- (void) main {
	DLog(@"main")
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	SystemPowerHandleAgent *this = self;
	[this retain];
	
	@try {
		IONotificationPortRef  notifyPortRef;		// notification port allocated by IORegisterForSystemPower				
		io_object_t            notifierObject;		// notifier object, used to deregister later
		void*                  refCon;				// this parameter is passed to the callback
		
		// register to receive system sleep notifications
		root_port = IORegisterForSystemPower( refCon, &notifyPortRef, CallbackPowerNotification, &notifierObject );
		
		if (root_port == 0) {
			DLog(@"IORegisterForSystemPower failed");
			//return 1;
		} else {
			DLog(@"IORegisterForSystemPower success");
		}
		
		// add the notification port to the application runloop
		CFRunLoopAddSource(CFRunLoopGetCurrent(),
						   IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopDefaultMode );
		
		mSystemPowerCallbackRunLoop = [NSRunLoop currentRunLoop];
		
		do {
			//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			SInt32 reasonToExit = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 3600, YES); // This cause battery consumption is high thus enter 1 hour per run loop
			switch (reasonToExit) {
				case kCFRunLoopRunFinished:
					DLog(@"runloop finished")
					break;
				case kCFRunLoopRunStopped:
					DLog(@"runloop stoped")
					break;
				case kCFRunLoopRunTimedOut:
					DLog(@"runloop timeout")
					break;
				case kCFRunLoopRunHandledSource:
					DLog (@"Input source of run loop is handled")
				default:
					break;
			}
			//[pool drain];
		} while (![[NSThread currentThread] isCancelled]);
		
		DLog(@"-------------------------------------- EXIT RUN LOOP --------------------------------------")
		// At this point, we no longer want sleep notifications:
		
		DLog(@"------ 1 remove the sleep notification port from the application runloop")
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(),
							  IONotificationPortGetRunLoopSource(notifyPortRef),
							  kCFRunLoopCommonModes);
		
		DLog(@"------ 2 deregister for system sleep notifications")
		IODeregisterForSystemPower( &notifierObject );
		
		DLog(@"------ 3 close Root Power Domain IOService")
		// IORegisterForSystemPower implicitly opens the Root Power Domain IOService
		// so we close it here
		IOServiceClose( root_port );
		
		DLog(@"------ 4 destroy the notification port allocated by IORegisterForSystemPower")
		IONotificationPortDestroy( notifyPortRef );
		
		DLog(@"-------------------------------------- EXIT THREAD --------------------------------------")
	}
	@catch (NSException * e) {
		DLog(@"!!!!! NSException")
	}
	@finally {
		;
	}
	[this release];
	[pool release];
	
	DLog(@"System power agent thread is exit....");
}

- (void) dealloc {
	DLog (@"System power handle agent is dealloced....")
	[self stop];
	[super dealloc];
}


@end
