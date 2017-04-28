//
//  ServerUrlEncryptionMacAppDelegate.h
//  ServerUrlEncryptionMac
//
//  Created by Ophat Phuetkasickonphasutha on 10/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EncryptionEngin;

@interface ServerUrlEncryptionMacAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSTextField *URLField;
    
    EncryptionEngin *mEncryptionEngin;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *URLField;
@property (nonatomic, retain) EncryptionEngin *mEncryptionEngin;

- (IBAction)Encrypt:(id)sender;
- (IBAction)Decrypt:(id)sender;

@end
