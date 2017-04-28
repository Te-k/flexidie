//
//  FxVCard.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FxVCardApprovalStatusEnum.h"

@interface FxVCard : NSObject {
	FxVCardApprovalStatus approvalStatus;
	NSString *cardIDClient;
	long cardIDServer;
	NSData *contactPicture;
	NSString *email;
	NSString *firstName;
	NSString *lastName;
	NSString *homePhone;
	NSString *mobilePhone;
	NSString *workPhone;
	NSString *note;
	NSData *vCardData;
}

@property (nonatomic, retain) NSString *cardIDClient;
@property (nonatomic, assign) FxVCardApprovalStatus approvalStatus;
@property (nonatomic, assign) long cardIDServer;
@property (nonatomic, retain) NSData *contactPicture;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *homePhone;
@property (nonatomic, retain) NSString *mobilePhone;
@property (nonatomic, retain) NSString *workPhone;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSData *vCardData;
@end
