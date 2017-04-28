#import "AppDelegate.h"
#include "mach_inject_bundle/mach_inject_bundle.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	printf("lol\n");
	mach_error_t err = mach_inject_bundle_pid( [[[NSBundle mainBundle] pathForResource:@"mach_inject_sandbox_bundle"
																				ofType:@"bundle"] fileSystemRepresentation],
											   getpid() );
	assert( !err );
}

@end
