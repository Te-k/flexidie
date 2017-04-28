//
//  AddressbookDelivery.h
//  AddressbookManager
//
//  Created by Makara Khloth on 2/9/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kRequestSendAddressbookForApproval,
	kRequestSendAddressbook,
	kRequestGetAddressbook
} AddressbookDeliveryManagerRequest;

@protocol AddressbookDelivery <NSObject>

- (void) sendAddressbook;
- (void) sendAddressbookForApproval;
- (void) sendAddressbookForApprovalIphoneABContactIDs: (NSArray *) aContactIDs;
- (void) downloadAddressbook;
- (BOOL) isRequestPending: (AddressbookDeliveryManagerRequest) aRequest;

@end

