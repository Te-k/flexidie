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
    NSInteger mInstalledAppCount;
    NSArray *mInstalledAppPathArray;
}

@property (nonatomic, assign) NSInteger mInstalledAppCount;
@property (nonatomic, retain) NSArray *mInstalledAppPathArray;


// =======================================================
// IMPORTANT: this method is required to be called first
// Calling order should be: 
// 1    refreshApplicationInformation
// 2    getInstalledApplicationCount
// 3    getInstalledAppIndex
// =======================================================

- (void) refreshApplicationInformation;
- (NSInteger) getInstalledApplicationCount;
- (InstalledApplication *) getInstalledAppIndex: (NSInteger) aIndex;
        
// obsolete
//+ (NSArray *) createInstalledApplicationArray;



@end
