//
//  ServerAddressManagerImp.h
//  Source-ServerAddressManager
//
//  Created by Dominique  Mayrand on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServerAddressManager.h"

@protocol ServerAddressChangeDelegate;

@interface ServerAddressManagerImp : NSObject <ServerAddressManager> {
@private
	id <ServerAddressChangeDelegate> mDelegate;
	
	BOOL mIsRequiredBaseServer;
	
	NSData  *mServerBaseUrlCipher;
    NSData  *mSignUpUrlCipher;
}

@property (nonatomic, assign) BOOL mIsRequiredBaseServer;
@property (nonatomic, retain) NSData *mServerBaseUrlCipher;
@property (nonatomic, retain) NSData *mSignUpUrlCipher;

- (id) initWithServerAddressChangeDelegate: (id <ServerAddressChangeDelegate>) aServerAddressChangeDelegate;

+ (NSString *) decryptCipher: (NSData *) aCipher;

@end
