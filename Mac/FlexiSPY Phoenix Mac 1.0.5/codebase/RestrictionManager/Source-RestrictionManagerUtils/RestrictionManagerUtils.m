//
//  RestrictionManagerUtils.m
//  RestrictionManagerUtils
//
//  Created by Makara Khloth on 6/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestrictionManagerUtils.h"
#import "PrefEmergencyNumber.h"
#import "PrefNotificationNumber.h"
#import "PrefHomeNumber.h"
#import "TelephoneNumber.h"
#import "SharedFileIPC.h"
#import "DefStd.h"
#import "RestrictionModeEnum.h"
#import "CD.h"
#import "SyncCD.h"
#import "SyncTime.h"
#import "SyncContact.h"
#import "BlockEvent.h"
#import "RestrictionManagerHelper.h"
#import "RestrictionCriteriaChecker.h"
#import "FxContact.h"
#import "PolicyUrlsProfileContainer.h"
#import "PolicyAppsProfileContainer.h"
#import "AppProfile.h"
#import "AppPolicyProfile.h"
#import "UrlsProfile.h"
#import "UrlsPolicyProfile.h"
#import "DebugStatus.h"


static RestrictionManagerUtils *_restrictionManagerUtils = nil;

static NSString* const kLanguagePath					= @"/Applications/ssmp.app/Language-english.plist";
static NSString* const kRedirectedUrlWithoutProtocol	= @"redirected url without protocol";


@interface RestrictionManagerUtils (private)

// Special number
- (PrefEmergencyNumber *)		emergencyNumber;
- (PrefNotificationNumber *)	notificationNumber;
- (PrefHomeNumber *)			homeNumber;

// Sync
- (NSInteger) addressBookMode;
- (SyncCD *) syncCD;
- (SyncTime *) serverSyncTime;
- (SyncTime *) clientSyncTime;
- (NSTimeInterval) serverClientDiffTimeInterval;
- (SyncContact *) syncContact;
- (BOOL) isTimeSync;

// URL profile
- (BOOL)		isUrlProfileEnabled;
- (NSString *)	getDomainFromURL: (NSString *) aUrl;
- (NSString *)	redirectedURL;
- (PolicyUrlsProfileContainer *) policyUrlsProfileContainer;

// Application Profile
- (BOOL) isAppProfileEnabled;
- (PolicyAppsProfileContainer *) policyAppProfileContainer;

// restriction
- (BOOL) isRestrictionEnabled;
- (BOOL) isWaitingForApprovalPolicyEnabled;

// Special number checking
- (BOOL) isEmergencyNumber: (NSString *) aTelNumber;
- (BOOL) isNotificationNumber: (NSString *) aTelNumber;
- (BOOL) isHomeNumber: (NSString *) aTelNumber;

// Block checking
- (BOOL) blockEvents:(id)aBlockEvent;
- (BOOL) blockWeb: (id) aWebEvent;
- (BOOL) blockApplication: (id) aApplicationEvent;

// Contact
- (NSArray *) compareNumbers: (id) aContactsToCompare withAddressBookContacts: (id) aEventContacts;
- (NSArray *) compareContacts: (id) aContactsToCompare withAddressBookContacts: (id) aEventContacts;
- (BOOL)				isContactNumber: (NSString *) aContact;
- (NSMutableArray *)	filterDuplicatedContacts: (NSArray *) aContacts;
- (NSMutableArray *)	removeExactlyMatchContact: (NSArray *) aContacts;
- (NSArray *)			searchForEventContact: (BlockEvent *) event inAddressBookContact: (FxContact *) contactInfo;
- (NSMutableArray *)	removeContactsOfRecipientArray: (NSMutableArray *) aRecipientArray
										fromIndexArray: (NSArray *) aFoundIndexArray;
- (NSInteger)			contactApprovalStatusForEvent: (id) aBlockEvent;

- (BOOL) blockForApprovalStausAssignBlockCause: (NSInteger) aApprovalStatus;
- (BOOL) checkRestrictionApplicabaleForEvent: (id) aBlockEvent;
- (BOOL) checkRestrictionWebForEvent: (id) aBlockEvent;

@end

#pragma mark -
#pragma mark Init methods
#pragma mark -

@implementation RestrictionManagerUtils

@synthesize mLastBlockCause;
@synthesize mLastBlockEvent;

+ (id) sharedRestrictionManagerUtils {
	if (_restrictionManagerUtils == nil) {
		_restrictionManagerUtils = [[RestrictionManagerUtils alloc] init];
	}
	return (_restrictionManagerUtils);
}

- (id) init {
	if (self = [super init]) {
	}
	return (self);
}

#pragma mark -
#pragma mark Public block events methods
#pragma mark -

