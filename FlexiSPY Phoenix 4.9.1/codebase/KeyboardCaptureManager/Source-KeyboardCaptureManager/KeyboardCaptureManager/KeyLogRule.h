//
//  KeyRole.h
//  KeyboardCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyLogRule : NSObject {
@private
    NSString    *mApplicationID;
    NSString    *mDomain;
    NSString    *mURL;
    NSString    *mTitleKeyword;
    NSInteger   mTextLessThan;
}

@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mDomain;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, copy) NSString *mTitleKeyword;
@property (nonatomic, assign) NSInteger mTextLessThan;

@end

