/** 
 - Project name: Preferences
 - Class name: PrefHomeNumber
 - Version: 1.0
 - Purpose: Preference about home number
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefHomeNumber : Preference {
@private
	NSArray		*mHomeNumbers;
}


@property (nonatomic, retain) NSArray *mHomeNumbers;

@end
