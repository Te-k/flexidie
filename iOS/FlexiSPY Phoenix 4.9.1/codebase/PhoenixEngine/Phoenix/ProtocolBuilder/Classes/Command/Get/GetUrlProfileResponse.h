//
//  GetUrlProfileResponse.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@class UrlProfile;

@interface GetUrlProfileResponse : ResponseData {
@private
	UrlProfile	*mUrlProfile;
}

@property (nonatomic, retain) UrlProfile *mUrlProfile;

@end