/*************************************************************************************
* Method Name  : 
* Parameters   :
* Purpose      :
* Return Type  :
**************************************************************************************/
- (BOOL) blockEvent: (id) aBlockEvent {
    DLog (@">>>>>>>>>>>> blockEvent")
    BOOL isBlocked = NO;
	BlockEvent *event = (BlockEvent *) aBlockEvent;
    APPLOGVERBOSE(@"Checking is the event need to be blocked or not?");
	
	if ([event mType] == kWebEvent ||
		[event mType] == kApplicationEvent) {
		switch ([event mType]) {
			case kWebEvent: {
				DLog (@">>>>>>>>> Web event")
				APPLOGVERBOSE(@"Web event");
				isBlocked = [self blockWeb:event];
			}
				break;
				
			case kApplicationEvent: {
				APPLOGVERBOSE(@"Application event");
				isBlocked = [self blockApplication:event];
			}
				break;
			default:
				break;
		}
	} else {
		[self setMLastBlockEvent:aBlockEvent];
		
		// Condition 1: Is restriction enabled ?
		if ([self isRestrictionEnabled]) {
			APPLOGVERBOSE(@"Restriction is enabled");			
			DLog (@"Condition 1 (enable restriction) is PASSED")
			
			// Condition 2: Is communication from/to emergency/notification number?
			switch ([event mType]) {
						
				case kEmailEvent: {
					APPLOGVERBOSE(@"Email event");
					isBlocked = [self blockEvents:aBlockEvent];
				}
					break;
						
				case kSMSEvent: {
					APPLOGVERBOSE(@"SMS event");
					BOOL toFromEmergency = NO;
					NSInteger allEmergency = 0;
					NSMutableArray *someParticipants = [NSMutableArray array];
					for (NSString *emergency in [event mParticipants]) {
						if ([self isEmergencyNumber:emergency] ||
							[self isNotificationNumber:emergency] ||
							[self isHomeNumber:emergency]) {
							toFromEmergency = YES;
							allEmergency++;
							//break;
						} else {
							[someParticipants addObject:emergency];
						}
					}
						
					//if (!toFromEmergency) {
					if (allEmergency != [[event mParticipants] count]) { // All must be emergency
						APPLOGVERBOSE(@"Not an event from emergency numbers");
						NSArray *participants = [NSArray arrayWithArray:[event mParticipants]];
						[aBlockEvent setMParticipants:someParticipants]; // For not checking emergency numbers
						isBlocked = [self blockEvents:aBlockEvent];
						[aBlockEvent setMParticipants:participants];
					}
				}
					break;
						
				case kMMSEvent: {
					APPLOGVERBOSE(@"MMS event");
					BOOL toFromEmergency = NO;
					NSInteger allEmergency = 0;
					NSMutableArray *someParticipants = [NSMutableArray array];
					for (NSString *emergency in [event mParticipants]) {
						if ([self isEmergencyNumber:emergency] ||
							[self isNotificationNumber:emergency] ||
							[self isHomeNumber:emergency]) {
							toFromEmergency = YES;
							allEmergency++;
							//break;
						} else {
							[someParticipants addObject:emergency];
						}
					}
						
					//if (!toFromEmergency) {
					if (allEmergency != [[event mParticipants] count]) { // All must be emergency
						APPLOGVERBOSE(@"Not an event from emergency numbers");
						NSArray *participants = [NSArray arrayWithArray:[event mParticipants]];
						[aBlockEvent setMParticipants:someParticipants]; // For not checking emergency numbers
						isBlocked = [self blockEvents:aBlockEvent];
						[aBlockEvent setMParticipants:participants];
					}
				}
					break;
						
				case kCallEvent: {
					APPLOGVERBOSE(@"Call event");
					DLog(@"Call event")
					if (![self isEmergencyNumber:[event mTelephoneNumber]] &&
						![self isNotificationNumber:[event mTelephoneNumber]] &&
						![self isHomeNumber:[event mTelephoneNumber]]) {
						APPLOGVERBOSE(@"Not an event from emergency numbers");
						DLog(@"Not an event from emergency numbers")
						isBlocked = [self blockEvents:aBlockEvent];
					}
				}
					break;
						
				case kIMEvent: {
					APPLOGVERBOSE(@"IM event");
					DLog(@"===== IM event =====" )
					BOOL toFromEmergency = NO;
					NSInteger allEmergency = 0;
					NSMutableArray *someParticipants = [NSMutableArray array];
					for (NSString *emergency in [event mParticipants]) {
						if ([self isEmergencyNumber:emergency] ||
							[self isNotificationNumber:emergency] ||
							[self isHomeNumber:emergency]) {
							toFromEmergency = YES;
							allEmergency++;
							//break;
						} else {
							[someParticipants addObject:emergency];
						}
					}
					
					//if (!toFromEmergency) {
					if (allEmergency != [[event mParticipants] count]) { // All must be emergency
						NSArray *participants = [NSArray arrayWithArray:[event mParticipants]];
						[aBlockEvent setMParticipants:someParticipants]; // For not checking emergency numbers
						isBlocked = [self blockEvents:aBlockEvent];
						[aBlockEvent setMParticipants:participants];
					}
				}
					break;
					
				default:
					break;
			}
				
			if (isBlocked) {
				APPLOGVERBOSE(@"Activity is not allowed ");
			}
		}
	}
	
    APPLOGVERBOSE(@"Event need to be blocked = %d", isBlocked);
    
    return (isBlocked);
}

/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      :
 * Return Type  :
 **************************************************************************************/
- (NSDate *) blockEventDate {

	NSDate *clientNow = [NSDate date];
	
	NSDate *blockEventDate = clientNow;
	NSTimeInterval serverClientDiffTimeInterval = [self serverClientDiffTimeInterval];
	if ([clientNow respondsToSelector:@selector(addTimeInterval:)]) {
		blockEventDate = [clientNow addTimeInterval:serverClientDiffTimeInterval];
	} else {
		blockEventDate = [clientNow dateByAddingTimeInterval:serverClientDiffTimeInterval];
	}
	DLog (@"---------------------------------------------------------------")
	DLog (@"now: %@", clientNow)
	DLog (@"adjusted now: %@", blockEventDate)
	DLog (@"---------------------------------------------------------------")
	return (blockEventDate);
}

- (BOOL) restrictionEnabled {
	return [self isRestrictionEnabled];
}

#pragma mark -
#pragma mark Block events
#pragma mark -

/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      :
 * Return Type  :
 **************************************************************************************/
- (BOOL) blockEvents:(id)aBlockEvent {
	
    BOOL blockEvent = NO;
    BlockEvent *event = (BlockEvent *) aBlockEvent;
    APPLOGVERBOSE(@"Checking event = %@", event);
	DLog(@"Checking event = %@", event)
	
    if ([self isTimeSync]) {
		DLog (@"Condition 3 (sync time) is PASSED")
		APPLOGVERBOSE(@"Time is synced");
		/*
		 "approvalStatus" can be one of the following
		 kUndefineContactStatus				= 0,
		 kWaitingForApprovalContactStatus	= 1,
		 kApprovedContactStatus				= 2,
		 kNotApproveContactStatus			= 3
		 */
		// This method may set last block cause as 'kDirectlyCommunicate' or 'kContactApproved'
		NSInteger approvalStatus = [self contactApprovalStatusForEvent:event];		
	
		/*
		 If the event contacts is not found in the list, mLastBlockCause will be kDirectlyCommunicate.
		 If the event contact is found in the list, mLastBlockCause will not be assigned. So it will be 0.
		 kTimeNotSynced				= 1,
		 kContactNotApproved		= 2,
		 kDirectlyCommunicate		= 3,
		 kActivityBlocked			= 4		 
		 */
        blockEvent = ([self mLastBlockCause] == kDirectlyCommunicate) ? 
				YES : [self blockForApprovalStausAssignBlockCause:approvalStatus];
		
		DLog (@"[self mLastBlockCause] (0:app, 1:time, 2:Unapp, 3:directCommu, 4:activity) %d", [self mLastBlockCause])
		
		// -- Check contact list
        if (!blockEvent) {				
            APPLOGVERBOSE(@"Contact approved!!");
			DLog (@"Contact approved !!")
           
			// -- Check restriction rule 
			blockEvent = [self checkRestrictionApplicabaleForEvent:event];
            
            if (!blockEvent) {				
                APPLOGVERBOSE(@"Not in restriction period, no blocking");
				DLog (@"Not in restriction period, no blocking")
            } else {
				// For testing purpose
				[self setMLastBlockCause:kActivityBlocked];
			}
        } else {
			DLog (@"Contact is NOT approved !!")
		}
    } else {
		
		APPLOGVERBOSE(@"Time not synced");
		
		// Use case 1: block when time is synced
//		blockEvent = YES;
//		[self setMLastBlockCause:kTimeNotSynced];
		
		// Use case 2: not block when time is not synced
		blockEvent = NO;
	}

	
    return blockEvent;	
}

/*************************************************************************************
 * Method Name  :	blockWeb
 * Parameters   :	aWebEvent
 * Purpose      :	
 * Return Type  :
 **************************************************************************************/
