//
//  FxFileActivityInfoEvent.m
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import "FileActivityInfo.h"

@implementation FileActivityInfo
@synthesize  mPath, mFileName, mSize, mAttributes, mPermissions;

-(void)dealloc{
    [mPath release];
    [mFileName release];
    [mPermissions release];
    [super dealloc];
}
@end
