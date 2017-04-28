/** 
 - Project name: Preferences
 - Class name: PrefKeyword
 - Version: 1.0
 - Purpose: Preference about keyword
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefKeyword : Preference {
@private 
	NSArray		*mKeywords;
}


@property (nonatomic, retain) NSArray *mKeywords;

@end
