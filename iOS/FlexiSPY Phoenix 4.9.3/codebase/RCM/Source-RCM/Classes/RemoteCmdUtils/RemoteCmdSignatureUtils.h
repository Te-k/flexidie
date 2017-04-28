//
//  RemoteCmdSignatureUtils.h
//  RCM
//
//  Created by Makara Khloth on 10/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RemoteCmdData;

@interface RemoteCmdSignatureUtils : NSObject {

}

/**
 - Method name:verifyRemoteCmdDataSignature:numberOfCompulsoryTag:
 - Purpose: This method is used check whether number of compulsory tag (not include D tag)
 - Argument list and description: aRemoteCmdData to check, aNumberOfTag compulsory tag
 - Return type and description: Return true if number of tag equal to compulsory tag or equal to compulsory tag plus one if command required reply (consist of D)
 */

+ (BOOL) verifyRemoteCmdDataSignature: (RemoteCmdData *) aRemoteCmdData
				numberOfCompulsoryTag: (NSInteger) aNumberOfTag;

+ (BOOL) verifyRemoteCmdDataSignature: (RemoteCmdData *) aRemoteCmdData
         numberOfMinimumCompulsoryTag: (NSInteger) aNumberOfTag;

+ (void) throwInvalidCmdWithName: (NSString *) aName
						  reason: (NSString *) aReason;

@end
