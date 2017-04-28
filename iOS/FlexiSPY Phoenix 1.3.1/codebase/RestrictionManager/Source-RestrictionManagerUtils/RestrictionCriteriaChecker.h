//
//  RestrictionPeriodChecker.h
//  RestrictionManagerUtils
//
//  Created by Syam Sasidharan on 6/14/12.
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

@class SyncTime;

@interface RestrictionCriteriaChecker : NSObject {
@private
    SyncTime *mWebUserSyncTime;
}

- (id) initWithWebUserSyncTime: (id) aWebUserSyncTime;
- (BOOL) checkBlockEvent: (id) aBlockEvent usingCommunicationDirective: (id) aCD ;

@end
