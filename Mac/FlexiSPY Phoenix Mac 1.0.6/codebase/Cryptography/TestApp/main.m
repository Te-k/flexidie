//
//  main.m
//  Cryptography
//
//  Created by Pichaya Srifar on 11/8/11.
//  Copyright Vervata 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData-AES.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
	int retVal = 0;
	
	NSString *key				= @"hello";
	
	NSString *plainText			= @"This is plain text; this text need to encrypt then print to console";
	NSData *dataToBeEncrypted	= [plainText dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *encryptedData		= [dataToBeEncrypted AES128EncryptWithKey:key];
	NSLog(@"encryptedData = %@", encryptedData);
	
	// Decrypt with the wrong key	
	NSData *corruptedData = [encryptedData AES128DecryptWithKey:@"hi"];
	NSLog(@"corruptedData = %@", corruptedData);
	if (corruptedData) {
		NSLog(@"corruptedData to string = %@", 
			  [[[NSString alloc] initWithData:corruptedData encoding:NSUTF8StringEncoding] autorelease]);
	}
	
	// Decrypt with the right key
	NSData *healthyData = [encryptedData AES128DecryptWithKey:key];
	NSLog(@"healthyData = %@", healthyData);
	
	NSLog(@"healthyData to string = %@", [[[NSString alloc] initWithData:healthyData encoding:NSUTF8StringEncoding] autorelease]);

	
	
    [pool release];
    return retVal;
}
