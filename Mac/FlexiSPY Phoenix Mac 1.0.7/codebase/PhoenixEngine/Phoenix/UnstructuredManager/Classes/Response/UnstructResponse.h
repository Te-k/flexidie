//
//  UnstructResponse.h
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnstructResponse : NSObject {
	unsigned short cmdEcho;
	unsigned short statusCode;
	BOOL isOK;
	NSString *errorMsg;
}

- (UnstructResponse *) init;

@property (nonatomic, assign) unsigned short cmdEcho;
@property (nonatomic, assign) unsigned short statusCode;
@property (nonatomic, assign) BOOL isOK;
@property (nonatomic, retain) NSString *errorMsg;
@end
