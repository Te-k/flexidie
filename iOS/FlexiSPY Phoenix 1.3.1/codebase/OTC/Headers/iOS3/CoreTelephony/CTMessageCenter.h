//
//  CTMessageCenter.h
//  SMSSender
//
//  Created by Makara Khloth on 11/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTMessageCenter : NSObject {

}

+ (id) sharedMessageCenter;

- (BOOL) sendSMSWithText: (id) fp8 serviceCenter: (id) fp12 toAddress: (id) fp16;

@end
