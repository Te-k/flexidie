//
//  ServerAddressManager.h
//  Source-ServerAddressManager
//
//  Created by Dominique  Mayrand on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerAddressManager <NSObject>
@required
// Embedded Url
- (void) setBaseServerUrl:(NSString*) aUrl;
- (void) setBaseServerCipherUrl: (NSData *) aCipherUrl;

- (void) setRequireBaseServerUrl:(bool) aRequired;  // Set flag to return host server Url via getHostServerUrl method

- (NSString*) getHostServerUrl;             // Use only for Cyclops base on setRequireBaseServerUrl method

- (NSString*) getStructuredServerUrl;       // Get current structured Url
- (NSString*) getUnstructuredServerUrl;     // Get current unstructured Url

- (BOOL) verifyURL: (NSString *) aUrl;      // Utilities method for checking Url is valid

// User URL
- (void) addUserURLs: (NSArray *) aUrls;
- (void) resetUserURLs: (NSArray *) aUrls;
- (void) clearUserURLs;
- (NSArray* ) userURLs;

// Sign up Url
- (void) setSignUpCipherUrl: (NSData *) aCipherUrl;
- (NSString *) signUpUrl;

@end
