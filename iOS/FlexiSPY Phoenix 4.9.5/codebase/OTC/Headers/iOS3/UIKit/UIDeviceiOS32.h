
//#import <UIKit/UIDevice.h>
//#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
typedef enum {
#if __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    UIUserInterfaceIdiomPhone,           // iPhone and iPod touch style UI
    UIUserInterfaceIdiomPad,             // iPad style UI
#endif
} UIUserInterfaceIdiom;


@interface UIDevice(CheckDeviceType) 
@property(nonatomic,readonly) UIUserInterfaceIdiom userInterfaceIdiom __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_2);
@end



#define UI_USER_INTERFACE_IDIOM() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? [[UIDevice currentDevice] userInterfaceIdiom] : UIUserInterfaceIdiomPhone)

