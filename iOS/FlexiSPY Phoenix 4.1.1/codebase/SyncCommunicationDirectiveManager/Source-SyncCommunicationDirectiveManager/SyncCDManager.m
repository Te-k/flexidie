//
//  SyncCDManager.m
//  SyncCommunicationDirectiveManager
//
//  Created by Makara Khloth on 6/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncCDManager.h"
#import "SyncCD.h"
#import "CD.h"
#import "CDCriteria.h"
#import "SyncCommunicationDirectiveDelegate.h"
#import "DataDelivery.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"
#import "GetCommunicationDirectives.h"
#import "GetCommunicationDirectivesResponse.h"
#import "CommunicationDirective.h"
#import "CommunicationDirectiveCriteria.h"
#import "DirectiveEventEnum.h"
#import "CDDAO.h"

@interface SyncCDManager (private)
- (void) deliverGetCD;
- (DeliveryRequest *) getCDRequest;
- (void) performGetCDSuccess: (GetCommunicationDirectivesResponse *) aGetCDResponse;
- (void) prerelease;
@end

@implementation SyncCDManager

@synthesize mSyncCD;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		mDDM = aDDM;
		mSyncCDDelegates = [[NSMutableArray alloc] init];
		[self setMSyncCD:[CDDAO syncCD]];
		if ([mDDM isRequestPendingForCaller:kDDC_SyncCDManager]) {
			[mDDM registerCaller:kDDC_SyncCDManager withListener:self];
		}
	}
	return (self);
}

- (void) appendSyncCDDelegate: (id <SyncCommunicationDirectiveDelegate>) aSyncCDDelegate {
	BOOL alreadyAdded = NO;
	for (id <SyncCommunicationDirectiveDelegate> delegate in mSyncCDDelegates) {
		if (delegate == aSyncCDDelegate) {
			alreadyAdded = YES;
			break;
		}
	}
	if (!alreadyAdded && aSyncCDDelegate) {
		[mSyncCDDelegates addObject:aSyncCDDelegate];
	}
	DLog (@"aSyncCDDelegate = %@ is already added = %d", aSyncCDDelegate, alreadyAdded);
}

- (void) removeSyncCDDelegate: (id <SyncCommunicationDirectiveDelegate>) aSyncCDDelegate {
	DLog (@"(BEFORE) processor to be deleted %@", aSyncCDDelegate)
	[mSyncCDDelegates removeObject:aSyncCDDelegate];
	DLog (@"(AFTER) processor to be deleted")
}

- (void) syncCD {
	[self deliverGetCD];
}

- (void) clearCDs {
	[CDDAO clearSyncCD];
}

- (void) requestFinished: (DeliveryResponse*) aResponse {
	if ([aResponse mSuccess]) {
		[self performGetCDSuccess:(GetCommunicationDirectivesResponse *)[aResponse mCSMReponse]];
	} else {
		// Requirement: retry every one minute if fail
		[self performSelector:@selector(syncCD)
				   withObject:nil
				   afterDelay:60];
	}
	
	// For preventing caller remove itself with syncCDSuccess or syncCDError call back
	NSArray *delegates = [NSArray arrayWithArray:mSyncCDDelegates];
	DLog(@"SyncCommunicationDirective delegates %@", delegates)
	
	for (id <SyncCommunicationDirectiveDelegate> delegate in delegates) {
		if ([aResponse mSuccess] && [delegate respondsToSelector:@selector(syncCDSuccess)]) {
			[delegate performSelector:@selector(syncCDSuccess)];
		}
		if (![aResponse mSuccess] && [delegate respondsToSelector:@selector(syncCDError:error:)]) {
			NSError *error = [NSError errorWithDomain:@"Sync communication directive error"
												 code:[aResponse mStatusCode]
											 userInfo:nil];
			[delegate performSelector:@selector(syncCDError:error:)
						   withObject:[NSNumber numberWithInt:[aResponse mDDMStatus]]
						   withObject:error];
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
}

- (void) deliverGetCD {
	DeliveryRequest* request = [self getCDRequest];
	if (![mDDM isRequestIsPending:request]) {
		GetCommunicationDirectives* getCD = [[GetCommunicationDirectives alloc] init];
		[request setMCommandCode:[getCD getCommand]];
		[request setMCompressionFlag:1];
		[request setMEncryptionFlag:1];
		[request setMCommandData:getCD];
		[request setMDeliveryListener:self];
		[mDDM deliver:request];
		[getCD release];
	}
}

- (DeliveryRequest *) getCDRequest {
	DeliveryRequest* request = [[DeliveryRequest alloc] init];
    [request setMCallerId:kDDC_SyncCDManager];
    [request setMPriority:kDDMRequestPriortyHigh];
    [request setMMaxRetry:0];
    [request setMEDPType:kEDPTypeGetCommunicationDirectives];
    [request setMRetryTimeout:60];
    [request setMConnectionTimeout:60];
	[request autorelease];
	return (request);
}
						  
- (void) performGetCDSuccess: (GetCommunicationDirectivesResponse *) aGetCDResponse {
	DLog (@"performGetCDSuccess")
	NSMutableArray *cds = [NSMutableArray array];
	for (CommunicationDirective *cd in [aGetCDResponse communicationDirectiveList]) {
		CD *commuD = [[CD alloc] init];
		[commuD setMRecurrence:[cd timeUnit]];
		CDCriteria *commuDCriteria = [[CDCriteria alloc] init];
		[commuDCriteria setMMultiplier:[[cd criteria] multiplier]];
		[commuDCriteria setMDayOfWeek:[[cd criteria] dayOfWeek]];
		[commuDCriteria setMDayOfMonth:[[cd criteria] dayOfMonth]];
		[commuDCriteria setMMonthOfYear:[[cd criteria] monthOfYear]];
		[commuD setMCDCriteria:commuDCriteria];
		DLog (@"CD --> %@", commuD)
		[commuDCriteria release];
		for (NSNumber *commuEvent in [cd commuEvent]) {
			NSUInteger blockEvents = [commuD mBlockEvents];
			switch ([commuEvent intValue]) {
				case CALL_DIRECTIVE:
					blockEvents |= kCDBlockCall;
					break;
				case SMS_DIRECTIVE:
					blockEvents |= kCDBlockSMS;
					break;
				case MMS_DIRECTIVE:
					blockEvents |= kCDBlockMMS;
					break;
				case EMAIL_DIRECTIVE:
					blockEvents |= kCDBlockEmail;
					break;
				case IM_DIRECTIVE:
					blockEvents |= kCDBlockIM;
					break;
				default:
					break;
			}
			[commuD setMBlockEvents:blockEvents];
		}
		[commuD setMStartDate:[cd startDate]];
		[commuD setMEndDate:[cd endDate]];
		[commuD setMStartTime:[cd dayStartTime]];
		[commuD setMEndTime:[cd dayEndTime]];
		[commuD setMAction:[cd action]];
		[commuD setMDirection:[cd direction]];
		[cds addObject:commuD];
		[commuD release];
	}
	SyncCD *syncCD = [[SyncCD alloc] init];
	[syncCD setMCDs:cds];
	[self setMSyncCD:syncCD];	
	[syncCD release];
		
	// Persist sync CD
	[CDDAO saveSyncCD:[self mSyncCD]];
}

- (void) prerelease {
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(syncCD)
											   object:nil];
}

- (void) release {
	[self prerelease];
	[super release];
}

- (void) dealloc {
	[mSyncCDDelegates release];
	[mSyncCD release];
	[super dealloc];
}

@end