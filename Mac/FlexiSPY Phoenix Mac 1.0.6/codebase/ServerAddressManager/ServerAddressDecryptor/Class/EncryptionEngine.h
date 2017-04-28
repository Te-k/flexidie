/** 
 - Project name: ServerUrlEncryption
 - Class name: EncryptionEngine
 - Version: 1.0
 - Purpose: Encrypt URLs and write them to a file
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@interface EncryptionEngine : NSObject {

}


- (NSString *) decryptURLFromEncryptedData:(NSData *)data;

@end
