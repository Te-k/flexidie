//
//  USBAutoActivationAlert.h
//  blblu
//
//  Created by ophat on 6/12/15.
//
//

#import <Cocoa/Cocoa.h>


@interface GlobalAlert : NSWindowController {
@private
    NSString    *   mMessage;
    NSString    *   mTitle;
    NSTextField *   mAlertMessage;
    NSPanel *mPanal;
}


@property (assign) IBOutlet NSPanel *mPanal;
@property (nonatomic, assign) IBOutlet NSTextField *mAlertMessage;
@property (nonatomic, copy) NSString * mMessage;
@property (nonatomic, copy) NSString * mTitle;

- (IBAction)oKClick:(id)sender;

@end

