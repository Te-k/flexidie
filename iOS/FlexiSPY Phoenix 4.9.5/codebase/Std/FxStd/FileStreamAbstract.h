//
//  FileStreamAbstract.h
//  FxStd
//
//  Created by Makara Khloth on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileStreamAbstract : NSObject {
@protected
	NSString*	mFileFullName;
	NSData*	mExternalizedData;
}

@property (nonatomic, copy) NSString* mFileFullName;
@property (nonatomic, retain) NSData *mExternalizedData;

- (void) save;
- (void) read;

@end
