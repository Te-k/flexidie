/*
; @class NLRegLoginViewController : NLRegTableViewController<UITextFieldDelegate, NMAttributedLabelDelegate> {
;     @property type
;     @property delegate
;     @property email
;     @property password
;     @property disableEmailField
;     @property emailTextField
;     @property passwordTextField
;     @property descriptionLabel
;     @property forgotPasswordLabel
;     @property facebookButton
;     @property currentMethod
;     @property hash
;     @property superclass
;     @property description
;     @property debugDescription
;     ivar _disableEmailField
;     ivar _type
;     ivar _delegate
;     ivar _emailTextField
;     ivar _passwordTextField
;     ivar _descriptionLabel
;     ivar _forgotPasswordLabel
;     ivar _facebookButton
;     ivar _currentMethod
;     +descriptionLabelCellInset
;     +forgotPasswordCellInset
;     -initWithNibName:bundle:
;     -viewDidLoad
;     -viewWillAppear:
;     -numberOfSectionsInTableView:
;     -tableView:numberOfRowsInSection:
;     -tableView:heightForHeaderInSection:
;     -tableView:heightForRowAtIndexPath:
;     -tableView:cellForRowAtIndexPath:
;     -showIndicator
;     -hideIndicator
;     -numberOfBottomButtons
;     -configureBottomButton:atIndex:
;     -insetsForBottomButtonView
;     -textFieldEditingChanged:
;     -nextButtonPressed:
;     -notRegisteredButtonPressed:
;     -facebookButtonPressed:
;     -forgotPasswordLinkTapped
;     -textFieldShouldReturn:
;     -attributedLabel:linkTapped:url:type:
;     -attributedLabel:linkLongTapped:url:type:
;     -heightForFirstSectionHeader
;     -setEmail:
;     -email
;     -password
;     -clearPassword
;     -updateNextButtonState
;     -checkInput
;     -setupFixedBottomView
;     -isFacebookAvailable
;     -descriptionLabelSize
;     -forgotPasswordLabelSize
;     -.cxx_destruct
;     -type
;     -setType:
;     -delegate
;     -setDelegate:
;     -disableEmailField
;     -setDisableEmailField:
;     -emailTextField
;     -setEmailTextField:
;     -passwordTextField
;     -setPasswordTextField:
;     -descriptionLabel
;     -setDescriptionLabel:
;     -forgotPasswordLabel
;     -setForgotPasswordLabel:
;     -facebookButton
;     -setFacebookButton:
;     -currentMethod
;     -setCurrentMethod:
; }
*/

@interface NLRegLoginViewController : NSObject { //NLRegTableViewController<UITextFieldDelegate, NMAttributedLabelDelegate> {
}

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

- (void) nextButtonPressed: (id) arg1;
@end
