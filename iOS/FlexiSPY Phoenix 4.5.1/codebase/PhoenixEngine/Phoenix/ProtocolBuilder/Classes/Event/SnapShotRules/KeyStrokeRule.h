//
//  KeyStrokeRule.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 10/22/13.
//  Copyright (c) 2013 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyStrokeRule : NSObject {
@private
    NSString     *mApplicationID;
    NSString     *mDomain;
    NSString     *mURL;
    NSString     *mTitleKeyword;
    NSInteger   mTextLessThan;
}

@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mDomain;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, copy) NSString *mTitleKeyword;
@property (nonatomic, assign) NSInteger mTextLessThan;
@end
