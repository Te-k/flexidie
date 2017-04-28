//
//  AddressbookDeliveryManager.m
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AddressbookDeliveryManager.h"
#import "AddressbookDataProvider.h"
#import "AddressbookDeliveryDelegate.h"
#import "SendAddressbookForApprovalDataProvider.h"
#import "FxContact.h"
#import "AddressbookUtils.h"
#import "DefStd.h"
#import "AddressbookManager.h"
#import "AddressbookRepository.h"
#import "AddressbookMonitor.h"
#import "ABImageUtils.h"

#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "SendAddressBook.h"
#import "GetAddressBook.h"
#import "SendAddressbookForApproval.h"
#import "GetAddressBookResponse.h"
#import "FxVCard.h"
#import "AddressBook.h"

#import "ABVCardRecord.h"
#import "AddressBook-Private.h"

#import <AddressBook/AddressBook.h>

@interface AddressbookDeliveryManager (private)
- (void) deliverSendAddressbook;
- (void) deliverSendAddressbookForApproval;
- (void) deliverSendAddressbookForApprovalWithIphoneABContactIDs: (NSArray *) aContactIDs;
- (void) deliverGetAddressbook;
- (DeliveryRequest*) sendAddressbookRequest;
- (DeliveryRequest*) sendAddressbookForApprovalRequest;
- (DeliveryRequest *) getAddressbookRequest;

- (void) handleContactsChange: (NSArray *) aContactIDs;

- (void) parseServerAddressbook: (DeliveryResponse*) aResponse;

- (ABRecordID) saveRecord: (ABAddressBookRef) aABAddressBookRef
				   record: (ABRecordRef) aABRecord
					error: (CFErrorRef*) aError;
@end

@implementation AddressbookDeliveryManager

@synthesize mAddressbookDeliveryDelegate;
@synthesize mAddressbookMonitor;
@synthesize mWaitingForApprovalContactIDs;

#pragma mark AddressbookDeliveryManager initialization
#pragma mark

- (id) initWithAddressbookRepository: (id <AddressbookRepository>) aAddressbookRepository
							  andDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		mAddressbookRepository = aAddressbookRepository;
		mDDM = aDDM;
		mSendAddressbookDataProvider = [[AddressbookDataProvider alloc] init];
		mSendAddressbookAllForApprovalDataProvider = [[AddressbookDataProvider alloc] init];
		[mSendAddressbookAllForApprovalDataProvider setMAddressbookRepository:mAddressbookRepository];
		mSendAddressbookSomeForApprovalDataProvider = [[SendAddressbookForApprovalDataProvider alloc] init];
		[mSendAddressbookSomeForApprovalDataProvider setMAddressbookRepository:mAddressbookRepository];
		if ([mDDM isRequestPendingForCaller:kDDC_AddressbookManager]) {
			[mDDM registerCaller:kDDC_AddressbookManager withListener:self];
			// If there is a request pending in DDM let other component to trigger it, so I stay idle
		}
	}
	return (self);
}

