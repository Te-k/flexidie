//
//  InstalledAppHelper.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 7/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	kApplicationOwnerSystem = 1,
	kApplicationOwnerUser = 2
} ApplicationOwner ;

@class InstalledApplication;

@interface InstalledAppHelper : NSObject {

}

// obsoleted, use the two methods below
//+ (NSArray *) createInstalledApplicationArray;

+ (NSArray *) createInstalledApplicationMetadataArray;
+ (InstalledApplication *) getInstalledApplicationForAppMetadataInfo: (NSDictionary *) aAppMetadataInfo;

// Utility methods
// -- name
+ (NSString *)				getAppName: (NSDictionary *) aAppInfo;
// -- version
+ (NSString *)				getAppVersion: (NSDictionary *) aAppInfop;
// -- size
+ (unsigned long long int)	folderSize: (NSString *) folderPath;
+ (NSInteger)				getAppSize: (NSString *) aAppPath;
// -- installed date
+ (NSString *)				getInstalledDate: (NSString *) aAppPath;
// -- icon

// obsolete for this project, use the two methods below. However, other component may use it
+ (NSData *)				getIconImageData: (NSDictionary *) aAppInfo;

+ (NSData *)                getIconImageData2: (NSDictionary *) aAppInfo path: (NSString *)aAppPath;
+ (NSData *)                getIconImageDataForIdentifier: (NSString *) aIdentifier;
@end
