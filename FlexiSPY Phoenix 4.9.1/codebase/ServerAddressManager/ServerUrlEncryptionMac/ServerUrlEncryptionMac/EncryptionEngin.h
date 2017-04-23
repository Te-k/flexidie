/** 
 - Project name: ServerUrlEncryption
 - Class name: EncryptionEngin
 - Version: 1.0
 - Purpose: Encrypt URLs and write them to a file
 - Copy right: 4/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@interface EncryptionEngin : NSObject {
@private
	NSMutableArray *mURLs;
}


@property (nonatomic, retain) NSMutableArray *mURLs;

- (void) addUrl: (NSString *) aURL;
- (void) encryptURLsAndWriteToFile;
- (void) encryptURLsAndWriteToFileWithTwoDiArray;
- (void) decryptURLs;

@end
