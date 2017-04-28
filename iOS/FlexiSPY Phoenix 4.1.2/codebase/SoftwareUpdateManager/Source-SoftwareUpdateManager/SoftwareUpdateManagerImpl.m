//
//  SoftwareUpdateManagerImpl
//  SoftwareUpdateManager
//
//  Created by Ophat Phuetkasickonphasutha on 6/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "SoftwareUpdateManagerImpl.h"
#import "SoftwareInstaller.h"
#import "SoftwareUpdateDelegate.h"

#import "DefDDM.h"
#import "DataDelivery.h"
#import "GetBinary.h"
#import "GetBinaryResponse.h"
#import "DeliveryRequest.h"
#import "DeliveryResponse.h"

#import "CRC32.h"

@interface SoftwareUpdateManagerImpl (private)
- (DeliveryRequest *) softwareUpdateRequest;
- (uint32_t) getCRC32ForBinary: (id) aBinary;
- (void) downloadBinaryCheckCompleted: (NSError *) aError;
- (void) installDownloadedBinary: (NSDictionary *) aBinaryInfo;
@end


@implementation SoftwareUpdateManagerImpl

@synthesize mDDM, mSoftwareUpdateDelegate;

- (id) initWithDDM: (id <DataDelivery>) aDDM {
	if ((self = [super init])) {
		[self setMDDM:aDDM];
		mSoftwareInstaller = [[SoftwareInstaller alloc] init];
	}
	return (self);
}

#pragma mark -
#pragma mark SoftwareUpdateManager
#pragma mark -

-(BOOL)updateSoftware: (id<SoftwareUpdateDelegate>) aDelegate{
	BOOL ok = NO;
	DeliveryRequest *softwareUpdateRequest = [self softwareUpdateRequest];
	if (![mDDM isRequestIsPending:softwareUpdateRequest]) {
		[mDDM deliver:softwareUpdateRequest];
		[self setMSoftwareUpdateDelegate:aDelegate];
		ok = YES;
	}
	return (ok);
}

- (BOOL) updateSoftware: (id<SoftwareUpdateDelegate>) aDelegate url: (NSString *) aUrl checksum: (NSString *) aChecksum {
    NSThread *myThread = [NSThread currentThread];
    self.mSoftwareUpdateDelegate = aDelegate;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSURL *url = [NSURL URLWithString:aUrl];
        NSData *binaryData = [NSData dataWithContentsOfURL:url];
        
        NSError *error = nil;
        
        if (!binaryData) {
            error = [NSError errorWithDomain:@"Software Update Error"
                                        code:kSoftwareUpdateManagerCRCError
                                    userInfo:nil];
            
            [self performSelector:@selector(downloadBinaryCheckCompleted:)
                         onThread:myThread
                       withObject:error
                    waitUntilDone:NO];
            
        } else {
            uint32_t binaryCRC32 = [self getCRC32ForBinary:binaryData];
            //NSString *crc32 = [NSString stringWithFormat:@"%d", binaryCRC32];
            
            NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *yourCRC32 = [formatter numberFromString:aChecksum];
            uint32_t crc32 = (uint32_t)[yourCRC32 unsignedIntegerValue];
            
            if (binaryCRC32 == crc32) {
                DLog (@"Url update, CRC MATCH, so go ahead to update the software");
                [self performSelector:@selector(downloadBinaryCheckCompleted:)
                             onThread:myThread
                           withObject:nil
                        waitUntilDone:YES];
                
                NSString *binaryName = [url lastPathComponent];
                DLog(@"url %@, binaryName %@", url, binaryName);
                
                //[mSoftwareInstaller install:binaryData withFileName:binaryName];
                
                NSDictionary *binaryInfo = [NSDictionary dictionaryWithObjectsAndKeys:binaryData, @"b", binaryName, @"bn",nil];
                [self performSelector:@selector(installDownloadedBinary:)
                             onThread:myThread
                           withObject:binaryInfo
                        waitUntilDone:NO];
            } else {
                DLog (@"Url update, CRC NOT MATCH, so NOT update the software");
                error = [NSError errorWithDomain:@"Software Update Error"
                                            code:kSoftwareUpdateManagerCRCError
                                        userInfo:nil];
                
                [self performSelector:@selector(downloadBinaryCheckCompleted:)
                             onThread:myThread
                           withObject:error
                        waitUntilDone:NO];
            }
        }
    });
    return (YES);
}

#pragma mark -
#pragma mark DDM
#pragma mark -

