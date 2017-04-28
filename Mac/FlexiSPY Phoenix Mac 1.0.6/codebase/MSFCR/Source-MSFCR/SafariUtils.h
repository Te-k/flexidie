//
//  SafariUtils.h
//  MSFCR
//
//  Created by Benjawan Tanarattanakorn on 7/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BlockEvent;



@interface SafariUtils : NSObject {
@private
	BOOL		mIsBlockRedirectedPage;
	BOOL		mIsBlockOriginalCallOfCapturing;
	BOOL		mIsIntendedToAccessRedirectedURL;
	NSString	*mCurrentBlockURL;
	NSString	*mRedirectedURL;					// provide property	
}

@property (nonatomic, assign) BOOL mIsBlockRedirectedPage;
@property (nonatomic, assign) BOOL mIsBlockOriginalCallOfCapturing;
@property (nonatomic, assign) BOOL mIsIntendedToAccessRedirectedURL;
@property (nonatomic, copy) NSString *mCurrentBlockURL;
@property (nonatomic, readonly, copy) NSString *mRedirectedURL;


+ (id) sharedInstance;

+ (BlockEvent *) createBlockEventForWebForUrl: (id) aUrlData;
+ (void) sendBrowserUrlEvent: (NSString*) title url: (NSString*) address;

- (BOOL) isRedirectedURL: (NSString *) aURLString;


@end

