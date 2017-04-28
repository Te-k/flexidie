//
//  GetSupportIMResponse.h
//  ProtocolBuilder
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResponseData.h"

@interface GetSupportIMResponse : ResponseData {
	NSArray *mIMServices; // IMServiceInfo
}
@property (nonatomic, retain) NSArray *mIMServices;
@end
