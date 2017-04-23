//
//  PhoenixUtilAppDelegate.m
//  PhoenixUtil
//
//  Created by Pichaya Srifar on 7/27/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import "PhoenixUtilAppDelegate.h"
#import "AESCryptor.h"
#import "RSACryptor.h"
#import "CryptoUtil.h"

@implementation PhoenixUtilAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	NSData *publicKey = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rsa_public"  ofType:@"key"]];
	
	NSLog(@"1 %@", publicKey);
	RSACryptor *cryptor = [[RSACryptor alloc] init];
	NSData *encryptedAESKey = [cryptor encrypt:[@"hVroFP8ZQ0mJe2CR" dataUsingEncoding:NSUTF8StringEncoding]
						   withServerPublicKey:publicKey];
	[cryptor release];
	
	
	NSLog(@"2 %@", encryptedAESKey);
	
//	BOOL status;
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"rsa_public" ofType:@"key"];
//	NSData *keyData = [NSData dataWithContentsOfFile:path];
//	status = [CryptoUtil saveRSAPublicKey:keyData appTag:@"keychain.test" overwrite:YES];
//	NSLog(@"saveRSAPublicKey status = %d", status);
	
//	AESCryptor *ct = [[AESCryptor alloc] init];
//	
//	NSData *plainText = [@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding];
//	NSLog(@"pt = %@", plainText);
//	
//	NSData *result = [ct encrypt:plainText withKey:@"1234567890123456"];
//	
//	NSLog(@"pass = %@", [@"1234567890123456" dataUsingEncoding:NSUTF8StringEncoding]);
//	
//	NSLog(@"%@", result);
//
//	result = [ct decrypt:result withKey:@"1234567890123456"];
//	
//	NSLog(@"%@", result);
//	
//	
//	NSLog(@"-------> %@", [ct decrypt:enct withKey:@"1234567890123456"]);
//	
//	
//	[ct release];
	
	
	
	
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
