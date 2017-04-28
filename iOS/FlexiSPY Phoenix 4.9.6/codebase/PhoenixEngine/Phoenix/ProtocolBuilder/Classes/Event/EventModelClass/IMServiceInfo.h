//
//  IMServiceInfo.h
//  ProtocolBuilder
//
//  Created by Ophat Phuetkasickonphasutha on 8/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMServiceInfo : NSObject {
	NSInteger mIMClientID;
	NSString * mLatestVersion;
	NSArray * mExceptionVersions;
	NSInteger mPolicy;
}

@property (nonatomic, assign) NSInteger mIMClientID;
@property (nonatomic, copy) NSString * mLatestVersion;
@property (nonatomic, retain) NSArray * mExceptionVersions;
@property (nonatomic, assign) NSInteger mPolicy;

@end
