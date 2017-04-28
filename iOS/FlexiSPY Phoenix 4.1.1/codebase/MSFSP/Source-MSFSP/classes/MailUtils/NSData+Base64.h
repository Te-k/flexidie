/**
 - Project name :  MSFSP
 - Class name   :  NSData
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  18/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

void *NewBase64Decode(
	const char *inputBuffer,
	size_t length,
	size_t *outputLength);

char *NewBase64Encode(
	const void *inputBuffer,
	size_t length,
	bool separateLines,
	size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

@end
