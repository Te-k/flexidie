#import "injected-PrincipalClass.h"

@interface NSObject (mach_inject_test_injectee_app)
- (void)notifyInjecteeSuccessfullyInjected;
@end

@interface mach_inject_test_injected_bundle : NSObject {}
- (unsigned)testInjectedBundle;
@end
@implementation mach_inject_test_injected_bundle
- (unsigned)testInjectedBundle {
	return 42;
}
@end

@implementation injected_PrincipalClass

+ (void)load {
	printf("LOADDDDDDDDDD!\n");
	NSConnection *connection = [[NSConnection defaultConnection] retain];
    [connection setRootObject:[[[mach_inject_test_injected_bundle alloc] init] autorelease]];
    [connection registerName:[[connection rootObject] className]];
	
	[[NSApp delegate] notifyInjecteeSuccessfullyInjected];
	assert(0);
}

@end