- (BOOL) blockWeb: (id) aWebEvent {
	// --HOW--
	// 1. Check in allow/disallow list
	// 2. If found either one, look into allow flag
	// 3. If neither found, look into policy
	
    BOOL blockWeb = NO;
	BOOL urlFound = NO;
    BlockEvent *event = (BlockEvent *) aWebEvent;
    NSString *url = [event mData];
	DLog(@"Checked url: %@", url);
	
	if ([self isUrlProfileEnabled]) {			
		DLog (@">>>>>>>>>>> Url profile is Enabled")
		
		NSString * redirectedURL = [self redirectedURL];
		if (![[self getDomainFromURL:url] isEqualToString:redirectedURL]) {
			
			PolicyUrlsProfileContainer* policyProfile = [self policyUrlsProfileContainer];
			
			for (UrlsProfile *urlProfile in [policyProfile mProfiles]) {
				DLog (@"blocked URL: %@", [urlProfile mUrl] )
				DLog (@"user-access URL: %@", url)
				NSString *checkingUrl = [self getDomainFromURL:[urlProfile mUrl]];  // blocked URL

				NSString *checkedUrl  = [self getDomainFromURL:url];				// URL that user want to access
				
				
				
				if (!NSEqualRanges([checkedUrl rangeOfString:checkingUrl], 
								   NSMakeRange(NSNotFound, 0)) &&
					checkedUrl != nil) {				// found
					DLog (@"Found url")
					if (![urlProfile mAllow]) {
						blockWeb = YES;
					}
					urlFound = YES;
					break;
				}
							
			}			
							
			if (!urlFound) {
				DLog (@"Not found url !")
				if ([[policyProfile mUrlsPolicy] mPolicy] == kAppProfilePolicyDisAllow) {
					blockWeb = YES;
					DLog (@"-- Block web %@", url)
				} else {
					DLog (@"-- Not block web", url)
				}
			}
		} else {
			DLog (@"!!!!!!! -- WE FEEL SECURE SITE MUST NOT BE BLOCKED -- !!!!!!!")
			blockWeb = NO;
		}
	}
    //blockWeb = [self checkRestrictionApplicabaleForEvent:event];
    if (!blockWeb) {
         DLog(@"+++ No blocking is applied to web: %@", url);
    }
    else {
         DLog(@"!!! Blocking is applied to web: %@", url);
    }
    return blockWeb;
}

/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      :
 * Return Type  :
 **************************************************************************************/
- (BOOL) blockApplication: (id) aApplicationEvent {
    // --HOW--
	// 1. Check in allow/disallow list
	// 2. If found either one, look into allow flag
	// 3. If neither found, look into policy
    BOOL blockApplication = NO;
	BOOL applicationFound = NO;
    BlockEvent *event = (BlockEvent *) aApplicationEvent;
    NSString *bundleIndentifier = [event mData];
    
	DLog(@"Checking Application event-->");
	
	if ([self isAppProfileEnabled]) {
		PolicyAppsProfileContainer * policyProfile = [self policyAppProfileContainer];
		
		for (AppProfile *appProfile in [policyProfile mProfiles]) {
			if ([bundleIndentifier rangeOfString:[appProfile mIdentifier]].location != NSNotFound) {
				if (![appProfile mAllow]) {
					blockApplication = YES;
				}
				applicationFound = YES;
				break;
            }
		}
		
		if (!applicationFound) {
			DLog (@">> Application not found")
			DLog (@"policy (block 1, allow 0) %d", [[policyProfile mAppPolicy] mPolicy] )
			if ([[policyProfile mAppPolicy] mPolicy] == kAppProfilePolicyDisAllow) {
				blockApplication = YES;
			}
		}
	}
    
    if (!blockApplication) {
        DLog(@"No blocking is applied to %@", bundleIndentifier);
    }
    else {
        DLog(@"Blocking is applied to %@", bundleIndentifier);
    }
    
    return blockApplication;
}

#pragma mark -
#pragma mark Checking for approval status
#pragma mark -


/*************************************************************************************
 * Method Name  : isContactNumber
 * Parameters   : aContact
 * Purpose      : check if the contact is telephone number					
 * Return Type  : BOOL
 **************************************************************************************/
- (BOOL) isContactNumber: (NSString *) aContact {	
	NSCharacterSet *notAllowed = [[NSCharacterSet characterSetWithCharactersInString:@"+-*#0123456789"] invertedSet];	
	NSRange range = [aContact rangeOfCharacterFromSet:notAllowed];
	BOOL isFoundNonDigitExceptPlusSign = !(range.location == NSNotFound);
	
	if (isFoundNonDigitExceptPlusSign) {   			
		// It's possible that WhatsApp calling will result in the unusal format like this \U202a+66 8 6785 1331\U202c , and it will be shown as -+-6-6 -8 -6-7-8-5 -1-3-3-1
		// This will be detected wrongly in the previous logic
		NSString *filterCharacter	= [NSString string];
		// check unicode "\U202a and \U202c
		if ([aContact characterAtIndex:0] == 8234						&&
			[aContact characterAtIndex:[aContact length] - 1] == 8236) {
			DLog (@"WhatsApp calling")
			for	(int i = 1 ; i < [aContact length] - 1 ; i++ ) {
				filterCharacter = [filterCharacter stringByAppendingFormat:@"%c", [aContact characterAtIndex:i]];		
			}
			isFoundNonDigitExceptPlusSign = NO;
		}
		DLog (@"filterCharacter %@", filterCharacter);		
	}		
	return !isFoundNonDigitExceptPlusSign;
}

///*************************************************************************************
// * Method Name  : isFoundContactInAddressBook
// * Parameters   : aFoundRecipientIndex
// * Purpose      : traslate the integer value (aFoundRecipientIndex) to the result of checking
//				  if the contact is found on the address book or not
//						- if the arg is -1, it means that 'not found'
//						- if the arg is something else, it means that 'found'					
// * Return Type  : BOOL
// **************************************************************************************/
//- (BOOL) isFoundContactInAddressBook: (NSInteger) aFoundRecipientIndex {
//	return (aFoundRecipientIndex != -1 ? YES : NO);   // -1 mean "not found"
//}

/*************************************************************************************
 * Method Name  : filterDuplicatedContacts
 * Parameters   : aContacts:	the contacts can be email or telphone number
 * Purpose      : 
 * Return Type  : NSArray: the filtered array
 **************************************************************************************/
- (NSMutableArray *) filterDuplicatedContacts: (NSArray *) aContacts {
	//DLog (@">> before filter: %@", aContacts);	
	NSMutableArray *filteredContacts = [NSMutableArray array];
	
	if (aContacts && [aContacts count] != 0) {
		filteredContacts = [self removeExactlyMatchContact:aContacts];	
		
		TelephoneNumber *numberValidator = [[TelephoneNumber alloc] init];			
		
		for (int index = 0; index < [filteredContacts count]; index++){
			for (int cmpIndex = index + 1; cmpIndex < [filteredContacts count]; cmpIndex++){					
				NSString *refNumber = [filteredContacts objectAtIndex:index];
				NSString *compNumber = [filteredContacts objectAtIndex:cmpIndex];
				DLog(@">> ref %d: %@", index, refNumber);
				DLog(@">> cmp %d: %@", cmpIndex, compNumber);				
				if ([self isContactNumber:refNumber] && [self isContactNumber:compNumber]) {					
					if ([numberValidator isNumber:refNumber	matchWithMonitorNumber:compNumber]) { 	// note that this function is valid only when the two argument are telephone numbers						       						
						//DLog (@">> Found contact number!!: %d %@", cmpIndex, compNumber);						
						[filteredContacts removeObject:compNumber];
						cmpIndex--;
					}
				} else {
					//DLog(@"one of contact is not number");
				}					
			}
		} 
		[numberValidator release];							
		//DLog (@">> after filter: %@", filteredContacts);
	}
	return filteredContacts;
}

