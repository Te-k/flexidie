//
//  SoftwareUpdateManager.h
//  SoftwareUpdateManager
//
//  Created by Ophat Phuetkasickonphasutha on 6/17/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SoftwareUpdateDelegate;


// Error Code
typedef enum {
	kSoftwareUpdateManagerCRCError						= 1, 
} SoftwareUpdateManagerErrorCode;


@protocol SoftwareUpdateManager <NSObject>

- (BOOL) updateSoftware: (id<SoftwareUpdateDelegate>) aDelegate;
- (BOOL) updateSoftware: (id<SoftwareUpdateDelegate>) aDelegate url: (NSString *) url checksum: (NSString *) aChecksum;

@end