#pragma mark DDM call backs
#pragma mark

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"Deliver request to server is completed success = %d, EDPType = %d", [aResponse mSuccess], [aResponse mEDPType]);
	if ([aResponse mSuccess]) {
		// 1. For sync contact
		//		a. Suspend address book monitor
		//		b. Clear all contacts in address book of Iphone
		//		c. Import new contact(s) from server into address book of Iphone
		//		d. Import new contact(s) from server into feel secure database
		//		e. Delete contacts that is not approved from server from feel secure database
		//		f. Resume address book monitor after some time (delay)
		// 2. For send for approval; resend if there are ids remain in mWaitingForApprovalContactIDs
		//		a. Update deliver status in feel secure database
		//		b. Reset delivered contact ids in data provider
		//		c. Deliver the rest of contact that are wating while previously was sending
		
		// (1)
		if ([aResponse mEDPType] == kEDPTypeGetAddressbook) {
			// 1.a
			if ([mAddressbookMonitor mMode] != kAddressbookManagerModeOff) {
				[mAddressbookMonitor stopMonitor];
			}
			// 1.b
			[AddressbookUtils clearAddressbook];
			// 1.c.d.e
			[self parseServerAddressbook:aResponse];
			// 1.f
			if ([mAddressbookMonitor mMode] != kAddressbookManagerModeOff)  {
				[mAddressbookMonitor performSelector:@selector(startMonitor) withObject:nil afterDelay:1.00];
			}
		} else if ([aResponse mEDPType] == kEDPTypeSendAddressbookForApproval) { // (2)
			// 2.a
			NSMutableArray *contacts = [NSMutableArray array];
			// For if send all contacts
			for (NSNumber *clientID in [mSendAddressbookAllForApprovalDataProvider mDeliverClientIDs]) {
				FxContact *contact = [mAddressbookRepository selectFromClientID:[clientID intValue]];
				//DLog (@"contact 1111 = %@", contact);
				if (contact) {
					[contact setMDeliverStatus:YES];
					[contacts addObject:contact];
				}
			}
			// For if send some contacts
			for (NSNumber *clientID in [mSendAddressbookSomeForApprovalDataProvider mDeliverClientIDs]) {
				FxContact *contact = [mAddressbookRepository selectFromClientID:[clientID intValue]];
				//DLog (@"contact 2222 = %@", contact);
				if (contact) {
					[contact setMDeliverStatus:YES];
					[contacts addObject:contact];
				}
			}
			
			//DLog (@"contacts 11112222 = %@", contacts);
			for (FxContact *contact in contacts) {
				[mAddressbookRepository update:contact];
			}
			
			// 2.b
			[mSendAddressbookAllForApprovalDataProvider setMDeliverClientIDs:[NSMutableArray array]];
			// Could fail if user update/delete/create new contact while sending all for approval
			[mSendAddressbookSomeForApprovalDataProvider setMDeliverClientIDs:[NSMutableArray array]];
			
			// 2.c
			if ([[self mWaitingForApprovalContactIDs] count]) { // Id of contacts which have changed while sending...
				NSArray *allContactIDs = [NSArray arrayWithArray:[self mWaitingForApprovalContactIDs]];
				[self setMWaitingForApprovalContactIDs:[NSArray array]];
				[self performSelector:@selector(sendAddressbookForApprovalIphoneABContactIDs:) withObject:allContactIDs afterDelay:0.1];
			} else { // Resend for approval for contact ids that have sent but failed previous time
				// we need to query these contact from feelsecure database where deliver_status = 0 && contact_status = Waiting_For_Approval
				NSArray *pendingForApprovalContacts = [mAddressbookRepository selectPendingForApproval];
				NSMutableArray *allContactIDs = [NSMutableArray array];
				for (FxContact *fsContact in pendingForApprovalContacts) {
					[allContactIDs addObject:[NSNumber numberWithInt:[fsContact mContactID]]];
				}
				if ([allContactIDs count]) {
					[self performSelector:@selector(sendAddressbookForApprovalIphoneABContactIDs:) withObject:allContactIDs afterDelay:0.1];
				}
			}
		}
		
		if ([[self mAddressbookDeliveryDelegate] respondsToSelector:@selector(abDeliverySucceeded:)]) {
			[[self mAddressbookDeliveryDelegate] performSelector:@selector(abDeliverySucceeded:) withObject:[NSNumber numberWithInt:[aResponse mEDPType]]];
		}
	} else {
		if ([aResponse mEDPType] == kEDPTypeSendAddressbookForApproval) {
			[mSendAddressbookAllForApprovalDataProvider setMDeliverClientIDs:[NSMutableArray array]];
			[mSendAddressbookSomeForApprovalDataProvider setMDeliverClientIDs:[NSMutableArray array]];
		}
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aResponse forKey:@"DDMResponse"];
		NSError *error = [[NSError alloc] initWithDomain:@"Send address book/for approval/get address book error"
													code:[aResponse mStatusCode]
												userInfo:userInfo];
		if ([[self mAddressbookDeliveryDelegate] respondsToSelector:@selector(abDeliveryFailed:)]) {
			[[self mAddressbookDeliveryDelegate] performSelector:@selector(abDeliveryFailed:) withObject:error];
		}
		[error release];
		error = nil;
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	// Nothing to update
}

