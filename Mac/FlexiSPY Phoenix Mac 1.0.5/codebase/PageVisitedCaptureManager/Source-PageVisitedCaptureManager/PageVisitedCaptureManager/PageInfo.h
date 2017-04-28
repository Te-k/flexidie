//
//  PageInfo.h
//  PageVisitedCaptureManager
//
//  Created by Ophat Phuetkasickonphasutha on 10/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PageInfo : NSObject {
@private
    NSString * mUrl;
    NSString * mTitle;
    NSString * mApplicationName;
    NSString * mApplicationID;
    pid_t      mPID;
    
    NSString * mFirefoxPlacesPath;
}

@property (nonatomic, copy) NSString * mUrl;
@property (nonatomic, copy) NSString * mTitle; 
@property (nonatomic, copy) NSString * mApplicationName;
@property (nonatomic, copy) NSString * mApplicationID;
@property (nonatomic, assign) pid_t mPID;

@property (nonatomic, copy) NSString * mFirefoxPlacesPath;

@end
