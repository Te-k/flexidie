#import "injector-AppDelegate.h"
#import <mach_inject_bundle/mach_inject_bundle.h>

NSTask *gInjecteeTask;

@interface NSObject (mach_inject_test_injected_bundle)
- (unsigned)testInjectedBundle;
@end

@interface mach_inject_test_injector_app : NSObject {}
- (void)notifyInjectorReadyForInjection;
@end
@implementation mach_inject_test_injector_app
- (void)notifyInjectorReadyForInjection {
	NSString *injectedBundlePath = [[NSBundle mainBundle] pathForResource:@"mach_inject_test_injected"
																   ofType:@"bundle"];
	assert( injectedBundlePath );
	
	printf("injecting pid\n");
	mach_error_t err = mach_inject_bundle_pid( [injectedBundlePath fileSystemRepresentation],
											   [gInjecteeTask processIdentifier] );
	printf("hi\n");
	assert( !err );
}
- (void)notifyInjectorSuccessfullyInjected {
	printf("successfully!\n");
	id injectedBundle = [NSConnection rootProxyForConnectionWithRegisteredName:@"mach_inject_test_injected_bundle" host:nil];	
	assert( injectedBundle );
	assert( 42 == [injectedBundle testInjectedBundle] );
	
	[gInjecteeTask terminate];
	[NSApp terminate:nil];
}
@end

@implementation injector_AppDelegate

- (void)inject:(IBOutlet)sender
{
	pid_t process_id = [pid intValue];
	printf("injecting into pid %d\n", process_id);
	NSString *injectedBundlePath = [[NSBundle mainBundle] pathForResource:@"mach_inject_test_injected"
																   ofType:@"bundle"];
	assert( injectedBundlePath );
	
	printf("injecting pid\n");
	mach_error_t err = mach_inject_bundle_pid( [injectedBundlePath fileSystemRepresentation],
											   process_id );
	printf("hi\n");
	assert( !err );
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification_ {
	return;
	NSConnection *connection = [[NSConnection defaultConnection] retain];
    [connection setRootObject:[[[mach_inject_test_injector_app alloc] init] autorelease]];
    [connection registerName:[[connection rootObject] className]];
	
	assert( ![NSConnection rootProxyForConnectionWithRegisteredName:@"mach_inject_test_injected_bundle" host:nil] );
	
	NSString *injecteeAppPath = [[NSBundle mainBundle] pathForResource:@"mach_inject_test_injectee"
																ofType:@"app"];
	assert( injecteeAppPath );
	gInjecteeTask = [NSTask launchedTaskWithLaunchPath:[injecteeAppPath stringByAppendingString:@"/Contents/MacOS/mach_inject_test_injectee"]
											 arguments:[NSArray array]];
	assert( gInjecteeTask );
}

@end