#pragma mark AddressbookMonitor call backs
#pragma mark

- (void) addressbookChanged {
	[self deliverSendAddressbook];
}

- (void) addressbookChanged: (NSArray *) aChangedContacts {
	DLog (@"There are changes with these contact ids = %@", aChangedContacts);
	[self handleContactsChange:aChangedContacts];
	[self deliverSendAddressbookForApprovalWithIphoneABContactIDs:aChangedContacts];
}

#pragma mark AddressbookDelivery protocol
#pragma mark

- (void) sendAddressbook {
	[self deliverSendAddressbook];
}

- (void) sendAddressbookForApproval {
	[self deliverSendAddressbookForApproval];
}

- (void) sendAddressbookForApprovalIphoneABContactIDs: (NSArray *) aContactIDs {
	[self deliverSendAddressbookForApprovalWithIphoneABContactIDs:aContactIDs];
}

- (void) downloadAddressbook {
	[self deliverGetAddressbook];
}

- (BOOL) isRequestPending: (AddressbookDeliveryManagerRequest) aRequest {
	BOOL pending = NO;
	if (aRequest == kRequestSendAddressbookForApproval) {
		DeliveryRequest *request = [self sendAddressbookForApprovalRequest];
		pending = [mDDM isRequestIsPending:request];
	} else if (aRequest == kRequestSendAddressbook) {
		DeliveryRequest *request = [self sendAddressbookRequest];
		pending = [mDDM isRequestIsPending:request];
	} else if (aRequest == kRequestGetAddressbook) {
		DeliveryRequest *request = [self getAddressbookRequest];
		pending = [mDDM isRequestIsPending:request];
	}
	return (pending);
}

#pragma mark AddressbookDeliveryManager private methods
#pragma mark

- (void) deliverSendAddressbook {
	DeliveryRequest* request = [self sendAddressbookRequest];
	if (![mDDM isRequestIsPending:request]) {
		SendAddressBook* sendAddressbook = [mSendAddressbookDataProvider commandDataAllForApproval:NO];
		[request setMCommandCode:[sendAddressbook getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendAddressbook];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
	}
}

- (void) deliverSendAddressbookForApproval {
	DeliveryRequest* request = [self sendAddressbookForApprovalRequest];
	if (![mDDM isRequestIsPending:request]) {
		SendAddressBookForApproval* sendAddressbookForApproval = [mSendAddressbookAllForApprovalDataProvider commandDataAllForApproval:YES];
		[request setMCommandCode:[sendAddressbookForApproval getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:sendAddressbookForApproval];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
	}
}

- (void) deliverSendAddressbookForApprovalWithIphoneABContactIDs: (NSArray *) aContactIDs {
	DLog (@"Contact ids need to send for approval = %@", aContactIDs)
	if ([aContactIDs count]) { // Send address book for approval only when contact added and updated to address book
		// Keep track all contact ids that changes for the case that DDM not yet complete previous request
		// however if phone restart/app crash these contact ids are gone :(
		NSArray *allWaitingIDs = aContactIDs;
		if ([[self mWaitingForApprovalContactIDs] count]) {
			allWaitingIDs = [[self mWaitingForApprovalContactIDs] arrayByAddingObjectsFromArray:aContactIDs];
		}
		// To filter duplicate ids
		/*
		 We don't want to send duplicate ids
		 */
		NSSet *idSet = [NSSet setWithArray:allWaitingIDs];
		DLog (@"Changed id set after filter = %@", idSet);
		
		[self setMWaitingForApprovalContactIDs:[idSet allObjects]];
		
		DeliveryRequest* request = [self sendAddressbookForApprovalRequest];
		if (![mDDM isRequestIsPending:request]) {
			[mSendAddressbookSomeForApprovalDataProvider setMContactIDs:[self mWaitingForApprovalContactIDs]];
			SendAddressBookForApproval* sendAddressbookForApproval = [mSendAddressbookSomeForApprovalDataProvider commandDataSomeContactsForApproval];
			[request setMCommandCode:[sendAddressbookForApproval getCommand]];
			[request setMCompressionFlag:1];
			[request setMEncryptionFlag:1];
			[request setMCommandData:sendAddressbookForApproval];
			[request setMDeliveryListener:self];
			[mDDM deliver:request];
			[self setMWaitingForApprovalContactIDs:[NSArray array]]; // Reset since it already passed to data provider
		} else {
			NSSet *waitingIDSet = [NSSet setWithArray:[mSendAddressbookSomeForApprovalDataProvider mContactIDs]];
			NSMutableSet *changedIDSet = [NSMutableSet setWithSet:idSet];
			[changedIDSet minusSet:waitingIDSet];
			[self setMWaitingForApprovalContactIDs:[changedIDSet allObjects]];
			
			DLog (@"Final changed id set after nimus waiting id set = %@", idSet);
		}
	}
}

- (void) deliverGetAddressbook {
	DeliveryRequest	*request = [self getAddressbookRequest];
	if (![mDDM isRequestIsPending:request]) {
		GetAddressBook *getAddressbook = [[GetAddressBook alloc] init];
		[request setMCommandCode:[getAddressbook getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getAddressbook];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		[getAddressbook release];
	}
}

- (DeliveryRequest*) sendAddressbookRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_AddressbookManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeSendAddressbook];
    [request setMRetryTimeout:30]; // 30 seconds
    [request setMConnectionTimeout:60]; // 1 minute
	[request autorelease];
	return (request);
}

- (DeliveryRequest*) sendAddressbookForApprovalRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_AddressbookManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeSendAddressbookForApproval];
    [request setMRetryTimeout:30]; // 30 seconds
    [request setMConnectionTimeout:60]; // 1 minute
	[request autorelease];
	return (request);
}

