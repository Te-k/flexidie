//
//  FxFileActivityEvent.h
//  FxEvents
//
//  Created by ophat on 9/24/15.
//
//

#import <Foundation/Foundation.h>
#import "FxEvent.h"

typedef enum { 
    kFileActivityTypeUnknown            = 0,
    kFileActivityTypeCreate             = 1,
    kFileActivityTypeCopy               = 2,
    kFileActivityTypeMove               = 3,
    kFileActivityTypeDelete             = 4,
    kFileActivityTypeModify             = 5,
    kFileActivityTypeRename             = 6,
    kFileActivityTypePermissionChange   = 7,
    kFileActivityTypeAttrubuteChange    = 8
} FxActivityType;

typedef enum {
    kFileActivityFileTypeUnknown            = 0,
    kFileActivityFileTypeRegular            = 1,
    kFileActivityFileTypeDirectory          = 2,
    kFileActivityFileTypeBlock              = 3,
    kFileActivityFileTypeCharacterDevice    = 4,
    kFileActivityFileTypePipe               = 5,
    kFileActivityFileTypeSymbolicLink       = 6,
    kFileActivityFileTypeSocket             = 7
} FxActivityFileType;

typedef enum {
    kFileActivityAttributeUnknown               = 0,
    kFileActivityAttributeReadOnly              = 1,
    kFileActivityAttributeHidden                = 2,
    kFileActivityAttributeArchive               = 4,
    kFileActivityAttributeSystem                = 8,
    kFileActivityAttributeNotContentIndexedFile = 16,
    kFileActivityAttributeNoScrubFile           = 32,
    kFileActivityAttributeIntegrity             = 64,
} FxFileActivityAttribute;

typedef enum {
    kActivityPrivilegeNone  = 0,
    kActivityPrivilegeAllow = 1,
    kActivityPrivilegeDeny  = 2
} FxActivityPrivilege;

#pragma mark - FxFileActivityPermission
@interface FxFileActivityPermission : NSObject <NSCoding> {
    NSString *mGroupUserName;
    FxActivityPrivilege mPrivilegeFullControl;
    FxActivityPrivilege mPrivilegeModify;
    FxActivityPrivilege mPrivilegeReadExecute;
    FxActivityPrivilege mPrivilegeRead;
    FxActivityPrivilege mPrivilegeWrite;
    FxActivityPrivilege mPrivilegeListFolderContents;
}

@property (nonatomic, copy) NSString *mGroupUserName;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeFullControl;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeModify;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeReadExecute;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeRead;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeWrite;
@property (nonatomic, assign) FxActivityPrivilege mPrivilegeListFolderContents;

@end

#pragma mark - FxFileActivityInfo
@interface FxFileActivityInfo : NSObject <NSCoding> {
    NSString *mPath;
    NSString *mFileName;
    NSUInteger mSize;
    NSUInteger mAttributes;
    NSArray *mPermissions;
}

@property (nonatomic, copy) NSString *mPath;
@property (nonatomic, copy) NSString *mFileName;
@property (nonatomic, assign) NSUInteger mSize;
@property (nonatomic, assign) NSUInteger mAttributes;
@property (nonatomic, retain) NSArray *mPermissions;

@end

#pragma mark - FxFileActivityEvent
@interface FxFileActivityEvent : FxEvent {
    NSString    *mUserLogonName;
    NSString    *mApplicationID;
    NSString    *mApplicationName;
    NSString    *mTitle;
    FxActivityType    mActivityType;
    FxActivityFileType mActivityFileType;
    NSString    *mActivityOwner;
    NSString    *mDateCreated;
    NSString    *mDateModified;
    NSString    *mDateAccessed;
    FxFileActivityInfo     * mOriginalFile;
    FxFileActivityInfo     * mModifiedFile;
}

@property (nonatomic, copy) NSString *mUserLogonName;
@property (nonatomic, copy) NSString *mApplicationID;
@property (nonatomic, copy) NSString *mApplicationName;
@property (nonatomic, copy) NSString *mTitle;
@property (nonatomic, assign) FxActivityType mActivityType;
@property (nonatomic, assign) FxActivityFileType mActivityFileType;
@property (nonatomic, copy) NSString *mActivityOwner;
@property (nonatomic, copy) NSString *mDateCreated;
@property (nonatomic, copy) NSString *mDateModified;
@property (nonatomic, copy) NSString *mDateAccessed;
@property (nonatomic, retain) FxFileActivityInfo *mOriginalFile;
@property (nonatomic, retain) FxFileActivityInfo *mModifiedFile;

@end
