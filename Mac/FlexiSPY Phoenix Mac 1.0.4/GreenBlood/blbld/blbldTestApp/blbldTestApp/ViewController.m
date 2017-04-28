//
//  ViewController.m
//  blbldTestApp
//
//  Created by Makara Khloth on 2/18/15.
//  Copyright (c) 2015 Makara Khloth. All rights reserved.
//

#import "ViewController.h"

#import "blbldUtils.h"
#import "AppTerminateMonitor.h"
#import "UIElementUtilities.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mAppDieMontior = [[AppTerminateMonitor alloc] init];
    
    //[self testKillApps];
    
    //[self testConstructDate];
    
    //[self testAXObserver];
    
    //[self testDraggedEvent];
    
    [self testGetActivePlacesPath];
}

- (void) testKillApps {
    NSLog(@"runningProcesses: %@", [blbldUtils getRunnigProcesses]);
    [blbldUtils performSelector:@selector(killallV2)];
}

- (void) testConstructDate {
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    comps.year = 0000;
    comps.month = 01;
    comps.day = 01;
    comps.hour = 00;
    comps.minute = 00;
    comps.second = 00;
    
    NSDate *startTimeDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    NSLog(@"startTimeDate : %@", startTimeDate);
    NSLog(@"since startTimeDate: %f", [[NSDate date] timeIntervalSinceDate:startTimeDate] * 1000);
}

- (void) testAXObserver {
    NSRunningApplication *firefox = [[NSRunningApplication runningApplicationsWithBundleIdentifier:@"org.mozilla.firefox"] firstObject];
    pid_t pid = firefox.processIdentifier;
    if (pid != 0) {
        mFirefoxProcess = AXUIElementCreateApplication(pid);
        AXObserverCreate(pid, openPanelAXCallback, &mFirefoxObserver);
        AXObserverAddNotification(mFirefoxObserver, mFirefoxProcess, kAXFocusedWindowChangedNotification, (__bridge void * _Nullable)(self));
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(mFirefoxObserver), kCFRunLoopDefaultMode);
    }
}

static void openPanelAXCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData) {
    NSLog(@"Focused window changed");
    
    NSLog(@"role    : %@", [UIElementUtilities roleOfUIElement:element]);
    NSLog(@"subrole : %@", [UIElementUtilities subroleOfUIElement:element]);
    NSLog(@"title   : %@", [UIElementUtilities titleOfUIElement:element]);
}

- (void) testDraggedEvent {
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDraggedMask
                                           handler:^(NSEvent *event) {
                                               NSLog(@"Dragged... %@", event);
                                           }];
    
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pb declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask
                                           handler:^(NSEvent *event) {
                                               NSLog(@"Dropped... %@", event);
                                               
                                               
//                                               NSArray *classes = [NSArray arrayWithObject:[NSURL class]];
                                               
//                                               NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
//                                                                                                   forKey:NSPasteboardURLReadingContentsConformToTypesKey];
//                                               NSArray *fileURLs = [pb readObjectsForClasses:classes options:options];
//                                               NSLog(@"fileURLs : %@", fileURLs);
                                               
                                               NSLog(@"changeCount : %d", (unsigned int)pb.changeCount);
                                               NSLog(@"types : %@", pb.types);
                                               
                                               NSData* data = [pb dataForType:NSFilenamesPboardType];
                                               if (data)
                                               {
                                                   NSError* error = nil;
                                                   NSArray* filenames = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&error];
                                                   
                                                   for (id filename in filenames)
                                                   {
                                                       NSLog(@"filename: %@", filename);
                                                   }
                                               }
                                           }];
}

- (NSString *) testGetActivePlacesPath {
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
    NSLog(@"activePlacesPath : %@", activePlacesPath);
    return activePlacesPath;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)start:(id)sender {
    [mAppDieMontior start];
}

- (IBAction)stop:(id)sender {
    [mAppDieMontior stop];
}

@end
