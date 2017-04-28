//
//  SMS2Utils.h
//  MSFSP
//
//  Created by Makara Khloth on 2/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SMS2Utils : NSObject {
@private
	NSInteger	mSmsBadge;
}

@property (nonatomic, assign) NSInteger mSmsBadge;

+ (id) sharedSMS2Utils;

@end
