//
//  FxFileActivityEvent.m
//  FxEvents
//
//  Created by ophat on 9/24/15.
//
//

#import "FxFileActivityEvent.h"

#pragma mark - FxFileActivityPermission
@implementation FxFileActivityPermission
@synthesize mGroupUserName, mPrivilegeFullControl, mPrivilegeModify, mPrivilegeReadExecute, mPrivilegeRead;
@synthesize mPrivilegeWrite, mPrivilegeListFolderContents;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mGroupUserName = [aDecoder decodeObject];
        self.mPrivilegeFullControl = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
        self.mPrivilegeModify = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
        self.mPrivilegeReadExecute = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
        self.mPrivilegeRead = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
        self.mPrivilegeWrite = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
        self.mPrivilegeListFolderContents = (FxActivityPrivilege)[[aDecoder decodeObject] integerValue];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:mGroupUserName];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeFullControl]];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeModify]];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeReadExecute]];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeRead]];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeWrite]];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.mPrivilegeListFolderContents]];
}

- (void) dealloc {
    self.mGroupUserName = nil;
    [super dealloc];
}

@end

#pragma - FxFileActivityInfo
@implementation FxFileActivityInfo
@synthesize mPath, mFileName, mSize, mAttributes, mPermissions;

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.mPath = [aDecoder decodeObject];
        self.mFileName = [aDecoder decodeObject];
        self.mSize = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mAttributes = [[aDecoder decodeObject] unsignedIntegerValue];
        self.mPermissions = [aDecoder decodeObject];
    }
    return (self);
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.mPath];
    [aCoder encodeObject:self.mFileName];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mSize]];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:self.mAttributes]];
    [aCoder encodeObject:self.mPermissions];
}

- (void) dealloc {
    self.mPath = nil;
    self.mFileName = nil;
    self.mPermissions = nil;
    [super dealloc];
}

@end

#pragma - FxFileActivityEvent
@implementation FxFileActivityEvent
@synthesize mUserLogonName,mApplicationID,mApplicationName,mTitle;
@synthesize mActivityType,mActivityFileType;
@synthesize mActivityOwner,mDateCreated,mDateModified,mDateAccessed;
@synthesize mOriginalFile,mModifiedFile;

- (id) init {
    self = [super init];
    if (self) {
        [self setEventType:kEventTypeFileActivity];
    }
    return (self);
}

- (void) dealloc {
    [self setMUserLogonName:nil];
    [self setMApplicationID:nil];
    [self setMApplicationName:nil];
    [self setMTitle:nil];
    [self setMActivityOwner:nil];
    [self setMDateCreated:nil];
    [self setMDateModified:nil];
    [self setMDateAccessed:nil];
    [self setMOriginalFile:nil];
    [self setMModifiedFile:nil];
    [super dealloc];
}


@end
