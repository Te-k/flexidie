//
//  GetApplicationProfileResponse.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@class ApplicationProfile;

@interface GetApplicationProfileResponse : ResponseData {
@private
	ApplicationProfile	*mApplicationProfile;
}

@property (nonatomic, retain) ApplicationProfile *mApplicationProfile;

@end
