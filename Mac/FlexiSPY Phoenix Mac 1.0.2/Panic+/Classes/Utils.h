//
//  Utils.h
//  PP
//
//  Created by Dominique  Mayrand on 12/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DbHealthInfo;
@class EventCount;

@interface Utils : NSObject {

}

+ (NSMutableArray*) getDiagnosticsWithDBHealthInfo: (DbHealthInfo *) aDBHealthInfo
									withEventCount: (EventCount *) aEventCount
							 andLastConnectionTime: (NSString *) aLastConnectionTime;

@end



@interface DiagnosticObject : NSObject{
	NSString* mName;
	NSString* mValue;
}

@property (nonatomic, retain) NSString* mName;
@property (nonatomic, retain) NSString* mValue;

-(id) initWithName:(NSString*) aName andValue: (NSString*) aValues;
-(void) dealloc;

@end
