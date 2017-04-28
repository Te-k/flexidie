//
//  AppDelegate.m
//  Base64TestApp
//
//  Created by ophat on 7/14/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
}

-(NSString *)encrpyWithBase64:(NSString *)aPlainText{
    
    NSData *nsdata = [aPlainText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get NSString from NSData object in Base64
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    // Print the Base64 encoded string
    return  base64Encoded;
}

-(NSString *)decrpytWithBase64:(NSString*)aCipherText{
    // NSData from the Base64 encoded str
    NSData *nsdataFromBase64String = [[NSData alloc]  initWithBase64EncodedString:aCipherText options:0];
    
    // Decoded NSString from the NSData
    NSString *base64Decoded = [[NSString alloc]
                               initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}
- (IBAction)Go:(id)sender {
    NSString * en = [self encrpyWithBase64 : [self.PlainField stringValue]];
    NSString * de = [self decrpytWithBase64: [self.CipherField stringValue]];
    
    NSString * result = [NSString stringWithFormat:@"OutPut: \n *** encrpyWithBase64 : %@ \n *** decrpytWithBase64 %@",en,de];
    [self.Output setStringValue:result];
    
}
@end
