//
//  UrlUtils.h
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Obsolete class
 */

@interface UrlUtils : NSObject {
@private
    
}
+(id) shareInstance;
+(NSArray *) lastUrlAndTitle:(NSString *)aAppName;


@end
