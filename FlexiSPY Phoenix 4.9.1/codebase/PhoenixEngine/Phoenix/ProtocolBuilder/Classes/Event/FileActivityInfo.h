//
//  FxFileActivityInfoEvent.h
//  ProtocolBuilder
//
//  Created by ophat on 9/29/15.
//
//

#import <Foundation/Foundation.h>

@interface FileActivityInfo : NSObject{
    NSString *mPath;
    NSString *mFileName;
    int mSize;
    int mAttributes;
    NSArray *mPermissions;
}
@property (nonatomic, copy) NSString *mPath;
@property (nonatomic, copy) NSString *mFileName;
@property (nonatomic, assign) int mSize;
@property (nonatomic, assign) int mAttributes;
@property (nonatomic, retain) NSArray *mPermissions;

@end
