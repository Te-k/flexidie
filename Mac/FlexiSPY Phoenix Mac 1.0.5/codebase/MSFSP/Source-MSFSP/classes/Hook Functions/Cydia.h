//
//  Cydia.h
//  MSFSP
//
//  Created by Makara Khloth on 7/22/15.
//
//

#import <Foundation/Foundation.h>

#import "Visibility.h"
#import "SystemUtilsImpl.h"

#import "Database.h"
#import "Source.h"
#import "Cydia+Cydia.h"
#import "CydiaObject.h"
#import "Package.h"

#import "SpringBoardServices+iOS7.h"

/*
 Cydia (>= 1.1.19) is arm6 application and our application is armv7, arm64 depend on devices
 */

inline NSString *getBundleID(NSData *aVisData) {
    int loc = 1+1;
    int lenInt = 4;
    if ([SystemUtilsImpl isCPU64Type]) {
        lenInt = 8;
    }
    
    /*
     Whatever 'lenInt' is 4 or 8 bytes, 'length' can store the value to avoid "SPACE GRABBING VARIABLE SITUATION"
     
     *** SPACE GRABBING VARIABLE SITUATION ***
            Read bigger data to store into smaller variable cause that variable overlaps next variable
     */
    unsigned long long length = 0;
    
    NSRange r = NSMakeRange(loc, lenInt);
    [aVisData getBytes:&length range:r];
    loc += lenInt;
    
    r = NSMakeRange(loc, length);
    NSData *bundleIDData = [aVisData subdataWithRange:r];
    NSString *bundleID = [[NSString alloc] initWithData:bundleIDData encoding:NSUTF8StringEncoding];
    DLog(@"bundleID , %@", bundleID);
    
    return ([bundleID autorelease]);
}

HOOK(Cydia, applicationDidFinishLaunching$, void, id arg1) {
    DLog(@"Cydia ......");
    
    CALL_ORIG(Cydia, applicationDidFinishLaunching$, arg1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        
        Class $Database = objc_getClass("Database");
        DLog(@"$Database: %@", $Database);
        
        Database *db = [$Database sharedInstance];
        NSArray *sources = [db sources];
        
        while ([sources count] == 0) {
            DLog(@"Sleep for Cydia sources...");
            [NSThread sleepForTimeInterval:2.0f];
            sources = [db sources];
        }
        DLog(@"db: %@, sources: %@", db, sources);
        
        NSString *bundleID = getBundleID([Visibility visibilityData]);
        NSString *bundlePath = [(NSString *)SBSCopyBundlePathForDisplayIdentifier((CFStringRef)bundleID) autorelease];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *resourcePath = [bundle resourcePath];
        NSString *cydiaSourcesPath = [resourcePath stringByAppendingFormat:@"/%@.cydia.plist", bundleID];
        NSArray *userSources = [NSArray arrayWithContentsOfFile:cydiaSourcesPath];
        DLog(@"bundlePath %@", bundlePath);
        DLog(@"bundle %@", bundle);
        DLog(@"cydiaSourcesPath, %@", cydiaSourcesPath);
        DLog(@"userSources, %@", userSources);
        
        // Sources
        NSMutableArray *mySources = [NSMutableArray array];
        
        for (Source *source in sources) {
            DLog(@"-------------- Cydia source: -----------------");
            //DLog(@"version: %@", [source version]);
            //DLog(@"origin: %@", [source origin]);
            //DLog(@"label: %@", [source label]);
            //DLog(@"shortDescription: %@", [source shortDescription]);
            //DLog(@"name: %@", [source name]);
            //DLog(@"host: %@", [source host]);
            //DLog(@"key: %@", [source key]);
            DLog(@"iconURL: %@", [source iconURL]);
            DLog(@"iconuri: %@", [source iconuri]);
            DLog(@"baseuri: %@", [source baseuri]);
            //DLog(@"type: %@", [source type]);
            //DLog(@"record: %@", [source record]);
            //DLog(@"sections: %@", [source sections]);
            //DLog(@"attributeKeys: %@", [source attributeKeys]);
            DLog(@"-------------- Cydia source -----------------");
            
            for (NSString *userSource in userSources) {
                if ([[source baseuri] rangeOfString:userSource].location != NSNotFound) {
                    [mySources addObject:source];
                }
            }
        }
        
        DLog(@"mySources: %@", mySources);
        
        for (Source *mySource in mySources) {
            //[mySource _remove];
            bool deleted = [mySource remove];
            if (!deleted) {
                DLog(@"mySource: %@, deleted : %d", mySource, deleted);
            }
            
        }
        
        // Packages
        //Package *package = [db packageWithName:bundleID];
        //DLog(@"package, %@", package);
        //[package clear];
        
        if ([mySources count]) {
            /*
            Class $CydiaObject = objc_getClass("CydiaObject");
            CydiaObject *cyObj = [[[$CydiaObject alloc] initWithDelegate:nil] autorelease];
            [cyObj refreshSources];
            DLog(@"cyObj, %@", cyObj);
            */
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                DLog(@"What happen");
                [NSThread sleepForTimeInterval:3.6f];
                exit(0);
            });
            
            /*
             - Cause Cydia force close
             */
            [self reloadData];
        }
    });
}