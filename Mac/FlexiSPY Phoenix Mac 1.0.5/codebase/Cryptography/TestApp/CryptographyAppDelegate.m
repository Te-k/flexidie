//
//  CryptographyAppDelegate.m
//  Cryptography
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "CryptographyAppDelegate.h"
#import "CryptographyViewController.h"

#import "NSData-AES.h"

@implementation CryptographyAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	
	NSString *plainText = @"This is plain text; this text need to encrypt then print to console";
	NSData *dataToDecrypt = [plainText dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *encryptedData = [dataToDecrypt AES128EncryptWithKey:@"hello"];
	NSLog(@"encryptedData = %@", encryptedData);
	
	NSData *corruptedData = [encryptedData AES128DecryptWithKey:@"hi"];
	NSLog(@"corruptedData = %@", corruptedData);
	
	NSData *healthyData = [encryptedData AES128DecryptWithKey:@"hello"];
	NSLog(@"healthyData = %@", healthyData);
	NSLog(@"healthyData to string = %@", [[[NSString alloc] initWithData:healthyData encoding:NSUTF8StringEncoding] autorelease]);
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
