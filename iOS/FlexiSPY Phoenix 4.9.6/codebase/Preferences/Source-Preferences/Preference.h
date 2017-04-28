/** 
 - Project name: Preferences
 - Class name: Preference
 - Version: 1.0
 - Purpose: Base class of preferences
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

typedef enum {
	kPrefUnknown,
    kEvents_Ctrl,
	kWatch_List,
    kLocation,
	kMonitor_Number,
	kNotification_Number,
	kEmergency_Number,
	kHome_Number,
	kKeyword,
	kPanic,
	kAlert,
	kStartup_Time,
	kVisibility,
	kRestriction,
	kSignUp,
	kFacetimeID,
    kFileActivity,
    kCallRecord
} PreferenceType;

@interface Preference : NSObject {
@protected
	PreferenceType mType;
}


@property (nonatomic, assign) PreferenceType mType;

- (id) initFromData: (NSData *) aData;
- (id) initFromFile: (NSString *) aFilePath; 
- (NSData *) toData;
- (PreferenceType) type;
- (void) reset;

@end