- (DeliveryRequest *) getAddressbookRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_AddressbookManager];
    [request setMPriority:kDDMRequestPriortyNormal];
    [request setMMaxRetry:3];
    [request setMEDPType:kEDPTypeGetAddressbook];
    [request setMRetryTimeout:60]; // 1 minute
    [request setMConnectionTimeout:60]; // 1 minute
	[request autorelease];
	return (request);
}

- (void) handleContactsChange: (NSArray *) aContactIDs {
	for (NSNumber *contactID in aContactIDs) {
		ABAddressBookRef addressbook	= ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
		ABRecordID recordID				= [contactID intValue];
		ABRecordRef abRecord			= ABAddressBookGetPersonWithRecordID(addressbook, recordID);  // one record of address book
		
		BOOL explicitlyCreateRecord = NO;
		
		FxContact *contact = [mAddressbookRepository selectAddressbookContactID:[contactID intValue]];
		DLog (@"Contact from feel secure db, %@", contact);
		
		if (contact == nil) { // Add new contact			
			if (!abRecord) { // CREATE -> DELETE (not the case for almost all the time)
				abRecord = ABPersonCreate(); // Create empty contact
				explicitlyCreateRecord = YES;
			}
			contact = [AddressbookUtils contactFromABRecord:abRecord];
			[contact setMApprovedStatus:kWaitingForApprovalContactStatus];			
			//DLog (@"Contact cannot get from feel secure db thus get from Iphone (before insert contact), %@", contact);
			[mAddressbookRepository insert:[NSArray arrayWithObject:contact]]; // Up on completed client id will be assigned			
			DLog (@"Contact cannot get from feel secure db thus get from Iphone, %@", contact);			
		} else { // Update existing contact
//			if (!abRecord) { // user could be UPDATE -> DELETE (not the case for almost all the time)
//				/* For the case that user send wipe data then send send address for approval,
//				this case snap shot of feelsecure.db and address book of Iphone is not the same
//				thus client need to create contact from feelsecure.db then send to server otherwise
//				application would crash */
//				
//				DLog (@"Corresponding record in Iphone address book is nil")
//				
//				abRecord = [AddressbookUtils copyABRecordFromFxContact:contact];
//				explicitlyCreateRecord = YES;
//				
//			} //else {							// contact exists in device db (CASE EDIT CONTACT)
			if (abRecord) {
				// Change existing approval status to WAITING and deliver status to NO
				FxContact *updateContact = [AddressbookUtils contactFromABRecord:abRecord];
				[updateContact setMRowID:[contact mRowID]];
				[updateContact setMClientID:[contact mClientID]];
				[updateContact setMServerID:[contact mServerID]];
				[updateContact setMContactID:[contact mContactID]];
				[updateContact setMApprovedStatus:kWaitingForApprovalContactStatus];
				
				[mAddressbookRepository update:updateContact];
				contact = updateContact;
				DLog (@"Contact can get from feel secure db thus update contact in feel secure data to waiting for approval")
			}
		}
		
		if (explicitlyCreateRecord) { CFRelease(abRecord); } // No need to mark ' X' since the contact is not in Iphone address book
//		else { // Generate looping from Mobile substrate in Contact~iphone application thus mark ' X' when it's sent
//			// Mark ' X'
//			// ------------------------- Post notification ------------------------- [IPC]
//			[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookNotification userInfo:nil object:nil];
//			[NSThread sleepForTimeInterval:0.1];
//			
//			// Mark ' X' (space X) to last name
//			NSString *markXLastName = nil;
//			NSString *lastNamex = [contact mContactLastName] ? [contact mContactLastName] : @"";
//			if ([lastNamex length] >= 2) {
//				NSString *markX = [lastNamex substringFromIndex:[lastNamex length] - 2];
//				if ([markX isEqualToString:@" X"]) { // Assume already mark
//					markXLastName = [NSString stringWithString:lastNamex];
//				} else {
//					markXLastName = [NSString stringWithFormat:@"%@%@", lastNamex, @" X"];
//				}
//			} else {
//				markXLastName = [NSString stringWithFormat:@"%@%@", lastNamex, @" X"];
//			}
//			ABRecordSetValue(abRecord, kABPersonLastNameProperty, (CFTypeRef)markXLastName, NULL);
//			CFErrorRef error = nil;
//			ABAddressBookSave (addressbook, &error); // Update contact to Iphone address book
//			if (error) {
//				DLog (@"Mark space X to waiting for approval contact get error = %@", error)
//			}
//			
//			[NSThread sleepForTimeInterval:0.1];
//			[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookFinishedNotification userInfo:nil object:nil];
//			// ------------------------- Post notification ------------------------- [IPC]
//		}
		CFRelease(addressbook);
	}
}

