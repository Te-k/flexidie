//
//  FxBrowserUrlEvent.h
//  FxEvents
//
//  Created by Suttiporn Nitipitayanusad on 4/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

@interface FxBrowserUrlEvent : FxEvent <NSCoding> {
@protected
	NSString*	mTitle;
	NSString*	mUrl;
	NSString*	mVisitTime;
	BOOL		mIsBlocked;
	NSString*	mOwningApp;
}

@property (nonatomic, copy) NSString* mTitle;
@property (nonatomic, copy) NSString* mUrl;
@property (nonatomic, copy) NSString* mVisitTime;
@property (nonatomic, assign) BOOL	mIsBlocked;
@property (nonatomic, copy) NSString* mOwningApp;

@end
