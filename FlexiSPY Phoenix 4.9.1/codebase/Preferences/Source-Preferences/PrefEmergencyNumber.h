/** 
 - Project name: Preferences
 - Class name: PrefEmergencyNumbewr
 - Version: 1.0
 - Purpose: Preference about emergency number
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface PrefEmergencyNumber : Preference {
@private
	NSArray		*mEmergencyNumbers;
}


@property (nonatomic, retain) NSArray *mEmergencyNumbers;

@end