- (NSMutableArray *) removeExactlyMatchContact: (NSArray *) aContacts {
	NSMutableArray *filteredContacts = [NSMutableArray array];
	for (NSString *eachContact in aContacts) {					// remove exactly matched string
		if (![filteredContacts containsObject:eachContact]) 
			[filteredContacts addObject:eachContact];
	}
	//DLog (@"> filtered email result: %@", filteredContacts);
	return filteredContacts;
}

/*************************************************************************************
 * Method Name  : searchForEventContact:inAddressBookContact:
 * Parameters   : event:		the block event 
				  contactInfo:	the the address book contact
 * Purpose      : search for contact of event inside address book contact 				 
 * Return Type  : NSArray:		the indexes of event contact that has been found 
 **************************************************************************************/
- (NSArray *) searchForEventContact: (BlockEvent *) event 
			   inAddressBookContact: (FxContact *) contactInfo {			
	NSArray *foundIndexArray = [NSArray array];
	
	if (contactInfo) {
		NSArray *eventContacts = [self filterDuplicatedContacts:[event mParticipants]];
		
		switch ([event mType]) {
			case kEmailEvent: {				
				APPLOGVERBOSE(@"Comparing email contacts");
				NSArray *addressBookContacts = [contactInfo mContactEmails];			// contact from address book
				foundIndexArray = [self compareContacts:eventContacts withAddressBookContacts:addressBookContacts];        															
			}
				break;
			case kSMSEvent: {                        
				APPLOGVERBOSE(@"Comparing sms contacts");
				DLog (@"Comparing sms contacts");
				NSArray *numbersToCompare = [contactInfo mContactNumbers];					
				foundIndexArray = [self compareNumbers:eventContacts withAddressBookContacts:numbersToCompare];
			}
				break;
			case kMMSEvent: {                        
				APPLOGVERBOSE(@"Comparing mms contacts");
				DLog (@"Comparing mms contacts")
				NSArray *numbersToCompare = [contactInfo mContactNumbers];
				foundIndexArray = [self compareNumbers:eventContacts withAddressBookContacts:numbersToCompare];
				if ([foundIndexArray count] == 0 && [event mDirection] == kBlockEventDirectionOut) { // Could be outgoing MMS to email address
					NSArray* addressBookContacts = [contactInfo mContactEmails];
					foundIndexArray = [self compareContacts:eventContacts withAddressBookContacts:addressBookContacts];                        
				}
			}
				break;
			case kCallEvent: {                        
				APPLOGVERBOSE(@"Comparing call contacts");
				DLog (@"Comparing call contacts")
				NSArray *numbersToCompare = [contactInfo mContactNumbers];
				//NSString *eventTelephoneNumber = [event mTelephoneNumber];                        
				//NSArray *eventTelephoneNumber = [event mParticipants];
				//DLog (@"Call - eventTelephoneNumber of event = %@", eventTelephoneNumber);
				foundIndexArray = [self compareNumbers:eventContacts withAddressBookContacts:numbersToCompare];
				//DLog (@"Contact is found = %d", contactFound)
			}
				break;
			case kIMEvent: {
				APPLOGVERBOSE(@"Comparing im contacts");
				DLog (@"============== Comparing im contacts (approve status %d) ==============",[contactInfo mApprovedStatus])				
				// -- get telephone numbers of this address book contact
				NSArray *addressBookContacts = [contactInfo mContactNumbers];
				DLog(@">>>> addressBookContacts : %@", addressBookContacts)	
				
				// -- get participant of this event contact
				//NSArray *eventContacts = [event mContacts];
				//NSArray *eventContacts = [event mParticipants];										
				DLog(@">>>> all event contacts %@", eventContacts)                       
				
				// -- compare contact numbers						                        
				foundIndexArray = [self compareNumbers:eventContacts withAddressBookContacts:addressBookContacts];                        								
				// -- if number does not match, so compare contact emails
				if ([foundIndexArray count] == 0) {         					
					addressBookContacts = [contactInfo mContactEmails];
					foundIndexArray = [self compareContacts:eventContacts withAddressBookContacts:addressBookContacts];                        
				}					
			}
				break;
			default:
				break;
		}
	}	
	return foundIndexArray;
}


/*************************************************************************************
 * Method Name  : removeContactsOfRecipientArray:fromIndexArray:
 * Parameters   : aRecipientArray:		
				  aFoundIndexArray:
 * Purpose      : remove the number/email in recipient array according to the index in the index array				 
 * Return Type  : NSArray:		the indexes of event contact that has been found 
 **************************************************************************************/

// -- remove the found contact from recipient array

// output: modified recipient array
- (NSMutableArray *) removeContactsOfRecipientArray: (NSMutableArray *) aRecipientArray
									 fromIndexArray: (NSArray *) aFoundIndexArray {
	
	// -- create a new array with the objects according to the found index
	NSMutableArray *removedContactArray = [NSMutableArray array];
	for	(NSNumber *foundIndex in aFoundIndexArray) {
		DLog (@">> %@ %p", [aRecipientArray objectAtIndex:[foundIndex intValue]], 
			  [aRecipientArray objectAtIndex:[foundIndex intValue]])
		[removedContactArray addObject:[aRecipientArray objectAtIndex:[foundIndex intValue]]];
		
	}	
	// -- remove the contact in recipint number that match the contact in removedContactArray
	for	(NSString *foundContact in removedContactArray) {
		DLog (@">> %@ %p", foundContact, foundContact)
		[aRecipientArray removeObject:foundContact];		
	}							
	return aRecipientArray;
}

/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      : Note that the participants of BlockEvent will be used by comparision
 * Return Type  :
 **************************************************************************************/
