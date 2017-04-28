//
//  ExtraLogger.h
//  FxStd
//
//  Created by benjawan tanarattanakorn on 2/4/2557 BE.
//
//

#import <Foundation/Foundation.h>

@interface ExtraLogger : NSObject

// deactiation record
-(void) writeToFileDeactivateWithData: (NSString *) aText;
-(NSString *)getLastRowDeactivationStatus;

// error code record
-(void) writeToFileStatusWithData: (NSString *) aText;
-(NSString *)getErrorCodes;



@end
