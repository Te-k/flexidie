//
//  IconUtils.h
//  ApplicationManager
//
//  Created by Benjawan Tanarattanakorn on 12/18/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IconUtils : NSObject {

}

+ (NSString *)	getIconNameFromPlist: (NSDictionary *) aAppInfo;
+ (NSArray *)	getIconNamesFromPlist: (NSDictionary *) aAppInfo;
+ (NSArray *)	getHighResolutionIconsNameFromIcons: (NSArray *) aFilenameArray;

+ (BOOL)		isPNGExist: (NSString *) aFilename;
+ (BOOL)		isJPGExist: (NSString *) aFilename;
+ (NSString *)	addPNGIfNotExist: (NSString *) aFilename;
+ (NSArray *)	defaultIconNames;

@end
