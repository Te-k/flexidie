#import "injectee-AppDelegate.h"

@interface NSObject (mach_inject_test_injector_app)
- (void)notifyInjectorReadyForInjection;
- (void)notifyInjectorSuccessfullyInjected;
@end

@implementation injectee_AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification_ {
	return;
	id injector = [NSConnection rootProxyForConnectionWithRegisteredName:@"mach_inject_test_injector_app" host:nil];
	printf("hi!!!\n");
	assert( injector );
	[injector notifyInjectorReadyForInjection];
}

- (void)notifyInjecteeSuccessfullyInjected {
	return;
	printf("OMG injected!!!\n");
	id injector = [NSConnection rootProxyForConnectionWithRegisteredName:@"mach_inject_test_injector_app" host:nil];
	assert( injector );
	[injector notifyInjectorSuccessfullyInjected];
}

@end