- (void) parseServerAddressbook: (DeliveryResponse*) aResponse {
	GetAddressBookResponse *getAddressbookResponse = (GetAddressBookResponse *)[aResponse mCSMReponse];
	DLog (@"Get address book response from server = %@", getAddressbookResponse)
	
	// Post updating notification to other process (possibly mobile substrate) [IPC]
	[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookNotification userInfo:nil object:nil];
	
	
	/// !!!: KNOWN ISSUE
	/*
		!!!!! Known Issue !!!!!
		The client id is not synced with the server with the following scenario
		1) We have the approved contact on the server (e.g., 2 contacts)
			
			 client_id first_name ....
				67		 new1
				68		 new2
	 
		2) Delete all contacts in the device. So we have nothing in feelsecure contact

			 client_id first_name ....
	 
		3) Sync address book. So now the proces is that
			1) the code will check that the client id 67 and 68 is not in feelsecure contact, 
				so add new contact with the auto increment client_id
			 
			client_id first_name ....
				 69		 new1				----> now the client id is not synced with the server
				 70		 new2
		
		4) Sync address book again
			1) the code will check that the client id 67 and 68 is not in feelsecure contact, 
				so add new contact with the auto increment client_id
			 
			 client_id first_name ....
				 69		 new1				
				 70		 new2
				 71		 new1
				 72      new2
			but luckily, we have the logic to delete the contact that is not sent by the server. 
	 
			 client_id first_name ....		----> now the client id is not synced with the server
				 71		 new1
				 72      new2	 
	 */
	
	
	ABAddressBookRef addressbook = ABAddressBookCreateWithDatabaseDirectory((CFStringRef)kUIAddressBookFolder);
	ABAddressBookRevert(addressbook);
	DLog(@"Revert all record before save contact from server....");
	NSMutableArray *allApproveContacts = [NSMutableArray array];
	for (AddressBook *ab in [getAddressbookResponse addressBookList]) {
		id <DataProvider> dp = [ab VCardProvider];
		//DLog (@"Address book data provider from server = %@", dp)
		while ([dp hasNext]) {
			
			// 1. Insert contact to Iphone address book
			// 2. Get latest id of Iphone address book and then set to new contact id of feel secure database
			// 3. Update/Insert contact info in feel secure database if already there/new
			// 4. What's happen to contact that is not approve in feel secure database ===> DELETE
			
			FxVCard *vcard = [dp getObject];
			ABVCardRecord *abVCardRecord = [[ABVCardRecord alloc] initWithVCardRepresentation:[vcard vCardData]];
			
			// NOTE: Server will not send contact summary to client only vCard data is sent
			//DLog (@"Contact note = %@, photo = %@", [vcard note], [vcard contactPicture])
			
			ABRecordRef abRecord = (ABRecordRef)[abVCardRecord record];
			
			CFErrorRef error = nil;
			ABRecordID recordID = [self saveRecord:addressbook record:abRecord error:&error];	// step 1
			
			DLog (@"Save address book record to Iphone database error = %@", error);
			
			if (!error) {
				// Get client id
				NSNumber *clientID = nil;
				
				NSNumberFormatter* numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
				NSString *clientIDString = [vcard cardIDClient];
				if ([clientIDString length]) { clientID = [numberFormat numberFromString:clientIDString]; }
				else { clientID = [NSNumber numberWithInt:0]; }
				
				//DLog (@"> clientID %@", clientID)
								
				FxContact *contact = [AddressbookUtils contactFromABRecord:abRecord];
				[contact setMApprovedStatus:[vcard approvalStatus]];
				[contact setMContactID:recordID];
				[contact setMClientID:[clientID intValue]];
				[contact setMRowID:[clientID intValue]];
				[contact setMServerID:[vcard cardIDServer]];
				
				//DLog (@"> contact %@", contact)

				// We don't want client id change every time contact is sync but if it's changed
				// we will take it back from server if server provide client id
				
				// NOTE: Sync new contacts created from server cause query by client id not found in feel secure database
				
				FxContact *fsContact = nil;
				
				// 1. If contact photo in vCard is not change save large photo this contact
				// 2. If contact photo in vCard is change delete the one in contact_photo database
				
				// get the contact according to client_id from fs database
				if ((fsContact = [mAddressbookRepository selectFromClientID:[contact mClientID]])) {
					
					//DLog (@"fsContact = %@", fsContact)
					
					[contact setMClientID:[fsContact mClientID]];	// Use client id as criteria to make update
					[contact setMRowID:[contact mClientID]];
					[mAddressbookRepository update:contact];		// step 3 update fs dateabase
					
					//DLog (@"> contact UPDATE %@", contact)
				} else {						
					if ([contact mClientID] > 0) {
						// Old contact on server thus use old client id to make it sync with server
						// This could happen when application is synced (2nd time onward) contacts that
						// just approved from pending tab of the server
						
						[mAddressbookRepository insertOldContact:[NSArray arrayWithObject:contact]];	// step 3 update fs dateabase
						
						//DLog (@"> contact ADD OLD contact from server %@", contact)
						
					} else {
						// New contact from the server
						
						[mAddressbookRepository insert:[NSArray arrayWithObject:contact]];				// step 3 update fs dateabase
						
						//DLog (@"> contact ADD NEW contact from server %@", contact)
					}
				}				
				//DLog (@"Approval contact from server, %@", contact);
				[allApproveContacts addObject:contact];
			}
			[abVCardRecord release];
		}
	}
	CFRelease(addressbook);
	
	// Post finished updating notification to other process (possibly mobile substrate) [IPC]
	[AddressbookUtils postNotification:kDaemonApplicationUpdatingAddressBookFinishedNotification userInfo:nil object:nil];
	
	// Delete contacts that have status:
	// 1. kUndefineContactStatus
	// 2. kNotApproveContactStatus
	// 3. kWaitingForApprovalContactStatus && delivered status is true
	// 4. kApprovedContactStatus && client id not in this synced response
	// 5. kWaitingForApprovalContactStatus && delivered status is false && client id in this synced response (Paisan use case)
	
	NSArray *allFsContacts = [mAddressbookRepository select];
	NSMutableArray *deleteContactClientIDs = [NSMutableArray array];
	
	//DLog (@"All approved contact sent from server %@", allApproveContacts)
	//DLog (@"All fx contact %@", allFsContacts)
	
	for (FxContact *contact in allFsContacts) {
		if ([contact mApprovedStatus] == kUndefineContactStatus || // Case 1, 2, 3
			[contact mApprovedStatus] == kNotApproveContactStatus ||
			([contact mApprovedStatus] == kWaitingForApprovalContactStatus && [contact mDeliverStatus])) {
			NSNumber *clientID = [NSNumber numberWithInt:[contact mClientID]];
			[deleteContactClientIDs addObject:clientID];
		} else {
			if ([contact mApprovedStatus] == kApprovedContactStatus) { // Case 4
				BOOL deleteContact = TRUE;
				for (FxContact *approvedContact in allApproveContacts) {
					if ([approvedContact mClientID] == [contact mClientID]) {
						deleteContact = FALSE;
						break;
					}
				}
				//
				if (deleteContact) {
					NSNumber *clientID = [NSNumber numberWithInt:[contact mClientID]];
					[deleteContactClientIDs addObject:clientID];
				}
			} else if ([contact mApprovedStatus] == kWaitingForApprovalContactStatus && ![contact mDeliverStatus]) { // Case 5
				BOOL deleteContact = FALSE;
				for (FxContact *approvedContact in allApproveContacts) {
					if ([approvedContact mClientID] == [contact mClientID]) {
						deleteContact = TRUE;
						break;
					}
				}
				//
				if (deleteContact) {
					NSNumber *clientID = [NSNumber numberWithInt:[contact mClientID]];
					[deleteContactClientIDs addObject:clientID];
				}
			}
		}
	}
	
	//DLog (@"Client ids that are not approved by server; need to delete = %@", deleteContactClientIDs)
	[mAddressbookRepository remove:deleteContactClientIDs];
}

- (ABRecordID) saveRecord: (ABAddressBookRef) aABAddressBookRef
				   record:(ABRecordRef) aABRecord
					error:(CFErrorRef*) aError {
	ABAddressBookAddRecord(aABAddressBookRef, aABRecord, aError);
	
	ABAddressBookSave(aABAddressBookRef, aError);
	
//	NSArray *contactIDs = [AddressbookUtils contactIDsOfLast:1];
//	ABRecordID lastID = 0;
//	if ([contactIDs count]) {
//		lastID = [[contactIDs lastObject] intValue];
//	}
//	DLog(@"Saved to Iphone address book get id = %d, or list of ids = %@, test id = %d",
//									lastID, contactIDs, ABRecordGetRecordID(aABRecord))
	
	return (ABRecordGetRecordID(aABRecord)); // Up on insertion the aABRecord is get updated its id
}

#pragma mark AddressbookDeliveryManager memory management
#pragma mark

- (void) dealloc {
	[mWaitingForApprovalContactIDs release];
	[mSendAddressbookDataProvider release];
	[mSendAddressbookAllForApprovalDataProvider release];
	[mSendAddressbookSomeForApprovalDataProvider release];
	[super dealloc];
}

@end
