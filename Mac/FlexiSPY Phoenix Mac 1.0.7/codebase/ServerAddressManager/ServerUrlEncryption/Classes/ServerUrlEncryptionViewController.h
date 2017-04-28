/** 
 - Project name: ServerUrlEncryption
 - Class name: ServerUrlEncryptionViewController
 - Version: 1.0
 - Purpose: Get server url to be encrypted
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <UIKit/UIKit.h>

@class EncryptionEngin;

@interface ServerUrlEncryptionViewController : UIViewController <UITextFieldDelegate> {
@private
	IBOutlet UITextField *mUrlText;
	
	EncryptionEngin *mEncryptionEngin;
}


@property (nonatomic, retain) IBOutlet UITextField *mUrlText;
@property (nonatomic, retain) EncryptionEngin *mEncryptionEngin;

- (IBAction) addButtonPressed: (id) aSender;
- (IBAction) encryptButtonPressed: (id) aSender;
- (IBAction) decryptButtonPressed: (id) aSender;

@end

