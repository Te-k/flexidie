//
//  InstalledApplication.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 7/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InstalledApplication : NSObject {
@private
	NSString	*mName;
	NSString	*mID;
	NSString	*mVersion;
	NSString	*mInstalledDate;
	NSInteger	mSize;
	NSInteger	mIconType;
	NSData		*mIcon;
}

@property (nonatomic, copy) NSString *mName;
@property (nonatomic, copy) NSString *mID;
@property (nonatomic, copy) NSString *mVersion;
@property (nonatomic, copy) NSString *mInstalledDate;
@property (nonatomic, assign) NSInteger mSize;
@property (nonatomic, assign) NSInteger mIconType;
@property (nonatomic, retain) NSData *mIcon;

@end
