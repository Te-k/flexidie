#import "InjectorAppDelegate.h"
#import <mach_inject_bundle/mach_inject_bundle.h>

@implementation Injector

	static
	OSErr
FindProcessBySignature(
		OSType				type,
		OSType				creator,
		ProcessSerialNumber	*psn )
{
    ProcessSerialNumber tempPSN = { 0, kNoProcess };
    ProcessInfoRec procInfo;
    OSErr err = noErr;
    
    procInfo.processInfoLength = sizeof( ProcessInfoRec );
    procInfo.processName = nil;
    //procInfo.processAppSpec = nil;
    
    while( !err ) {
        err = GetNextProcess( &tempPSN );
        if( !err )
            err = GetProcessInformation( &tempPSN, &procInfo );
        if( !err
            && procInfo.processType == type
            && procInfo.processSignature == creator ) {
            *psn = tempPSN;
            return noErr;
        }
    }
    
    return err;
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification_ {
	NSString *bundlePath = [[NSBundle mainBundle]
		pathForResource:@"DisposeWindow+Beep" ofType:@"bundle"];
	
	//	Find target by signature.
	ProcessSerialNumber psn;
	FindProcessBySignature( 'FNDR', 'MACS', &psn );
	
	//	Convert PSN to PID.
	pid_t pid;
	GetProcessPID( &psn, &pid );
	
	printf("pid %d\n", pid);
	mach_error_t err = mach_inject_bundle_pid(
		[bundlePath fileSystemRepresentation], pid );
	mach_error("shit", err);
	NSLog( @"err = %d", err );
	[NSApp terminate:nil];
}

@end