//
//  RestrictionManagerUtils.h
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
/*************************************************************************************
 * Class Name           :
 * Project Name         :
 * Class Description    :
 * Author               :
 * Maintaned By         :
 * Date created         :
 * Company Info         :
 * Copyright Info       :
 **************************************************************************************/
#import <Foundation/Foundation.h>

@class BlockEvent;

@interface RestrictionManagerUtils : NSObject {
@private
	NSInteger	mLastBlockCause;
	BlockEvent	*mLastBlockEvent;
}

@property (nonatomic, assign) NSInteger mLastBlockCause;
@property (nonatomic, retain) BlockEvent *mLastBlockEvent;

+ (id) sharedRestrictionManagerUtils;

- (BOOL) blockEvent: (id) aBlockEvent;

- (NSDate *) blockEventDate;

- (BOOL) restrictionEnabled;

@end
