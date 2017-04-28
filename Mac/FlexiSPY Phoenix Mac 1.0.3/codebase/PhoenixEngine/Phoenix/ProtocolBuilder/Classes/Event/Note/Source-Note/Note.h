//
//  Note.h
//  Note
//
//  Created by Ophat on 1/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	kAppIdUnknow,	
	kAppIdNative,
	kAppIdOneNote,
	kAppIdEverNote	
} AppId;


@interface Note : NSObject {
	AppId	   mAppId;
	NSString * mNoteId;
	NSString * mCreationDateTime;
	NSString * mLastModifiedDateTime;
	NSString * mTitle;
	NSString * mContent;
}
@property(nonatomic,assign) AppId	mAppId;
@property(nonatomic,copy) NSString * mNoteId;
@property(nonatomic,copy) NSString * mCreationDateTime;
@property(nonatomic,copy) NSString * mLastModifiedDateTime;
@property(nonatomic,copy) NSString * mTitle;
@property(nonatomic,copy) NSString * mContent;

@end