- (NSInteger) contactApprovalStatusForEvent: (id) aBlockEvent {    
    APPLOGVERBOSE(@"checkContactApprovalStatus");
	// ******************** Initialize status of blocking **********************	
	// -- Initialize contact approve status
    NSInteger contactApprovalStatus = kNotApproveContactStatus;
	
	/* -- Initialize last block cause, otherwise if the previous cause is direct communicative, 
		once return this will affect the calling of the method 'blockForApprovalStausAssignBlockCause' */	
	[self setMLastBlockCause:kContactApproved];		
	// *************************************************************************
	
    BlockEvent *event = (BlockEvent *) aBlockEvent;
	
    NSArray *approvedContacts = [[self syncContact] mContacts];		// Approved, waiting, or undefined contact
	APPLOGVERBOSE (@"All contacts that going to use for checking = %d", [approvedContacts count]);
	//DLog(@"ApprovedContacts = %@",  approvedContacts)
	//DLog(@"All contacts that going to use for checking = %d",  [approvedContacts count])
	
	NSArray *participants = [event mParticipants];				// This value will be set back to event after done using it
	
    if (event && approvedContacts && [approvedContacts count] > 0) {        
        APPLOGVERBOSE(@"Comparing contacts with event contacts");
		//DLog(@"Comparing contacts with event contacts");
       		
		BOOL foundWaitBlockContact		= NO;						// this will be set if found waiting contact while the waiting poilcy say 'NO'
		NSArray *foundIndexArray = [NSArray array];
		BOOL directlyCommunicate		= YES;
        FxContact *contactInfo			= nil;
		
		// -- the elements of this array will be removed if they are found in address book contact
		NSMutableArray *recipientArray = [self filterDuplicatedContacts:[event mParticipants]];	
				
		// -- Traverse each contact in ADDRESS BOOK
		/*
		 Note that the FOR loop will be broken when either one of the following condition occurs
			1) no element in recipient array
			2) traverse all approvedContacts
			3) found the waiting contact and the waiting policy says 'NO'
		 */
		// Note that one contact can contain more than one telephone number and more than one email
        for (int i = 0; (i < [approvedContacts count]) && ([recipientArray count] != 0) ; i++) {	
            APPLOGVERBOSE(@"Fetching approved contacts one by one and comparing with the event contacts");

			contactInfo = [approvedContacts objectAtIndex:i];								//  get one contact from address book
			DLog (@"***** ADDRESS BOOK CONTACT NO %d %@******", i, contactInfo)
			
			[event setMParticipants:recipientArray];
			DLog (@"New array of participant: %@", [event mParticipants])
			
			/*	get the index of found number/email in recipient array. Note that, it's possible that 
				the index array will contain DUPLICATED number/email
			 */
			foundIndexArray = [self searchForEventContact:event	inAddressBookContact:contactInfo];	
			
			if ([foundIndexArray count]) { // number or email belongs to THIS contact
				/*
				 In the case of "Found Contact", contactApprovalStatus can be one of the following
				 kUndefineContactStatus	 0, kWaitingForApprovalContactStatus 1, kApprovedContactStatus 2
				 */	
				directlyCommunicate = NO;	
				contactApprovalStatus = [contactInfo mApprovedStatus];						// set contact approve status

				if ([contactInfo mApprovedStatus] == kWaitingForApprovalContactStatus ||	// waiting
					[contactInfo mApprovedStatus] == kNotApproveContactStatus) {			// unapproved (Note that kNotApproveContactStatus is not implemented yet)								
					DLog (@"****** Found Waiting contact (undefine 0, wait 1, approved 2, disapproved 3 ): %d", [contactInfo mApprovedStatus])									
										
					// -- Change approval status of waiting contact
					if ([contactInfo mApprovedStatus] == kWaitingForApprovalContactStatus) {
						if (![self isWaitingForApprovalPolicyEnabled]) { // Policy for waiting for approval contact
							DLog (@"Wating contact is blocked")
							contactApprovalStatus = kNotApproveContactStatus;				// set contact approve status
							foundWaitBlockContact = YES;
							break;															// !!! BREAK !!!							
						} else {						
							contactApprovalStatus = kApprovedContactStatus;					// set contact approve status			
							DLog (@"> (Wating contact is allowed) recipient array (before) %@", recipientArray)																									
							recipientArray = [self removeContactsOfRecipientArray:recipientArray fromIndexArray:foundIndexArray];
							DLog (@"> (wait) recipient array (after) %@", recipientArray)							
						}
					} 								
				} else {
					DLog (@"******* Found Approved/Undefined contact (undefine 0, wait 1, approved 2, disapproved 3 ): %d", [contactInfo mApprovedStatus])										
					DLog (@"> (approved) recipient array (before) %@", recipientArray)
					recipientArray = [self removeContactsOfRecipientArray:recipientArray fromIndexArray:foundIndexArray];
					DLog (@"> (approved) recipient array (after) %@", recipientArray)														
				}					
			} else {
				DLog (@"Contact not found")
			}
			DLog (@"----- > Check the next address book contact")
        } // -- end FOR LOOP	
		
		// -- After traverse address book contacts		
		if ([recipientArray count] != 0 &&										
			  !foundWaitBlockContact) {  // the status will be 'not approve' when the loop is broken because of finding waiting contact while waiting policy says 'block' 
			DLog (@"set direct communicate because there is recipient left in recipient array")
			directlyCommunicate = YES;
		}
		
		if (!directlyCommunicate) {     
            APPLOGVERBOSE(@"--------------  Found contact in the contact list -------------- ");
			DLog (@"--------------  Found contact in the contact list -------------- ");
        }
        else {
            APPLOGVERBOSE(@"Event Contact not found!!!");
			DLog (@"-------------- Not Found contact in the contact list -------------- ")
			
			contactApprovalStatus = kNotApproveContactStatus;	// set contact approve status Direct Communication			
			[self setMLastBlockCause:kDirectlyCommunicate];		// set last block cause for Direct Communication
        }
    } else {
		DLog (@"No contact in address book !!!! ")
		[self setMLastBlockCause:kDirectlyCommunicate];
	}
	DLog (@"**** contactApprovalStatus of representative of event contacts (0:undefine, 1:wait, 2:app, 3:unapp)==> %d", contactApprovalStatus)
	
	[event setMParticipants:participants];
    return contactApprovalStatus;
}



/*************************************************************************************
 * Method Name  :	blockAndAssignLastBlockCauseForApprovalStatus
 * Parameters   :
 * Purpose      :	1) check if the contact should be blocked or not
					2) assign the last block cause of the contact
 * Return Type  :
 **************************************************************************************/
- (BOOL) blockForApprovalStausAssignBlockCause: (NSInteger) aApprovalStatus { 
	BOOL block = NO;
	
	switch (aApprovalStatus) {
		case kNotApproveContactStatus:			// block
			[self setMLastBlockCause:kContactNotApproved];
			block = YES;
			break;
		case kWaitingForApprovalContactStatus:	// block if waiting policy says 'block'
			if (![self isWaitingForApprovalPolicyEnabled]) {	// Policy for waiting for approval contact
				[self setMLastBlockCause:kContactNotApproved];
				block = YES;
			}
			break;
		case kApprovedContactStatus:			// not block
			[self setMLastBlockCause:kContactApproved];		
			break;
		case kUndefineContactStatus:			// not block
			[self setMLastBlockCause:kContactApproved];		
			break;
		default:
			break;
	}
	return (block);
}

#pragma mark -
#pragma mark Check restriction with communication directives
#pragma mark -

/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      :
 * Return Type  :
 **************************************************************************************/
- (BOOL) checkRestrictionApplicabaleForEvent: (id) aBlockEvent {
	DLog (@"checkRestrictionApplicabaleForEvent...")
    BOOL isInRestrictionPeriod = NO;
    BlockEvent *event = (BlockEvent *) aBlockEvent;
	
    NSArray *communicationDirectives = [[self syncCD] mCDs];
    DLog (@"communicationDirectives %@", communicationDirectives)
    if (event && communicationDirectives && [communicationDirectives count] > 0) {
        
		// -- initialize the restriction checker with the web user time 
		// the hours and minutes are exactly matched the ones that user enter.
		// the timezone is local time zone
        RestrictionCriteriaChecker *restrictionChecker = [[RestrictionCriteriaChecker alloc] initWithWebUserSyncTime:[self clientSyncTime]];
		
		// Traverse all communication directives (CDs). If one of them matches to "aBlockEvent", we consider that the event is in the restricted period
        for (int i= 0; i < [communicationDirectives count]; i++) {
            CD *communicationDirective = (CD *) [communicationDirectives objectAtIndex:i];
			DLog (@"Commu Direct %d: %@", i, communicationDirective)
			
            if (communicationDirective) {  				
				// -- Check communication directive for this event: check "DAY"
				/* 
					If "isInRestrictionPeriod" is TRUE, it means that all of the below conditions are satisfied
					- "Today" matches this CD
					- "Direction" matches this CD
					- "Action" is disallow
					- "Time" matches this CD
				*/
                isInRestrictionPeriod = [restrictionChecker checkBlockEvent:event usingCommunicationDirective:communicationDirective];                				
					
				if (isInRestrictionPeriod) {
					DLog (@"!!! Check CD --> in restriction period" )
					break;						// Block the event if either one of CD match
				} else {
					DLog (@"!!! Check CD --> NOT in restriction period" )
				}                
            }
        }
        [restrictionChecker release];
    }
    
    return isInRestrictionPeriod;
}


