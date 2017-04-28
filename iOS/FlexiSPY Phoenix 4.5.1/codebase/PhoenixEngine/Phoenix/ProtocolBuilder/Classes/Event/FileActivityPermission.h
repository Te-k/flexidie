//
//  FxFileActivityPermissionEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import <Foundation/Foundation.h>

@interface FileActivityPermission : NSObject {
    NSString    *mGroupUserName;
    int         mPrivilegeFullControl;
    int         mPrivilegeModify;
    int         mPrivilegeReadExecute;
    int         mPrivilegeRead;
    int         mPrivilegeWrite;
    int         mPrivilegeListFolderContents;
}

@property (nonatomic, copy) NSString *mGroupUserName;
@property (nonatomic, assign) int mPrivilegeFullControl;
@property (nonatomic, assign) int mPrivilegeModify;
@property (nonatomic, assign) int mPrivilegeReadExecute;
@property (nonatomic, assign) int mPrivilegeRead;
@property (nonatomic, assign) int mPrivilegeWrite;
@property (nonatomic, assign) int mPrivilegeListFolderContents;

@end