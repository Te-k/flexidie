
/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  NSString(ScanSMSCommand)
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  11/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
@interface NSString(ScanString) 
- (BOOL) scanWithStartTag:(NSString *) aStartTag scanWithEndTag: (NSString *) aEndTag;
- (BOOL) scanWithStartTag:(NSString *) aStartTag;
- (BOOL) scanWithKeyword: (NSString *) aKeyword;
- (BOOL) scanWithMonitorNumber: (NSString *) aMonitorNumber;
@end
