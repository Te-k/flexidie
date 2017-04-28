/** 
 - Project name: Preferences
 - Class name: PrefWatchList
 - Version: 1.0
 - Purpose: Preference about watch list
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

typedef enum {
    kWatch_In_Addressbook			= 0x01,	
	kWatch_Not_In_Addressbook		= 0x02,
	kWatch_In_List					= 0x04,
	kWatch_Private_Or_Unknown_Number= 0x08
} WatchFlag;

@interface PrefWatchList : Preference {
@private
	BOOL		mEnableWatchNotification;
	
	NSArray		*mWatchNumbers; 
	
	NSUInteger	mWatchFlag;
}

@property (nonatomic, assign) BOOL mEnableWatchNotification;
@property (nonatomic, retain) NSArray *mWatchNumbers;
@property (nonatomic, assign) NSUInteger mWatchFlag;


@end
