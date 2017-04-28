//
//  AudioActiveInfo.h
//  MSSPC
//
//  Created by Makara Khloth on 5/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioActiveInfo : NSObject {
@private
	NSString	*mBundleID;
	BOOL		mIsAudioActive;
}

@property (nonatomic, copy) NSString *mBundleID;
@property (nonatomic, assign) BOOL mIsAudioActive;

- (id) initWithData: (NSData *) aData;
- (NSData *) toData;

@end
