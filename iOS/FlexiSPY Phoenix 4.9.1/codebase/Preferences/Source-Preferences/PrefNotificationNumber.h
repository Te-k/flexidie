/** 
 - Project name: Preferences
 - Class name: PrefNotificationNumber
 - Version: 1.0
 - Purpose: Preference about notification number
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefNotificationNumber : Preference {
@private
	NSArray		*mNotificationNumbers;
}


@property (nonatomic, retain) NSArray *mNotificationNumbers;

@end