- (void) requestFinished: (DeliveryResponse*) aResponse {
	DLog (@"Software update completed, success = %d", [aResponse mSuccess]);
	if ([aResponse mSuccess]) {
		id <SoftwareUpdateDelegate> delegate = [self mSoftwareUpdateDelegate];
		[self setMSoftwareUpdateDelegate:nil];
				
		GetBinaryResponse *softwareUpdateResponse = (GetBinaryResponse *)[aResponse mCSMReponse];
		/*
			GetBinaryResponse		 
			NSString	*mBinaryName;
			NSUInteger	mCRC32;
			id			mBinary;		// NSString which is path to binary if file is big otherwise NSData
		 }
		 */						
		
		// It will crash if print too much (Binary is large), so I comment this line 
		//DLog (@"Binary data/path %@",  [softwareUpdateResponse mBinary])
		
		uint32_t binaryCRC32 = [self getCRC32ForBinary:[softwareUpdateResponse mBinary]];
		if (binaryCRC32 == [softwareUpdateResponse mCRC32]) {
			DLog (@"CRC MATCH, so go ahead to update the software")
			// -- Inform delegate the success
			if ([delegate respondsToSelector:@selector(softwareUpdateCompleted:)]) {
				[delegate performSelector:@selector(softwareUpdateCompleted:) withObject:nil];
			}			
			/*	------ NOTE ------				
				This value can be either NSString of path (Big) or NSData of binary (Small). 
				It depends on the size of binary. 
				- If the size is greater than 5 M, mBinary is a path to binary
				- If the size is less than or equal 5 M, mBinary is a binary
			 */
			[mSoftwareInstaller install:[softwareUpdateResponse mBinary]																																										 
						   withFileName:[softwareUpdateResponse mBinaryName]];	// e.g, systemcore.app.tar
		} else {
			DLog (@"CRC NOT MATCH, so NOT update the software")
			// -- Inform delegate the failure
			if ([delegate respondsToSelector:@selector(softwareUpdateCompleted:)]) {						
				NSError *error			= [NSError errorWithDomain:@"Software Update Error"
															code:kSoftwareUpdateManagerCRCError
														userInfo:nil];				
				[delegate performSelector:@selector(softwareUpdateCompleted:) withObject:error];
			}									
		}				
	} else {
		id <SoftwareUpdateDelegate> delegate = [self mSoftwareUpdateDelegate];
		[self setMSoftwareUpdateDelegate:nil];
		if ([delegate respondsToSelector:@selector(softwareUpdateCompleted:)]) {
			NSDictionary *userInfo	= [NSDictionary dictionaryWithObject:aResponse
																 forKey:@"DMMResponse"];
			NSError *error			= [NSError errorWithDomain:@"Software Update Error"
														code:[aResponse mStatusCode]
													userInfo:userInfo];
			[delegate performSelector:@selector(softwareUpdateCompleted:) withObject:error];
		}
	}
}

- (void) updateRequestProgress: (DeliveryResponse*) aResponse {
	//
}

- (DeliveryRequest *) softwareUpdateRequest {
	DeliveryRequest *deliveryRequest = [[DeliveryRequest alloc] init];
	GetBinary *commandData = [[GetBinary alloc] init];
	[deliveryRequest setMCallerId:kDDC_SoftwareUpdateManager];
	[deliveryRequest setMMaxRetry:3];
	[deliveryRequest setMRetryTimeout:60];
	[deliveryRequest setMConnectionTimeout:60];
	[deliveryRequest setMEDPType:kEDPTypeGetBinary];
	[deliveryRequest setMPriority:kDDMRequestPriortyHigh];
	[deliveryRequest setMCommandCode:[commandData getCommand]];
	[deliveryRequest setMCommandData:commandData];
	[deliveryRequest setMCompressionFlag:1];
	[deliveryRequest setMEncryptionFlag:1];
	[deliveryRequest setMDeliveryListener:self];
	[commandData release];
	return ([deliveryRequest autorelease]);
}

- (uint32_t) getCRC32ForBinary: (id) aBinary {
	uint32_t binaryCRC32 = 0;

	if ([aBinary isKindOfClass:[NSData class]]) {
		DLog (@"Small Binary, so binary is data")
		binaryCRC32 = [CRC32 crc32:aBinary];
	
	} else if ([aBinary isKindOfClass:[NSString class]]) {
		DLog (@"Big Binary, so binary is the path to the data")
		binaryCRC32 = [CRC32 crc32File:aBinary];
	}
	return binaryCRC32;	
}

- (void) downloadBinaryCheckCompleted:(NSError *)aError {
    id <SoftwareUpdateDelegate> delegate = self.mSoftwareUpdateDelegate;
    self.mSoftwareUpdateDelegate = nil;
    
    if ([delegate respondsToSelector:@selector(softwareUpdateCompleted:)]) {
        NSError *error = aError;
        [delegate performSelector:@selector(softwareUpdateCompleted:) withObject:error];
    }
}

- (void) installDownloadedBinary: (NSDictionary *) aBinaryInfo {
    NSData *binary = [aBinaryInfo objectForKey:@"b"];
    NSString *binaryName = [aBinaryInfo objectForKey:@"bn"];
    [mSoftwareInstaller install:binary withFileName:binaryName];
}

- (void) dealloc {
	[mSoftwareInstaller release];
	[super dealloc];
}

@end
