//
//  MessaPortIPCSender.h
//  IPC
//
//  Created by Dominique  Mayrand on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessagePortIPCSender : NSObject {
	CFMessagePortRef mMessagePortRef;
	NSString* mPortName;
	
	//
	NSData *mReturnData;
}

@property (nonatomic, retain) NSData *mReturnData;

- (id) initWithPortName: (NSString*) aPortName;
- (BOOL) writeDataToPort: (NSData*) aRawData;

@end
