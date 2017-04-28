//
//  FxFileActivityPermissionEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import "FileActivityPermission.h"

@implementation FileActivityPermission
@synthesize mGroupUserName,mPrivilegeFullControl,mPrivilegeModify,mPrivilegeReadExecute,mPrivilegeRead,mPrivilegeWrite,mPrivilegeListFolderContents;

-(void)dealloc{
    [mGroupUserName release];
    [super dealloc];
}
@end
