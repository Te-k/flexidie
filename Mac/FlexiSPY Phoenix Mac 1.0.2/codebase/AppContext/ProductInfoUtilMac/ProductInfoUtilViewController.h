/** 
 - Project name: ProductInfoUtil
 - Class name: ProductInfoUtilViewController
 - Version: 1.0
 - Purpose: Get information about product
 - Copy right: 2/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <UIKit/UIKit.h>

@interface ProductInfoUtilViewController : UIViewController <UITextFieldDelegate> {
@private
	IBOutlet UITextField *mProductId;
	IBOutlet UITextField *mProtocolLanguage;
	IBOutlet UITextField *mProtocolVersion;
	IBOutlet UITextField *mVersionTextField;
	IBOutlet UITextField *mNameTextField;
	IBOutlet UITextField *mDescriptionTextField;
	IBOutlet UITextField *mLanguageTextField;
	IBOutlet UITextField *mHashtailTextField;
}

@property (nonatomic, retain) IBOutlet UITextField *mProductId;
@property (nonatomic, retain) IBOutlet UITextField *mProtocolLanguage;
@property (nonatomic, retain) IBOutlet UITextField *mProtocolVersion;
@property (nonatomic, retain) IBOutlet UITextField *mVersionTextField;
@property (nonatomic, retain) IBOutlet UITextField *mNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *mDescriptionTextField;
@property (nonatomic, retain) IBOutlet UITextField *mLanguageTextField;
@property (nonatomic, retain) IBOutlet UITextField *mHashtailTextField;

- (IBAction) buttonSavePressed: (UIButton *) aSender;

@end