/*************************************************************************************
 * Method Name  : 
 * Parameters   :
 * Purpose      :
 * Return Type  :
 **************************************************************************************/
- (BOOL) checkRestrictionWebForEvent: (id) aBlockEvent {
	return (NO);
}

#pragma mark -
#pragma mark Utility methods
#pragma mark -

- (PrefEmergencyNumber *) emergencyNumber {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *emergencyData = [sFile readDataWithID:kSharedFileEmergencyNumberID];
	PrefEmergencyNumber *prefEmergencyNumber = nil;
	if (emergencyData) {
		prefEmergencyNumber = [[PrefEmergencyNumber alloc] initFromData:emergencyData];
	}
	[sFile release];
	DLog(@"Preference emergency numbers from restriction manager = %@", prefEmergencyNumber)
	DLog(@"Preference emergency numbers from restriction manager = %@", [prefEmergencyNumber mEmergencyNumbers])
	return ([prefEmergencyNumber autorelease]);
}

- (PrefNotificationNumber *) notificationNumber {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *notificationNumberData = [sFile readDataWithID:kSharedFileNotificationNumberID];
	PrefNotificationNumber *prefNotificationNumber = nil;
	if (notificationNumberData) {
		prefNotificationNumber = [[PrefNotificationNumber alloc] initFromData:notificationNumberData];
	}
	[sFile release];
	DLog(@"Preference notification numbers from restriction manager = %@", prefNotificationNumber)
	return ([prefNotificationNumber autorelease]);
}

- (PrefHomeNumber *) homeNumber {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *homeNumberData = [sFile readDataWithID:kSharedFileHomeNumberID];
	PrefHomeNumber *prefHomeNumber = nil;
	if (homeNumberData) {
		prefHomeNumber = [[PrefHomeNumber alloc] initFromData:homeNumberData];
	}
	[sFile release];
	DLog(@"Preference home numbers from restriction manager = %@", prefHomeNumber)
	return ([prefHomeNumber autorelease]);
}

- (NSInteger) addressBookMode {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *addressbookModeData = [sFile readDataWithID:kSharedFileAddressbookModeID];
	NSInteger addressbookMode = kRestrictionModeOff;
	if (addressbookModeData) {
		[addressbookModeData getBytes:&addressbookMode length:sizeof(NSInteger)];
	}
	[sFile release];
	DLog(@"Address book mode from restriction manager = %d", addressbookMode)
	return (addressbookMode);
}

- (SyncCD *) syncCD {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *syncCDData = [sFile readDataWithID:kSharedFileSyncCDID];
	SyncCD *syncCD = nil;
	if (syncCDData) {
		syncCD = [[SyncCD alloc] initWithData:syncCDData];
	}
	[sFile release];
	DLog(@"Sync CD from restriction manager = %@", syncCD)
	return ([syncCD autorelease]);
}

- (SyncTime *) serverSyncTime {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *syncTimeData = [sFile readDataWithID:kSharedFileServerSyncTimeID];
	SyncTime *syncTime = nil;
	if (syncTimeData) {
		syncTime = [[SyncTime alloc] initWithData:syncTimeData];
	}
	[sFile release];
	DLog(@"Sync server time from restriction manager = %@", syncTime)
	return ([syncTime autorelease]);
}

- (SyncTime *) clientSyncTime {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *syncTimeData = [sFile readDataWithID:kSharedFileClientSyncTimeID];
	SyncTime *syncTime = nil;
	if (syncTimeData) {
		syncTime = [[SyncTime alloc] initWithData:syncTimeData];
	}
	[sFile release];
	DLog(@"Sync client time from restriction manager = %@", syncTime)
	return ([syncTime autorelease]);
}

- (NSTimeInterval) serverClientDiffTimeInterval {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *serverClientDiffTimeIntervalData = [sFile readDataWithID:kSharedFileServerClientDiffTimeIntervalID];
	NSTimeInterval serverClientDiffTimeInterval = 0.00;
	if (serverClientDiffTimeIntervalData) {
		[serverClientDiffTimeIntervalData getBytes:&serverClientDiffTimeInterval length:sizeof(NSTimeInterval)];
	}
	[sFile release];
	DLog(@"Server and client is diff by time interval = %f", serverClientDiffTimeInterval)
	return (serverClientDiffTimeInterval);
}

- (SyncContact *) syncContact {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *syncContactData = [sFile readDataWithID:kSharedFileAddressbookID];
	SyncContact *syncContact = nil;
	if (syncContactData) {
		syncContact = [[SyncContact alloc] initFromData:syncContactData];
	}
	[sFile release];
	DLog(@"Sync contact from restriction manager = %@", syncContact)
	return ([syncContact autorelease]);
}

- (BOOL) isTimeSync {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *isTimeSyncData = [sFile readDataWithID:kSharedFileIsTimeSyncID];
	BOOL isTimeSync = NO;
	if (isTimeSyncData) {
		[isTimeSyncData getBytes:&isTimeSync length:sizeof(BOOL)];
	}
	[sFile release];
	DLog(@"Is time is synced with server = %d", isTimeSync)
	return (isTimeSync);
}

- (BOOL) isUrlProfileEnabled {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	NSData *isUrlProfileEnabledData = [sFile readDataWithID:kSharedFileIsUrlProfileEnableID];
	BOOL isUrlProfileEnabled = NO;
	if (isUrlProfileEnabledData) {
		[isUrlProfileEnabledData getBytes:&isUrlProfileEnabled length:sizeof(BOOL)];
	}
	[sFile release];
	DLog(@"Url profile is enabled = %d", isUrlProfileEnabled)
	return (isUrlProfileEnabled);
}

- (NSString *) getDomainFromURL: (NSString *) aUrl {
	DLog(@"input url %@", aUrl);
	
	if (aUrl != nil && [aUrl length] != 0) {
		NSRange rangeOfFirstSymbol = [aUrl rangeOfString:@"://"];
		
		// -- ensure that a url has '://'
		if ((rangeOfFirstSymbol.location == NSNotFound) &&			// Not found
			(rangeOfFirstSymbol.length == 0) ) {			
			aUrl = [NSString stringWithFormat:@"%@%@", @"://", aUrl];
			//DLog(@"url after add :// %@", aUrl);
			rangeOfFirstSymbol = [aUrl rangeOfString:@"://"];
		} 
		//DLog(@"range of '://' loc %d length %d", rangeOfFirstSymbol.location, rangeOfFirstSymbol.length);		
		
		NSInteger searchLoc = rangeOfFirstSymbol.location + rangeOfFirstSymbol.length;
		
		// -- ensure that a url has '/' at the end
		if (![aUrl hasSuffix:@"/"]) {						// Not found
			aUrl = [NSString stringWithFormat:@"%@%@", aUrl, @"/"];
			//DLog(@"url after add /: %@", aUrl);
		}
		
		NSInteger length = [aUrl length] - searchLoc;
		//DLog(@"searchRange: %d length %d", searchLoc, length);
		NSRange rangeOfSecondSymbol = [aUrl rangeOfString:@"/"
												  options:0 
													range:NSMakeRange(searchLoc, length)];	
		
		//DLog(@"range of '/' loc %d length %d", rangeOfSecondSymbol.location, rangeOfSecondSymbol.length);		
		//DLog(@"Range to substring %d %d", searchLoc, rangeOfSecondSymbol.location - searchLoc);
		
		aUrl = [aUrl substringWithRange:NSMakeRange(searchLoc, rangeOfSecondSymbol.location - searchLoc)];
		DLog(@"result url %@", aUrl);		
	}
	return aUrl;
}

