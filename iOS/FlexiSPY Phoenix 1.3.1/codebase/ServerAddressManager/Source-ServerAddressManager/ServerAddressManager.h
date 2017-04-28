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
-(void) setBaseServerUrl:(NSString*) aUrl;
- (void) setBaseServerCipherUrl: (NSData *) aCipherUrl;
-(void) setRequireBaseServerUrl:(bool) aRequired;
-(NSString*) getHostServerUrl; // Not used for Flexispy and FeelSecure only use in Cyclops. 
-(NSString*) getStructuredServerUrl; // Request current URL
-(NSString*) getUnstructuredServerUrl;
- (BOOL) verifyURL: (NSString *) aUrl;
- (BOOL) hasNextURL;
//Added
- (void) addUserURLs: (NSArray *) aUrls;
- (void) clearUserURLs;
- (NSArray* ) userURLs;
// Sign up
- (NSString *) signUpUrl;
@end
