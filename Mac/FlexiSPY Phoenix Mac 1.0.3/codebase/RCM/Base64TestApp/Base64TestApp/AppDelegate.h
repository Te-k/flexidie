//
//  AppDelegate.h
//  Base64TestApp
//
//  Created by ophat on 7/14/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *PlainField;
@property (weak) IBOutlet NSTextField *CipherField;
@property (weak) IBOutlet NSTextFieldCell *Output;

- (IBAction)Go:(id)sender;

@end

