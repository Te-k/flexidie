/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdErrorMessage
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  23/11/2011, Makara KH, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>


@interface RemoteCmdErrorMessage : NSObject {

}
+ (NSString *) errorMessage: (NSUInteger) aErrorCode; 

@end
