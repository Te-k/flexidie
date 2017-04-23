//
//  GetBinaryResponse.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 6/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetBinaryResponse : ResponseData {
@private
	NSString	*mBinaryName;
	NSUInteger	mCRC32;
	id			mBinary;		// NSString which is path to binary if file is big otherwise NSData
}

@property (nonatomic, copy) NSString *mBinaryName;
@property (nonatomic, assign) NSUInteger mCRC32;
@property (nonatomic, retain) id mBinary;

@end
