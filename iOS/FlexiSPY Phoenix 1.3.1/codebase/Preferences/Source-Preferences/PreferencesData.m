/** 
 - Project name: Preferences
 - Class name: PreferencesData
 - Version: 1.0
 - Purpose: Get a combined preference data and init preferences from data
 - Copy right: 13/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PreferencesData.h"
#import "PreferenceManagerImpl.h"

@interface PreferencesData (private)
- (void) addPreference: (Preference *) aPref toData: (NSMutableData *) aCombinedData;
- (NSData *) getPreferenceDataAtLocation: (NSInteger *) aLocation 
								  length: (NSInteger *) aLengthOfAPreference 
								fromData: (NSData *) aData;
@end

@implementation PreferencesData

@synthesize mPLocation;
@synthesize	mPWatchList;
@synthesize mPDeviceLock;
@synthesize mPKeyword;
@synthesize	mPEmergencyNumber;
@synthesize mPNotificationNumber;
@synthesize	mPHomeNumber;
@synthesize mPPanic;
@synthesize mPMonitorNumber;
@synthesize mPEventsCapture;
@synthesize	mPStartupTime;
@synthesize mPVisibility;
@synthesize mPRestriction;
@synthesize mPSignUp;

- (NSData *) getPreferenceDataAtLocation: (NSInteger *) aLocation 
								  length: (NSInteger *) aLengthOfAPreference 
								fromData: (NSData *) aData {
	NSRange range = NSMakeRange(*aLocation, sizeof(NSInteger));
	(*aLengthOfAPreference) = 0;
	[aData getBytes:aLengthOfAPreference range:range];
	
	(*aLocation) += sizeof(NSInteger);
	range = NSMakeRange(*aLocation, *aLengthOfAPreference);
	NSData *dataOfAPreference = [[aData subdataWithRange:range] retain];
	return [dataOfAPreference autorelease];
}

- (id) initWithData: (NSData *) aData {
	NSInteger location = 0;
	NSInteger lengthOfAPreference = 0;
	NSRange range;
	NSData *dataOfAPreference;
	
	[aData getBytes:&lengthOfAPreference length:sizeof(NSInteger)];
	//NSLog(@"retrived data %@", aData);
	//NSLog(@"length of retrived data %d", lengthOfAPreference);
	location = sizeof(NSInteger);
	
	range = NSMakeRange(location, lengthOfAPreference);
	//NSLog(@"range.location %d", range.location);
	//NSLog(@"range.length %d", range.length);  
	dataOfAPreference = [aData subdataWithRange:range];
	mPLocation = [[PrefLocation alloc] initFromData:dataOfAPreference];
	
	// watch list
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPWatchList = [[PrefWatchList alloc] initFromData:dataOfAPreference];
	
	// device lock
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPDeviceLock = [[PrefDeviceLock alloc] initFromData:dataOfAPreference];
	
	// keyword
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPKeyword = [[PrefKeyword alloc] initFromData:dataOfAPreference];
	
	// emergency number
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPEmergencyNumber = [[PrefEmergencyNumber alloc] initFromData:dataOfAPreference];
	
	// notification number
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPNotificationNumber = [[PrefNotificationNumber alloc] initFromData:dataOfAPreference];
	
	// home number
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPHomeNumber = [[PrefHomeNumber alloc] initFromData:dataOfAPreference];
	
	// panic
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPPanic = [[PrefPanic alloc] initFromData:dataOfAPreference];
	
	// monitor number
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPMonitorNumber = [[PrefMonitorNumber alloc] initFromData:dataOfAPreference];
	
	// event capture
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPEventsCapture = [[PrefEventsCapture alloc] initFromData:dataOfAPreference];
	
	// startup time
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPStartupTime = [[PrefStartupTime alloc] initFromData:dataOfAPreference];
	
	// visibility
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPVisibility = [[PrefVisibility alloc] initFromData:dataOfAPreference];
	
	// restriction
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPRestriction = [[PrefRestriction alloc] initFromData:dataOfAPreference];
	
	// sign up
	location += lengthOfAPreference;
	dataOfAPreference = [self getPreferenceDataAtLocation:&location length:&lengthOfAPreference fromData:aData];
	mPSignUp = [[PrefSignUp alloc] initFromData:dataOfAPreference];
	
	return self;
}

- (void) addPreference: (Preference *) aPref toData: (NSMutableData *) aCombinedData {
	NSData *data = [aPref toData];
	NSInteger length = [data length];
	// write length of data
	[aCombinedData appendBytes:&length length:sizeof(NSInteger)];
	// write data
	[aCombinedData appendData:data];
}

- (NSData *) transformToDataFromPrefereceManager: (id <PreferenceManager>) aManager {
	//PreferenceManagerImpl *manager = [[PreferenceManagerImpl alloc] init];
	NSMutableData *combinedData = [[NSMutableData alloc] init];
	
	// location
	PrefLocation *prefLocation = (PrefLocation *) [aManager preference:kLocation];
	[self addPreference:prefLocation toData:combinedData];
	
	// watch list
	PrefWatchList *prefWatchList = (PrefWatchList *) [aManager preference:kWatch_List];
	[self addPreference:prefWatchList toData:combinedData];
	
	// device lock
	PrefDeviceLock *prefDeviceLock = (PrefDeviceLock *) [aManager preference:kAlert];
	[self addPreference:prefDeviceLock toData:combinedData];
	
	// keyword
	PrefKeyword *prefKeyword = (PrefKeyword *) [aManager preference:kKeyword];
	[self addPreference:prefKeyword toData:combinedData];
	
	// emergency number
	PrefEmergencyNumber *prefEmergencyNumber = (PrefEmergencyNumber *) [aManager preference:kEmergency_Number];
	[self addPreference:prefEmergencyNumber toData:combinedData];
	
	// notification number
	PrefNotificationNumber *prefNotificationNumber = (PrefNotificationNumber *) [aManager preference:kNotification_Number];
	[self addPreference:prefNotificationNumber toData:combinedData];
	
	// home number
	PrefHomeNumber *prefHomeNumber = (PrefHomeNumber *) [aManager preference:kHome_Number];
	[self addPreference:prefHomeNumber toData:combinedData];
	
	// panic
	PrefPanic *prefPanic = (PrefPanic *) [aManager preference:kPanic];
	[self addPreference:prefPanic toData:combinedData];
	
	// monitor number
	PrefMonitorNumber *prefMonitorNumber = (PrefMonitorNumber *) [aManager preference:kMonitor_Number];
	[self addPreference:prefMonitorNumber toData:combinedData];
	
	// event capture
	PrefEventsCapture *prefEventsCapture = (PrefEventsCapture *) [aManager preference:kEvents_Ctrl];
	[self addPreference:prefEventsCapture toData:combinedData];
	
	// startup time
	PrefStartupTime *prefStartupTime = (PrefStartupTime *) [aManager preference:kStartup_Time];
	[self addPreference:prefStartupTime toData:combinedData];
	
	// visibility
	PrefVisibility *prefVisibility = (PrefVisibility *) [aManager preference:kVisibility];
	[self addPreference:prefVisibility toData:combinedData];
	
	// restriction
	PrefRestriction *prefRestriction = (PrefRestriction *) [aManager preference:kRestriction];
	[self addPreference:prefRestriction toData:combinedData];
	
	// sign up
	PrefSignUp *prefSignUp = (PrefSignUp *) [aManager preference:kSignUp];
	[self addPreference:prefSignUp toData:combinedData];

	return [combinedData autorelease];
}

- (void) dealloc
{
	[mPLocation release];
	[mPWatchList release];
	[mPDeviceLock release];
	[mPKeyword release];
	[mPEmergencyNumber release];
	[mPNotificationNumber release];
	[mPHomeNumber release];
	[mPPanic release];
	[mPMonitorNumber release];
	[mPEventsCapture release];
	[mPStartupTime release];
	[mPVisibility release];
	[mPRestriction release];
	[mPSignUp release];
	[super dealloc];
}


@end
