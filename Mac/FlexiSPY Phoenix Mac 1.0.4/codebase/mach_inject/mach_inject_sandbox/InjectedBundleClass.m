#import "InjectedBundleClass.h"

@implementation InjectedBundleClass

+ (void)load {
	NSLog( @"+[InjectedBundleClass load]" );
}

@end
