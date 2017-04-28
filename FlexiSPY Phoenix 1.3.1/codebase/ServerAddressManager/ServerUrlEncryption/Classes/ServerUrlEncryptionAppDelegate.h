/** 
 - Project name: ServerUrlEncryption
 - Class name: ServerUrlEncryptionAppDelegate
 - Version: 1.0
 - Purpose: Application delegate
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <UIKit/UIKit.h>

@class ServerUrlEncryptionViewController;

@interface ServerUrlEncryptionAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ServerUrlEncryptionViewController *viewController;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ServerUrlEncryptionViewController *viewController;

@end

