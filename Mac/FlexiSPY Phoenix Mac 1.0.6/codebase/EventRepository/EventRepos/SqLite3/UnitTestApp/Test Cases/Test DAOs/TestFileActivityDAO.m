//
//  TestFileActivityDAO.m
//  UnitTestApp
//
//  Created by Makara Khloth on 9/29/15.
//
//

#import <GHUnitIOS/GHUnit.h>
#import "DatabaseManager.h"

#import "DAOFactory.h"
#import "DetailedCount.h"
#import "DefCommonEventData.h"

#import "FxFileActivityEvent.h"
#import "FileActivityDAO.h"

static NSString* const kEventDateTime  = @"11:11:11 2011-11-11";

@interface TestFileActivityDAO : GHTestCase {
@private
    DatabaseManager*  mDatabaseManager;
}

@end

@implementation TestFileActivityDAO

- (void) setUp {
    if (!mDatabaseManager) {
        mDatabaseManager = [[DatabaseManager alloc] init];
        [mDatabaseManager dropDB];
    } else {
        [mDatabaseManager dropDB];
    }
}

- (void) tearDown {
    
}

- (void) testNormalTest {
    FxFileActivityEvent* event = [[FxFileActivityEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActivityType = kFileActivityTypeCopy;
    event.mActivityFileType = kFileActivityFileTypeDirectory;
    event.mActivityOwner = @"Siriluk";
    event.mDateCreated = @"11:11:11 2010-11-11";
    event.mDateModified = @"11:11:11 2015-07-11";
    event.mDateAccessed = @"11:11:11 2015-09-11";
    
    // Original
    FxFileActivityInfo *original = [[[FxFileActivityInfo alloc] init] autorelease];
    original.mPath = @"/Users/makara/spyCall.h";
    original.mFileName = @"spyCall.h";
    original.mSize = 1024;
    original.mAttributes = kFileActivityAttributeReadOnly | kFileActivityAttributeNotContentIndexedFile;
    
    FxFileActivityPermission *originalPermision1 = [[[FxFileActivityPermission alloc] init] autorelease];
    originalPermision1.mGroupUserName = @"makara";
    originalPermision1.mPrivilegeFullControl = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeModify = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeRead = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeWrite = kActivityPrivilegeDeny;
    originalPermision1.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    FxFileActivityPermission *originalPermision2 = [[[FxFileActivityPermission alloc] init] autorelease];
    originalPermision2.mGroupUserName = @"Administrator";
    originalPermision2.mPrivilegeFullControl = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeModify = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeRead = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeWrite = kActivityPrivilegeDeny;
    originalPermision2.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    original.mPermissions = [NSArray arrayWithObjects:originalPermision1, originalPermision2, nil];
    
    // Modified
    FxFileActivityInfo *modified = [[[FxFileActivityInfo alloc] init] autorelease];
    modified.mPath = @"/Volumns/Kinstone/hack/spyCall.h";
    modified.mFileName = @"spyCall.h";
    modified.mSize = 1024;
    modified.mAttributes = kFileActivityAttributeReadOnly | kFileActivityAttributeNotContentIndexedFile;
    
    FxFileActivityPermission *modifiedPermision1 = [[[FxFileActivityPermission alloc] init] autorelease];
    modifiedPermision1.mGroupUserName = @"Siriluk";
    modifiedPermision1.mPrivilegeFullControl = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeModify = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeRead = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeWrite = kActivityPrivilegeDeny;
    modifiedPermision1.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    FxFileActivityPermission *modifiedPermision2 = [[[FxFileActivityPermission alloc] init] autorelease];
    modifiedPermision2.mGroupUserName = @"root";
    modifiedPermision2.mPrivilegeFullControl = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeModify = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeRead = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeWrite = kActivityPrivilegeDeny;
    modifiedPermision2.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    modified.mPermissions = [NSArray arrayWithObjects:modifiedPermision1, modifiedPermision2, nil];
    
    event.mOriginalFile = original;
    event.mModifiedFile = modified;
    
    FileActivityDAO* dao = [DAOFactory dataAccessObject:[event eventType] withSqlite3:[mDatabaseManager sqlite3db]];
    [dao insertEvent:event];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 1, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:33];
    for (FxFileActivityEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings([event mApplicationName], [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mActivityType], [event1 mActivityType], @"Compare activity type");
        GHAssertEquals([event mActivityFileType], [event1 mActivityFileType], @"Compare activity file type");
        GHAssertEqualStrings([event mActivityOwner], [event1 mActivityOwner], @"Compare activity owner name");
        GHAssertEqualStrings([event mDateCreated], [event1 mDateCreated], @"Compare created date");
        GHAssertEqualStrings([event mDateModified], [event1 mDateModified], @"Compare modified date");
        GHAssertEqualStrings([event mDateAccessed], [event1 mDateAccessed], @"Compare accessed date");
        
        // Original
        GHAssertEqualStrings([[event mOriginalFile] mPath], [[event1 mOriginalFile] mPath], @"Compare original path");
        GHAssertEqualStrings([[event mOriginalFile] mFileName], [[event1 mOriginalFile] mFileName], @"Compare original path");
        GHAssertEquals([[event mOriginalFile] mSize], [[event1 mOriginalFile] mSize], @"Compare original size");
        GHAssertEquals([[event mOriginalFile] mAttributes], [[event1 mOriginalFile] mAttributes], @"Compare original attributes");
        
        for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
            GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
        }
        
        // Modified
        GHAssertEqualStrings([[event mModifiedFile] mPath], [[event1 mModifiedFile] mPath], @"Compare midified path");
        GHAssertEqualStrings([[event mModifiedFile] mFileName], [[event1 mModifiedFile] mFileName], @"Compare midified path");
        GHAssertEquals([[event mModifiedFile] mSize], [[event1 mModifiedFile] mSize], @"Compare midified size");
        GHAssertEquals([[event mModifiedFile] mAttributes], [[event1 mModifiedFile] mAttributes], @"Compare midified attributes");
        
        for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
            GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
        }
        
        GHAssertEquals(lastEventId, 1, @"Compare lastEventId with 1");
    }
    
    FxFileActivityEvent* tempEvent = (FxFileActivityEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mActivityType], [tempEvent mActivityType], @"Compare activity type");
    GHAssertEquals([event mActivityFileType], [tempEvent mActivityFileType], @"Compare activity file type");
    GHAssertEqualStrings([event mActivityOwner], [tempEvent mActivityOwner], @"Compare activity owner name");
    GHAssertEqualStrings([event mDateCreated], [tempEvent mDateCreated], @"Compare created date");
    GHAssertEqualStrings([event mDateModified], [tempEvent mDateModified], @"Compare modified date");
    GHAssertEqualStrings([event mDateAccessed], [tempEvent mDateAccessed], @"Compare accessed date");
    
    // Original
    GHAssertEqualStrings([[event mOriginalFile] mPath], [[tempEvent mOriginalFile] mPath], @"Compare original path");
    GHAssertEqualStrings([[event mOriginalFile] mFileName], [[tempEvent mOriginalFile] mFileName], @"Compare original path");
    GHAssertEquals([[event mOriginalFile] mSize], [[tempEvent mOriginalFile] mSize], @"Compare original size");
    GHAssertEquals([[event mOriginalFile] mAttributes], [[tempEvent mOriginalFile] mAttributes], @"Compare original attributes");
    
    for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    // Modified
    GHAssertEqualStrings([[event mModifiedFile] mPath], [[tempEvent mModifiedFile] mPath], @"Compare midified path");
    GHAssertEqualStrings([[event mModifiedFile] mFileName], [[tempEvent mModifiedFile] mFileName], @"Compare midified path");
    GHAssertEquals([[event mModifiedFile] mSize], [[tempEvent mModifiedFile] mSize], @"Compare midified size");
    GHAssertEquals([[event mModifiedFile] mAttributes], [[tempEvent mModifiedFile] mAttributes], @"Compare midified attributes");
    
    for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    NSString *newApplicationID = @"com.scb.mobilescb";
    NSString *newApplicationName = @"SCB Mobile Banking";
    [tempEvent setMApplicationID:newApplicationID];
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMActivityOwner:@"Ophat"];
    [tempEvent setMActivityType:kFileActivityTypeDelete];
    [dao updateEvent:tempEvent];
    tempEvent = (FxFileActivityEvent*)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings(newApplicationID, [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(newApplicationName, [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kFileActivityTypeDelete, [tempEvent mActivityType], @"Compare activity type");
    GHAssertEquals([event mActivityFileType], [tempEvent mActivityFileType], @"Compare activity file type");
    GHAssertEqualStrings(@"Ophat", [tempEvent mActivityOwner], @"Compare activity owner name");
    GHAssertEqualStrings([event mDateCreated], [tempEvent mDateCreated], @"Compare created date");
    GHAssertEqualStrings([event mDateModified], [tempEvent mDateModified], @"Compare modified date");
    GHAssertEqualStrings([event mDateAccessed], [tempEvent mDateAccessed], @"Compare accessed date");
    
    // Original
    GHAssertEqualStrings([[event mOriginalFile] mPath], [[tempEvent mOriginalFile] mPath], @"Compare original path");
    GHAssertEqualStrings([[event mOriginalFile] mFileName], [[tempEvent mOriginalFile] mFileName], @"Compare original path");
    GHAssertEquals([[event mOriginalFile] mSize], [[tempEvent mOriginalFile] mSize], @"Compare original size");
    GHAssertEquals([[event mOriginalFile] mAttributes], [[tempEvent mOriginalFile] mAttributes], @"Compare original attributes");
    
    for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    // Modified
    GHAssertEqualStrings([[event mModifiedFile] mPath], [[tempEvent mModifiedFile] mPath], @"Compare midified path");
    GHAssertEqualStrings([[event mModifiedFile] mFileName], [[tempEvent mModifiedFile] mFileName], @"Compare midified path");
    GHAssertEquals([[event mModifiedFile] mSize], [[tempEvent mModifiedFile] mSize], @"Compare midified size");
    GHAssertEquals([[event mModifiedFile] mAttributes], [[tempEvent mModifiedFile] mAttributes], @"Compare midified attributes");
    
    for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    [dao deleteEvent:lastEventId];
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    
    [event release];
}

- (void) testStressTest {
    FileActivityDAO* dao = [DAOFactory dataAccessObject:kEventTypeFileActivity withSqlite3:[mDatabaseManager sqlite3db]];
    DetailedCount* detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event");
    
    FxFileActivityEvent* event = [[FxFileActivityEvent alloc] init];
    event.dateTime = kEventDateTime;
    event.mUserLogonName = @"Ophat";
    event.mApplicationID = @"com.kbak.kmobile";
    event.mApplicationName = @"KBank Mobile";
    event.mTitle = @"iTune Connect";
    event.mActivityType = kFileActivityTypeCopy;
    event.mActivityFileType = kFileActivityFileTypeDirectory;
    event.mActivityOwner = @"Siriluk";
    event.mDateCreated = @"11:11:11 2010-11-11";
    event.mDateModified = @"11:11:11 2015-07-11";
    event.mDateAccessed = @"11:11:11 2015-09-11";
    
    // Original
    FxFileActivityInfo *original = [[[FxFileActivityInfo alloc] init] autorelease];
    original.mPath = @"/Users/makara/spyCall.h";
    original.mFileName = @"spyCall.h";
    original.mSize = 1024;
    original.mAttributes = kFileActivityAttributeReadOnly | kFileActivityAttributeNotContentIndexedFile;
    
    FxFileActivityPermission *originalPermision1 = [[[FxFileActivityPermission alloc] init] autorelease];
    originalPermision1.mGroupUserName = @"makara";
    originalPermision1.mPrivilegeFullControl = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeModify = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeRead = kActivityPrivilegeAllow;
    originalPermision1.mPrivilegeWrite = kActivityPrivilegeDeny;
    originalPermision1.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    FxFileActivityPermission *originalPermision2 = [[[FxFileActivityPermission alloc] init] autorelease];
    originalPermision2.mGroupUserName = @"Administrator";
    originalPermision2.mPrivilegeFullControl = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeModify = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeRead = kActivityPrivilegeAllow;
    originalPermision2.mPrivilegeWrite = kActivityPrivilegeDeny;
    originalPermision2.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    original.mPermissions = [NSArray arrayWithObjects:originalPermision1, originalPermision2, nil];
    
    // Modified
    FxFileActivityInfo *modified = [[[FxFileActivityInfo alloc] init] autorelease];
    modified.mPath = @"/Volumns/Kinstone/hack/spyCall.h";
    modified.mFileName = @"spyCall.h";
    modified.mSize = 1024;
    modified.mAttributes = kFileActivityAttributeReadOnly | kFileActivityAttributeNotContentIndexedFile;
    
    FxFileActivityPermission *modifiedPermision1 = [[[FxFileActivityPermission alloc] init] autorelease];
    modifiedPermision1.mGroupUserName = @"Siriluk";
    modifiedPermision1.mPrivilegeFullControl = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeModify = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeRead = kActivityPrivilegeAllow;
    modifiedPermision1.mPrivilegeWrite = kActivityPrivilegeDeny;
    modifiedPermision1.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    FxFileActivityPermission *modifiedPermision2 = [[[FxFileActivityPermission alloc] init] autorelease];
    modifiedPermision2.mGroupUserName = @"root";
    modifiedPermision2.mPrivilegeFullControl = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeModify = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeReadExecute = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeRead = kActivityPrivilegeAllow;
    modifiedPermision2.mPrivilegeWrite = kActivityPrivilegeDeny;
    modifiedPermision2.mPrivilegeListFolderContents = kActivityPrivilegeDeny;
    
    modified.mPermissions = [NSArray arrayWithObjects:modifiedPermision1, modifiedPermision2, nil];
    
    event.mOriginalFile = original;
    event.mModifiedFile = modified;
    
    NSInteger maxEventTest = 1000;
    NSInteger j;
    for (j = 0; j < maxEventTest; j++) {
        event.mApplicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        if (j % 2 == 0) {
            event.mActivityFileType = kFileActivityFileTypeRegular;
        } else {
            event.mActivityFileType = kFileActivityFileTypeSocket;
        }
        [dao insertEvent:event];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], maxEventTest, @"Count event after insert passed");
    
    NSInteger lastEventId = 0;
    NSArray* eventArray = [dao selectMaxEvent:maxEventTest];
    NSMutableArray* eventIdArray = [[NSMutableArray alloc] init];
    
    j = 0;
    for (FxFileActivityEvent* event1 in eventArray) {
        lastEventId = [event1 eventId];
        [eventIdArray addObject:[NSNumber numberWithInt:lastEventId]];
        NSString *applicationName = [NSString stringWithFormat:@"KBank Mobile v-%d", j];
        
        GHAssertEqualStrings([event dateTime], [event1 dateTime], @"Compare date time");
        GHAssertEqualStrings([event mUserLogonName], [event1 mUserLogonName], @"Compare user logon name");
        GHAssertEqualStrings([event mApplicationID], [event1 mApplicationID], @"Compare application ID");
        GHAssertEqualStrings(applicationName, [event1 mApplicationName], @"Compare application name");
        GHAssertEqualStrings([event mTitle], [event1 mTitle], @"Compare title");
        GHAssertEquals([event mActivityType], [event1 mActivityType], @"Compare activity type");
        if (j % 2 == 0) {
            GHAssertEquals(kFileActivityFileTypeRegular, [event1 mActivityFileType], @"Compare activity file type");
        } else {
            GHAssertEquals(kFileActivityFileTypeSocket, [event1 mActivityFileType], @"Compare activity file type");
        }
        GHAssertEqualStrings([event mActivityOwner], [event1 mActivityOwner], @"Compare activity owner name");
        GHAssertEqualStrings([event mDateCreated], [event1 mDateCreated], @"Compare created date");
        GHAssertEqualStrings([event mDateModified], [event1 mDateModified], @"Compare modified date");
        GHAssertEqualStrings([event mDateAccessed], [event1 mDateAccessed], @"Compare accessed date");
        
        // Original
        GHAssertEqualStrings([[event mOriginalFile] mPath], [[event1 mOriginalFile] mPath], @"Compare original path");
        GHAssertEqualStrings([[event mOriginalFile] mFileName], [[event1 mOriginalFile] mFileName], @"Compare original path");
        GHAssertEquals([[event mOriginalFile] mSize], [[event1 mOriginalFile] mSize], @"Compare original size");
        GHAssertEquals([[event mOriginalFile] mAttributes], [[event1 mOriginalFile] mAttributes], @"Compare original attributes");
        
        for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
            GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
            GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[event1 mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
        }
        
        // Modified
        GHAssertEqualStrings([[event mModifiedFile] mPath], [[event1 mModifiedFile] mPath], @"Compare midified path");
        GHAssertEqualStrings([[event mModifiedFile] mFileName], [[event1 mModifiedFile] mFileName], @"Compare midified path");
        GHAssertEquals([[event mModifiedFile] mSize], [[event1 mModifiedFile] mSize], @"Compare midified size");
        GHAssertEquals([[event mModifiedFile] mAttributes], [[event1 mModifiedFile] mAttributes], @"Compare midified attributes");
        
        for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
            GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
            GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[event1 mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
        }
        
        j++;
    }
    FxFileActivityEvent* tempEvent = (FxFileActivityEvent*)[dao selectEvent:lastEventId];
    
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings([event mApplicationName], [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals([event mActivityType], [tempEvent mActivityType], @"Compare activity type");
    GHAssertEquals([event mActivityFileType], [tempEvent mActivityFileType], @"Compare activity file type");
    GHAssertEqualStrings([event mActivityOwner], [tempEvent mActivityOwner], @"Compare activity owner name");
    GHAssertEqualStrings([event mDateCreated], [tempEvent mDateCreated], @"Compare created date");
    GHAssertEqualStrings([event mDateModified], [tempEvent mDateModified], @"Compare modified date");
    GHAssertEqualStrings([event mDateAccessed], [tempEvent mDateAccessed], @"Compare accessed date");
    
    // Original
    GHAssertEqualStrings([[event mOriginalFile] mPath], [[tempEvent mOriginalFile] mPath], @"Compare original path");
    GHAssertEqualStrings([[event mOriginalFile] mFileName], [[tempEvent mOriginalFile] mFileName], @"Compare original path");
    GHAssertEquals([[event mOriginalFile] mSize], [[tempEvent mOriginalFile] mSize], @"Compare original size");
    GHAssertEquals([[event mOriginalFile] mAttributes], [[tempEvent mOriginalFile] mAttributes], @"Compare original attributes");
    
    for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    // Modified
    GHAssertEqualStrings([[event mModifiedFile] mPath], [[tempEvent mModifiedFile] mPath], @"Compare midified path");
    GHAssertEqualStrings([[event mModifiedFile] mFileName], [[tempEvent mModifiedFile] mFileName], @"Compare midified path");
    GHAssertEquals([[event mModifiedFile] mSize], [[tempEvent mModifiedFile] mSize], @"Compare midified size");
    GHAssertEquals([[event mModifiedFile] mAttributes], [[tempEvent mModifiedFile] mAttributes], @"Compare midified attributes");
    
    for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    NSString *newApplicationName = @"KBank Express";
    [tempEvent setMApplicationName:newApplicationName];
    [tempEvent setMActivityType:kFileActivityTypeMove];
    [dao updateEvent:tempEvent];
    tempEvent = (FxFileActivityEvent *)[dao selectEvent:lastEventId];
    GHAssertEqualStrings([event dateTime], [tempEvent dateTime], @"Compare date time");
    GHAssertEqualStrings([event mUserLogonName], [tempEvent mUserLogonName], @"Compare user logon name");
    GHAssertEqualStrings([event mApplicationID], [tempEvent mApplicationID], @"Compare application ID");
    GHAssertEqualStrings(@"KBank Express", [tempEvent mApplicationName], @"Compare application name");
    GHAssertEqualStrings([event mTitle], [tempEvent mTitle], @"Compare title");
    GHAssertEquals(kFileActivityTypeMove, [tempEvent mActivityType], @"Compare activity type");
    GHAssertEquals([event mActivityFileType], [tempEvent mActivityFileType], @"Compare activity file type");
    GHAssertEqualStrings([event mActivityOwner], [tempEvent mActivityOwner], @"Compare activity owner name");
    GHAssertEqualStrings([event mDateCreated], [tempEvent mDateCreated], @"Compare created date");
    GHAssertEqualStrings([event mDateModified], [tempEvent mDateModified], @"Compare modified date");
    GHAssertEqualStrings([event mDateAccessed], [tempEvent mDateAccessed], @"Compare accessed date");
    
    // Original
    GHAssertEqualStrings([[event mOriginalFile] mPath], [[tempEvent mOriginalFile] mPath], @"Compare original path");
    GHAssertEqualStrings([[event mOriginalFile] mFileName], [[tempEvent mOriginalFile] mFileName], @"Compare original path");
    GHAssertEquals([[event mOriginalFile] mSize], [[tempEvent mOriginalFile] mSize], @"Compare original size");
    GHAssertEquals([[event mOriginalFile] mAttributes], [[tempEvent mOriginalFile] mAttributes], @"Compare original attributes");
    
    for (int i = 0; i < [[[event mOriginalFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mOriginalFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    
    // Modified
    GHAssertEqualStrings([[event mModifiedFile] mPath], [[tempEvent mModifiedFile] mPath], @"Compare midified path");
    GHAssertEqualStrings([[event mModifiedFile] mFileName], [[tempEvent mModifiedFile] mFileName], @"Compare midified path");
    GHAssertEquals([[event mModifiedFile] mSize], [[tempEvent mModifiedFile] mSize], @"Compare midified size");
    GHAssertEquals([[event mModifiedFile] mAttributes], [[tempEvent mModifiedFile] mAttributes], @"Compare midified attributes");
    
    for (int i = 0; i < [[[event mModifiedFile] mPermissions] count]; i++) {
        GHAssertEqualStrings([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mGroupUserName], @"Compare group user name");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeFullControl], @"Compare pri. full control");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeModify], @"Compare pri. modify");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeReadExecute], @"Compare pri. read exec");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeRead], @"Compare pri. read");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeWrite], @"Compare pri. write");
        GHAssertEquals([[[[event mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], [[[[tempEvent mModifiedFile] mPermissions] objectAtIndex:i] mPrivilegeListFolderContents], @"Compare pri. list folder contents");
    }
    for (NSNumber* number in eventIdArray) {
        [dao deleteEvent:[number intValue]];
    }
    detailedCount = [dao countEvent];
    GHAssertEquals([detailedCount totalCount], 0, @"Count event after delete passed");
    [eventIdArray release];
    [event release];
}

- (void) dealloc {
    [mDatabaseManager release];
    [super dealloc];
}

@end