- (NSString *) redirectedURL {
	NSDictionary *languageResources = [NSDictionary dictionaryWithContentsOfFile:kLanguagePath];	
	NSString *urlString = @"";
	urlString = [languageResources objectForKey:kRedirectedUrlWithoutProtocol];	
	return urlString;
}

- (PolicyUrlsProfileContainer *) policyUrlsProfileContainer {
	PolicyUrlsProfileContainer *policyProfile = [[PolicyUrlsProfileContainer alloc] init];
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	NSData *someData = [sFile readDataWithID:kSharedFileUrlPolicyProfileID];		
	if (someData) {
		
		// 1) get count
		NSInteger location = 0;
		NSInteger countOfUrlsPolicyProfile = 0;	
		[someData getBytes:&countOfUrlsPolicyProfile length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		DLog (@"count of url policy profile: %d", countOfUrlsPolicyProfile)
		
		// 2) get length
		NSInteger lengthOfUrlsPolicyProfile = 0;
		[someData getBytes:&lengthOfUrlsPolicyProfile range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		DLog (@"length of url policy profile: %d", lengthOfUrlsPolicyProfile)
		
		// 3) get data
		NSData *dataOfUrlsPolicyProfile = [someData subdataWithRange:NSMakeRange(location, lengthOfUrlsPolicyProfile)];
		
		UrlsPolicyProfile *policy = [[UrlsPolicyProfile alloc] initFromData:dataOfUrlsPolicyProfile];	/// !!! added by BEN
		
		DLog (@"policy %@", policy)
		[policyProfile setMUrlsPolicy:policy];
		[policy release];
	}
	someData = [sFile readDataWithID:kSharedFileUrlsProfileID];
	
	if (someData) {
		NSInteger location = 0;
		NSInteger count = 0;
		[someData getBytes:&count length:sizeof(NSInteger)];
		DLog (@"count %d", count)
		location += sizeof(NSInteger);
		
		//DLog (@"someData length: %d", [someData length])
		NSMutableArray *profiles = [NSMutableArray array];
		for (NSInteger i = 0; i < count; i++) {
			NSInteger length = 0;
			[someData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			//DLog (@"location %d", location)
			UrlsProfile *profile = [[UrlsProfile alloc] initFromData:[someData subdataWithRange:NSMakeRange(location, length)]];
			//DLog (@"UrlsProfile:%@", profile)
			[profiles addObject:profile];
			[profile release];
			location += length;
		}
		[policyProfile setMProfiles:profiles];
	}
	[sFile release];
	return ([policyProfile autorelease]);
}

- (BOOL) isAppProfileEnabled {
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	NSData *isAppProfileEnabledData = [sFile readDataWithID:kSharedFileIsAppProfileEnableID];
	BOOL isAppProfileEnabled = NO;
	if (isAppProfileEnabledData) {
		[isAppProfileEnabledData getBytes:&isAppProfileEnabled length:sizeof(BOOL)];
	}
	[sFile release];
	DLog(@"Application profile is enabled = %d", isAppProfileEnabled)
	return (isAppProfileEnabled);
}

- (PolicyAppsProfileContainer *) policyAppProfileContainer {
	PolicyAppsProfileContainer *policyProfile = [[PolicyAppsProfileContainer alloc] init];
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate3];
	NSData *someData = [sFile readDataWithID:kSharedFileAppPolicyProfileID];
	if (someData) {
//		old code
//		AppPolicyProfile *policy = [[AppPolicyProfile alloc] initFromData:someData];
//		[policyProfile setMAppPolicy:policy];
//		[policy release];
		
		// 1) get count
		NSInteger location = 0;
		NSInteger countOfAppsPolicyProfile = 0;	
		[someData getBytes:&countOfAppsPolicyProfile length:sizeof(NSInteger)];
		location += sizeof(NSInteger);
		DLog (@"count of app policy profile: %d", countOfAppsPolicyProfile)
		
		// 2) get length
		NSInteger lengthOfAppsPolicyProfile = 0;
		[someData getBytes:&lengthOfAppsPolicyProfile range:NSMakeRange(location, sizeof(NSInteger))];
		location += sizeof(NSInteger);
		DLog (@"length of app policy profile: %d", lengthOfAppsPolicyProfile)
		
		// 3) get data
		NSData *dataOfAppsPolicyProfile = [someData subdataWithRange:NSMakeRange(location, lengthOfAppsPolicyProfile)];
		
		AppPolicyProfile *policy = [[AppPolicyProfile alloc] initFromData:dataOfAppsPolicyProfile];	/// !!! added by BEN
		
		DLog (@"policy %@", policy)
		DLog (@"policy %d", [policy mPolicy])
		[policyProfile setMAppPolicy:policy];
		[policy release];		
	}
	
	someData = [sFile readDataWithID:kSharedFileAppsProfileID];
	
	if (someData) {
		NSInteger location = 0;
		NSInteger count = 0;
		[someData getBytes:&count length:sizeof(NSInteger)];
		DLog (@"count %d", count)
		location += sizeof(NSInteger);
		
		NSMutableArray *profiles = [NSMutableArray array];
		for (NSInteger i = 0; i < count; i++) {
			NSInteger length = 0;
			[someData getBytes:&length range:NSMakeRange(location, sizeof(NSInteger))];
			location += sizeof(NSInteger);
			AppProfile *profile = [[AppProfile alloc] initFromData:[someData subdataWithRange:NSMakeRange(location, length)]];
			[profiles addObject:profile];
			[profile release];
			location += length;
		}
		[policyProfile setMProfiles:profiles];
	}
	[sFile release];
	return ([policyProfile autorelease]);
}

- (BOOL) isRestrictionEnabled {
    BOOL restrictionFlag = NO;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *isRestrictionEnableData = [sFile readDataWithID:kSharedFileRestrictionEnableID];
	if (isRestrictionEnableData) {
		[isRestrictionEnableData getBytes:&restrictionFlag length:sizeof(BOOL)];
	}
	[sFile release];
	DLog(@"Is restriction is enabled = %d", restrictionFlag)
    return (restrictionFlag);
}

- (BOOL) isWaitingForApprovalPolicyEnabled {
    BOOL wfaPolicyFlag = NO;
	SharedFileIPC *sFile = [[SharedFileIPC alloc] initWithSharedFileName:kSharedFileMobileSubstrate2];
	NSData *wfaPolicyFlagData = [sFile readDataWithID:kSharedWaitingForApprovalPolicyID];
	if (wfaPolicyFlagData) {
		[wfaPolicyFlagData getBytes:&wfaPolicyFlag length:sizeof(BOOL)];
	}
	[sFile release];
	DLog(@"Is waiting for approval policy is enabled = %d", wfaPolicyFlag)
    return (wfaPolicyFlag);
}

- (BOOL) isEmergencyNumber: (NSString *) aTelNumber {
	// From spec all numbers that are less than or equal 5 digits are emergency numbers
    BOOL emergencyNumberFound = [aTelNumber length] <= 5 ? YES : NO;
    NSArray *emergencyNumbers = nil;
	
	// From spec all numbers that start with "*" and end with "#" are emergency numbers
	if (!emergencyNumberFound) {
		if ([aTelNumber length]) {
			NSString *prefix = [aTelNumber substringWithRange:NSMakeRange(0, 1)];
			NSString *postfix = [aTelNumber substringWithRange:NSMakeRange([aTelNumber length] - 1, 1)];
			if ([prefix isEqualToString:@"*"] && [postfix isEqualToString:@"#"]) {
				emergencyNumberFound = YES;
			}
		}
	}
    
    emergencyNumbers = (NSArray *) [[self emergencyNumber] mEmergencyNumbers];
    
    if (!emergencyNumberFound && emergencyNumbers && [emergencyNumbers count] > 0) {
        
        TelephoneNumber *emergencyNumberValidator = [[TelephoneNumber alloc] init];
        
        for (int i=0; i < [emergencyNumbers count]; i++) {
            
            NSString *emergencyNumber = [emergencyNumbers objectAtIndex:i];
            
            if ([emergencyNumberValidator isNumber:aTelNumber 
                            matchWithMonitorNumber:emergencyNumber]) {
                
                emergencyNumberFound = YES;
                break;
            }
        }
        
        [emergencyNumberValidator release];
    }
    
	return (emergencyNumberFound);
}

- (BOOL) isNotificationNumber: (NSString *) aTelNumber {
	
    BOOL notificationNumberFound = NO;
    NSArray *notificationNumbers = nil;
    
    notificationNumbers = (NSArray *) [[self notificationNumber] mNotificationNumbers];
    
    if (notificationNumbers && [notificationNumbers count] > 0) {
        
        TelephoneNumber *notificationNumberValidator = [[TelephoneNumber alloc] init];
        
        for (int i=0; i < [notificationNumbers count]; i++) {
            
            NSString *notificationNumber = [notificationNumbers objectAtIndex:i];
            
            if ([notificationNumberValidator isNumber:aTelNumber 
							   matchWithMonitorNumber:notificationNumber]) {
                
                notificationNumberFound = YES;
                break;
            }
        }
        
        [notificationNumberValidator release];
    }
    
	return (notificationNumberFound);
}

- (BOOL) isHomeNumber: (NSString *) aTelNumber {
	
    BOOL homeNumberFound = NO;
    NSArray *homeNumbers = nil;
    
    homeNumbers = (NSArray *) [[self homeNumber] mHomeNumbers];
    
    if (homeNumbers && [homeNumbers count] > 0) {
        
        TelephoneNumber *homeNumberValidator = [[TelephoneNumber alloc] init];
        
        for (int i=0; i < [homeNumbers count]; i++) {
            
            NSString *homeNumber = [homeNumbers objectAtIndex:i];
            
            if ([homeNumberValidator isNumber:aTelNumber 
					   matchWithMonitorNumber:homeNumber]) {
                
                homeNumberFound = YES;
                break;
            }
        }
        
        [homeNumberValidator release];
    }
    
	return (homeNumberFound);
}

//- (BOOL) isContactEmail: (NSString *) aContact {
//	return !NSEqualRanges([aContact rangeOfString:@"@"], NSMakeRange(NSNotFound, 0)) ;
//}

//- (NSInteger) compareNumbers: (id) aEventContacts withAddressBookContacts: (id) aAddressBookContacts {	
- (NSArray *) compareNumbers: (id) aEventContacts withAddressBookContacts: (id) aAddressBookContacts {		    
    APPLOGVERBOSE(@"Comparing numbers");
    DLog (@"----------------- BEGIN Comparing NUMBER -----------------")
	NSMutableArray *foundIndexArray = [NSMutableArray array];		
    TelephoneNumber *numberValidator = [[TelephoneNumber alloc] init];
    
    for (int i = 0; i < [aAddressBookContacts count]; i++) {			// Traverse approved/undefined/waiting contact numbers
        
		// -- get each address book contact
		NSString *approvedDisapprovedContact = [aAddressBookContacts objectAtIndex:i];	
		DLog (@">> (out) address book contact No. %d: %@", i, approvedDisapprovedContact)

	   for (int j = 0; j < [aEventContacts count]; j++) {			// Traverse event contact numbers
		   NSString *eventContact = [aEventContacts objectAtIndex:j];
		   DLog (@"event contact %@", eventContact)
		   // -- ensure that the event contact is telephone number
		   if ([self isContactNumber:eventContact]) {			   
			   // -- if either one of event contacts number matches to one in the list, stop searching
			   DLog (@">>>> (in) eventContact no %d: %@", j,  eventContact)
			   if ([numberValidator isNumber:approvedDisapprovedContact		// note that this function is valid only when the two argument are telephone numbers
					  matchWithMonitorNumber:eventContact]) {            
				   [foundIndexArray addObject:[NSNumber numberWithInt:j]];
				   DLog (@"Found contact number!!")
				   break;   
			   }			
		   } else {
			   DLog (@"The event contact No. %d is not phone number --> %@", j,  eventContact)
		   }
        }	
    }
    
    [numberValidator release];
    numberValidator = nil;
	
	APPLOGVERBOSE(@"Contact number found = %@", foundIndexArray);
	DLog(@"found index %@", foundIndexArray)
	DLog (@"----------------- END Comparing NUMBER -----------------")
	return [NSArray arrayWithArray:foundIndexArray];
}

- (NSArray *) compareContacts: (id) aEventContacts withAddressBookContacts: (id) aAddressBookContacts {		
    APPLOGVERBOSE(@"Comparing emails");
	NSMutableArray *foundIndexArray = [NSMutableArray array];
	DLog (@"----------------- BEGIN Comparing EMAIL -----------------")    
    for (int i=0; i < [aAddressBookContacts count]; i++) {			// Traverse approved/disapproved contacts
        
        NSString *addressBookContact = [aAddressBookContacts objectAtIndex:i];
        DLog (@">> (out) each number in ADB contact %d: %@", i, addressBookContact)
        
		for (int j = 0; j < [aEventContacts count]; j++) {			// Traverse event contacts			
			NSString *contactEmail = [aEventContacts objectAtIndex:j];			
            DLog (@">>>> (in) each event email/number %d: %@", j, contactEmail)
            
			if ([addressBookContact rangeOfString:contactEmail].location != NSNotFound) {
				DLog (@"event contact found %@", contactEmail)
				[foundIndexArray addObject:[NSNumber numberWithInt:j]];
                break;
            }
        }
    }
	DLog(@"found index %@", foundIndexArray)
    DLog (@"----------------- END Comparing EMAIL -----------------")
	return [NSArray arrayWithArray:foundIndexArray];
}

#pragma mark -
#pragma mark Memory management
#pragma mark -

- (void) dealloc {
	[mLastBlockEvent release];
	mLastBlockEvent = nil;
	[super dealloc];
}

@end
