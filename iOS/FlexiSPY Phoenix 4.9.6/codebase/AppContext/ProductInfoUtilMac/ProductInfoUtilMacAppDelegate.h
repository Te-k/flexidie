//
//  ProductInfoUtilMacAppDelegate.h
//  ProductInfoUtilMac
//
//  Created by Benjawan Tanarattanakorn on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ProductInfoUtilMacAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *mProductId;
	IBOutlet NSTextField *mProtocolLanguage;
	IBOutlet NSTextField *mProtocolVersion;
	IBOutlet NSTextField *mVersionTextField;
	IBOutlet NSTextField *mNameTextField;
	IBOutlet NSTextField *mDescriptionTextField;
	IBOutlet NSTextField *mLanguageTextField;
	IBOutlet NSTextField *mHashtailTextField;
}

@property (assign) IBOutlet NSWindow *window;


@property (nonatomic, retain) IBOutlet NSTextField *mProductId;
@property (nonatomic, retain) IBOutlet NSTextField *mProtocolLanguage;
@property (nonatomic, retain) IBOutlet NSTextField *mProtocolVersion;
@property (nonatomic, retain) IBOutlet NSTextField *mVersionTextField;
@property (nonatomic, retain) IBOutlet NSTextField *mNameTextField;
@property (nonatomic, retain) IBOutlet NSTextField *mDescriptionTextField;
@property (nonatomic, retain) IBOutlet NSTextField *mLanguageTextField;
@property (nonatomic, retain) IBOutlet NSTextField *mHashtailTextField;

- (IBAction) buttonSavePressed: (id) aSender;

@end
