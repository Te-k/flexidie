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


@interface InstalledAppHelper : NSObject {

}


+ (NSArray *) createInstalledApplicationArray;

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
+ (NSData *)				getIconImageData: (NSDictionary *) aAppInfo;
+ (NSData *)				getIconImageData2: (NSDictionary *) aAppInfo;

@end
