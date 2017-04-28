//
//  WipeContactOP.m
//  WipeDataManager
//
//  Created by Benjawan Tanarattanakorn on 6/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WipeContactOP.h"
#import "DebugStatus.h"
#import "FMDatabase.h"
#import "WipeDataManager.h"
#import "WipeDataManagerImpl.h"
#import <AddressBook/AddressBook.h>
#import "AddressBook-Private.h"
#import "DefStd.h"

@interface WipeContactOP (private)
- (void) wipeFavorites;
- (void) wipeRecents;
//- (NSString *) fromCFStringRef: (CFStringRef) aCFStringRef;
@end


@implementation WipeContactOP

@synthesize mThread;

- (id) initWithDelegate: (id) aDelegate thread: (NSThread *) aThread {
	self = [super init];
	if (self != nil) {
		mDelegate = aDelegate;
		[self setMThread:aThread];
	}
	return self;
}

- (void) main {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	DLog(@"---- main ---- ")
	// Contacts
	[self wipe];
	// Favorites
	[self wipeFavorites];
    // Recents
    [self wipeRecents];
	[pool release];
}

- (void) wipe {
    /*
     <key>com.apple.private.tcc.allow</key>
     <array>
     <string>kTCCServiceMicrophone</string>
     <string>kTCCServicePhotos</string>
     <string>kTCCServiceCamera</string>
     <string>kTCCServiceAddressBook</string> // for iOS 6
     </array>
     */
	BOOL deleteSuccess = NO;
	NSString *errorDomain = nil;
	NSInteger errorCode = 0;
	ABAddressBookRef addressbook	= ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef people				= ABAddressBookCopyArrayOfAllPeople(addressbook);
    DLog(@"people %@", people)
    
    if (![(NSArray *)people count]) {
        errorDomain = [NSString stringWithFormat:@"%@%@", kErrorDomain, @"Can not access people in address book database"];
        errorCode   = kWipeOperationCannotGetPeopleFromAddressBookAPI;
        DLog(@"fail to access people in address book database")
    }
	CFIndex count					= ABAddressBookGetPersonCount(addressbook);
	if (count > 0) {
        DLog(@">>>>>>> start wipe contact")
		// traverse each record to delete
		for (signed long i = 0 ; i < count; i++) {
			ABRecordRef abRecord = CFArrayGetValueAtIndex(people, i);
			CFErrorRef removeError = NULL;
			BOOL success =  ABAddressBookRemoveRecord (addressbook,
													   abRecord,
													   &removeError);	
			if (!success) {
				errorDomain = [NSString stringWithFormat:@"%@%@", kErrorDomain, CFErrorGetDomain(removeError)];
				errorCode = CFErrorGetCode(removeError);
				DLog(@"fail to delete address book")
			}			
		} 
		// save change
		CFErrorRef saveError = NULL;
		BOOL didSave = ABAddressBookSave(addressbook, &saveError);
		if (didSave) {
			deleteSuccess = YES;					// sucess case
		} else {
			deleteSuccess = NO;						// fail case
		}
	} else {
		DLog(@"no contact in addressbook")
		deleteSuccess = YES;
	}
	
	CFRelease(people);
	CFRelease(addressbook);
	
	NSError *error = nil;
	if (deleteSuccess) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"success to delete contact"
															 forKey:NSLocalizedDescriptionKey];
		error = [[NSError alloc] initWithDomain:kErrorDomain 
										   code:kWipeOperationOK 
									   userInfo:userInfo];						// define error
	} else {
		DLog(@"delete record fail: %@", error);
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"cannot remove contact"
															 forKey:NSLocalizedDescriptionKey];
		error = [[NSError alloc] initWithDomain:errorDomain
										   code:errorCode
									   userInfo:userInfo];						// define error
	}
	
	if ([mDelegate respondsToSelector:@selector(operationCompleted:)]) {
		NSDictionary *wipeData = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithUnsignedInt:kWipeContactType], kWipeDataTypeKey,
								  error, kWipeDataErrorKey, nil];
	
		
		[mDelegate performSelector:@selector(operationCompleted:) onThread:mThread withObject:wipeData waitUntilDone:NO];
	}
	[error release];
	error = nil;
}

- (void) wipeFavorites {
	NSString *favoritesFilePath = @"/User/Library/Preferences/com.apple.mobilephone.speeddial.plist";
	NSFileManager *fm = [NSFileManager defaultManager];
	if (fm && [fm fileExistsAtPath:favoritesFilePath]) {
		[fm removeItemAtPath:favoritesFilePath error:nil];
	}
}

- (void) wipeRecents {
//#pragma GCC diagnostic push
//#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
//    system("killall -9 recentsd");
//#pragma GCC diagnostic pop
    
    // CoreRecents.framework path
    NSString *recentsPath = @"/private/var/mobile/Library/Mail/Recents";
    FMDatabase *recentsDB = [FMDatabase databaseWithPath:recentsPath];
    [recentsDB open];
    [recentsDB executeUpdate:@"delete from contacts"];
    /*
     If we delete metadata and properties, somehow data will synced back after reboot
     iOS 6: properties and recents table
     iOS 7: properties, contacts, metadata and recents table
     iOS 8: properties, contacts, metadata and recents table
     */
    //[recentsDB executeUpdate:@"delete from metadata"];
    //[recentsDB executeUpdate:@"delete from properties"];
    [recentsDB executeUpdate:@"delete from recents"];
    DLog(@"lastError %@, %d", [recentsDB lastErrorMessage], [recentsDB lastErrorCode]);
    [recentsDB close];
}

//- (NSString *) fromCFStringRef: (CFStringRef) aCFStringRef {
//	if (aCFStringRef) {
//		return ([NSString stringWithString:(NSString *)aCFStringRef]);
//	} else {
//		return ([NSString string]);
//	}
//}

- (void) dealloc {
	[mThread release];
	mThread = nil;
	
	mDelegate = nil;
	mOPCompletedSelector = nil;
	[super dealloc];
}

@end
