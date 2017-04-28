//
//  FirefoxGetInfo.m
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 3/6/15.
//
//

#import "FirefoxGetInfo.h"

#import "FMDatabase.h"
#import "FMResultSet.h"

@interface FirefoxGetInfo (private)
- (void) searchFirefoxDatabasePath;
- (NSString *) searchFileName: (NSString *) aFileName inDirectory: (NSString *) aDirectory;
@end

@implementation FirefoxGetInfo

@synthesize mFirefoxDatabasePath;

- (NSDictionary *) lastUrlInfo {
    NSDictionary *urlInfo = nil;
    
    [self searchFirefoxDatabasePath];
    
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
    
    [self searchFirefoxDatabasePath];
    
    if ([self.mFirefoxDatabasePath length] > 0) {
        FMDatabase *db = [FMDatabase databaseWithPath:self.mFirefoxDatabasePath];
        [db open];
        NSString *sql = @"select * from moz_places where title = ?";
        FMResultSet *rs = [db executeQuery:sql, aTitle];
        if ([rs next]) {
            NSString *url = [rs stringForColumn:@"url"];
//            NSString *title = [rs stringForColumn:@"title"];
//            DLog(@"url      = %@", url);
//            DLog(@"title    = %@", title);
            
            URL = url;
        }
        [db close];
    }
    return (URL);
}

- (void) searchFirefoxDatabasePath {
    if (self.mFirefoxDatabasePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *applicationSupportPath = [paths firstObject];
        NSString *firefoxApplicationSupport = [applicationSupportPath stringByAppendingString:@"/Firefox/Profiles/"];
        NSString *dbOfFirefoxPath = [self searchFileName:@"places.sqlite" inDirectory:firefoxApplicationSupport];
        self.mFirefoxDatabasePath = dbOfFirefoxPath;
        DLog(@"dbOfFirefoxPath = %@", dbOfFirefoxPath);
    }
}

- (NSString *) searchFileName: (NSString *) aFileName inDirectory: (NSString *) aDirectory {
    NSString *fileItemFullPath = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileItems = [fileManager contentsOfDirectoryAtPath:aDirectory error:nil];
    for (NSString *fileItem in fileItems) {
        NSString *fullPath = [NSString stringWithFormat:@"%@%@", aDirectory, fileItem];
        NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:fullPath error:nil];
        if (![[fileAttr fileType] isEqualToString:NSFileTypeDirectory]) {
            if ([fileItem isEqualToString:aFileName]) {
                fileItemFullPath = fullPath;
                break;
            }
        } else {
            fullPath = [NSString stringWithFormat:@"%@%@/", aDirectory, fileItem];
            fileItemFullPath = [self searchFileName:aFileName inDirectory:fullPath];
            if (fileItemFullPath != nil) {
                break;
            }
        }
    }
    return (fileItemFullPath);
}

- (void) dealloc {
    [mFirefoxDatabasePath release];
    [super dealloc];
}

@end
