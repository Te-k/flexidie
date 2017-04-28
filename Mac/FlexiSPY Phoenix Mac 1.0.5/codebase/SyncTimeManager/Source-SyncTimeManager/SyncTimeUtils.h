//
//  SyncTimeUtils.h
//  SyncTimeManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SyncTime;

@interface SyncTimeUtils : NSObject {

}

/*************************************************************************************
 * Method Name  : clientSyncTime
 * Parameters   : Server sync time object
 * Purpose      : Use to convert server sync time to local client sync time (take time zone
					into consideration
 * Return Type  : Client local sync time object
 **************************************************************************************/
+ (SyncTime *) clientSyncTime: (SyncTime *) aServerSyncTime;

/*************************************************************************************
 * Method Name  : now
 * Parameters   : None
 * Purpose      : Use to get client local sync time object
 * Return Type  : Client local sync time now object
 **************************************************************************************/
+ (SyncTime *) now;

/*************************************************************************************
 * Method Name  : webUserSyncTime
 * Parameters   : Server sync time object
 * Purpose      : Use to convert server sync time to local client sync time (not take time zone
					into consideration (simply take utc time plus offset)
 * Return Type  : Client local sync time object
 **************************************************************************************/
+ (SyncTime *) webUserSyncTime: (SyncTime *) aServerSyncTime;

@end
