#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

static NSString *commonCH	= @"// Date: %@\n\n";
static NSString *hTemplate1 = @"char s21%d();\n";
static NSString *cTemplateP1 = @"// argv[1] = %@\n";
static NSString *cTemplateP2 = @"// argv[2] = %@\n\n";
static NSString *cTemplateP3 = @"// argv[3] = %d\n";
static NSString *cTemplateP4 = @"// argv[4] = %d\n\n";
static NSString *cTemplate0 = @"#include \"S21.h\"\n\n";
static NSString *cTemplate1 = @"char S21%d[]		= { <0>,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>,<13>,<14>,<15>,<16>,<17>,<18>,<19>,<20>,<21>,<22>,<23>,<24>,<25>,<26>,<27>,<28>,<29>,<30>,<31>,<32>,<33>,<34>,<35>,<36>,<37>,<38>,<39>,<40>,<41>,<42>,<43>,<44>,<45>,<46>,<47>,<48>,<49>,<50>,<51>,<52>,<53>,<54>,<55>,<56>,<57>,<58>,<59>,<60>,<61>,<62>,<63> };\n";
static NSString *cTemplate3 = @"char s21%d() {return (S21%d[%d] - (%d));}\n";

NSData * encryptv1 (NSData *objDataToBeEncrypted, NSString *key) {
	// 'key' should be 16 bytes for AES128, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES128+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [objDataToBeEncrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	//kCCOptionPKCS7Padding
	size_t numBytesEncrypted = 0;
	
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [objDataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	NSLog(@"Encrypt v1 AES128EncryptWithKey FAILED ----------------------");
	free(buffer); //free the buffer;
	return nil;
}

NSData * encryptv2(NSData *objDataToBeEncrypted ,NSData *key) {
	
	NSUInteger dataLength = [objDataToBeEncrypted length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	//kCCOptionPKCS7Padding
	size_t numBytesEncrypted = 0;
	
	
	char iv[] = {7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43};
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  [key bytes], kCCKeySizeAES128,
										  iv /* initialization vector (optional) */,
										  [objDataToBeEncrypted bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	NSLog(@"Encrypt v2 AES128EncryptWithKey FAILED ----------------------");
	free(buffer); //free the buffer;
	return nil;	
}

int main (int argc, const char * argv[]) { // argv[0] = path to this binary, argv[1] = absolute path to pcf file, argv[2] = key in this format: "23,31,3,0,3,21,2,4,5,20,1,2,3,3,4,1", argv[3] = start offset, argv[4] = number of eof
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	// 1. Calculate checksum
	// 2. Encrypt checksum with auto generate key
	// 3. Write encrypted checksum to distribute array
	NSNumberFormatter* nf = [[[NSNumberFormatter alloc] init] autorelease];
	
	NSString *startString = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
	NSString *endString = [NSString stringWithCString:argv[4] encoding:NSUTF8StringEncoding];
	NSInteger start = [[nf numberFromString:startString] intValue];
	NSInteger end = [[nf numberFromString:endString] intValue];
	
    // 1.
	NSString *pcfFile = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	NSData *pcfData = [NSData dataWithContentsOfFile:pcfFile];
	pcfData = [pcfData subdataWithRange:NSMakeRange(start, [pcfData length] - (start + end))];
	unsigned char msgDigestPCFByte[16];
	CC_MD5([pcfData bytes], [pcfData length], msgDigestPCFByte);
	NSData* msgDigestPCFData = [NSData dataWithBytes:msgDigestPCFByte length:16];
	NSLog(@"msgDigestPCFData = %@", msgDigestPCFData);
	
	// 2.a Create key
	char pcfKey[16];
	NSString *key = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
	NSArray *eachBytes = [key componentsSeparatedByString:@","];
	for (NSInteger i = 0; i < 16; i++) {
		NSNumberFormatter* numberFormat = [[[NSNumberFormatter alloc] init] autorelease];
		NSString *byteString = [eachBytes objectAtIndex:i];
		NSNumber* byte = [numberFormat numberFromString:byteString];
		pcfKey[i] = [byte intValue];
	}
	
//	NSString *aesKey = [[[NSString alloc] initWithBytes:pcfKey
//												 length:16
//											   encoding:NSUTF8StringEncoding] autorelease];
	
	NSData *aesKey = [NSData dataWithBytes:pcfKey length:16];
	
	// 2.b Encrypt PCF
	//NSData *encyptedPCF = encryptv1(msgDigestPCFData, aesKey);
	
	NSData *encyptedPCF = encryptv2(msgDigestPCFData, aesKey);
	
	// 3.
	NSString *folder = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding]; // /Users/makara/Dev/xcode_build_output/Debug/PCFChecksum
	
	NSLog(@"folder = %@", folder);
	
	NSDateFormatter *fm = [[[NSDateFormatter alloc] init] autorelease];
	[fm setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	NSString *dateString = [fm stringFromDate:[NSDate date]];
	
	NSMutableString *hCode = [NSMutableString stringWithFormat:commonCH, dateString];
	for (NSInteger i = 0; i < [encyptedPCF length]; i++) {
		[hCode appendFormat:hTemplate1, i];
	}
	
	NSString *path = [folder stringByReplacingOccurrencesOfString:@"PCFChecksum" withString:@"S21.h"];
	NSLog(@"h-path = %@", path);
	
	NSData *hData = [hCode dataUsingEncoding:NSUTF8StringEncoding];
	[hData writeToFile:path atomically:YES];
	
	
	NSMutableString *cCode = [NSMutableString stringWithFormat:commonCH, dateString];
	[cCode appendFormat:cTemplateP1, pcfFile];
	[cCode appendFormat:cTemplateP2, key];
	[cCode appendFormat:cTemplateP3, start];
	[cCode appendFormat:cTemplateP4, end];
	[cCode appendFormat:@"// %@\n\n", [msgDigestPCFData description]];
	[cCode appendString:cTemplate0];
	
	NSLog(@"cCode -1- = %@", cCode);
	
	NSInteger length = [encyptedPCF length]; // Must be 32 bytes cause data to encrypt is 16 bytes
	const char *bytes = [encyptedPCF bytes];
	
	int *indexs = malloc(length*sizeof(int));
	int *makeupKeys = malloc(length*sizeof(int));
	
	for (NSInteger i = 0; i < length; i++) {
		int index = (arc4random() % length);
		indexs[i] = index;
		 
		char key = bytes[i];
		
		int makeup = (arc4random() % 255); // 0 to 255
		makeupKeys[i] = abs(makeup);
		
		NSString* array = [NSString stringWithFormat:cTemplate1, i];
		for (NSInteger j = 0; j < 64; j++) {
			NSString *tag = [NSString stringWithFormat:@"<%d>", j];
			if (j == index) {
				char visibleKey = key + abs(makeup);
				array = [array stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", visibleKey]];
			} else {
				char fakeKey = (arc4random() % 255);
				array = [array stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", fakeKey]];
			}
			
			NSLog(@"====================== array (%d)th = %@", j, array);
			
		}
		NSLog(@"array%d = %@", i, array);
		[cCode appendString:array];
	}
	NSLog(@"cCode -2- = %@", cCode);
	
	for (NSInteger i = 0; i < length; i++) {
		[cCode appendFormat:cTemplate3, i, i, indexs[i], makeupKeys[i]];		
	}
	NSLog(@"cCode -3- = %@", cCode);
	
	path = [folder stringByReplacingOccurrencesOfString:@"PCFChecksum" withString:@"S21.c"];
	NSLog(@"c-path = %@", path);
	
	NSData *cData = [cCode dataUsingEncoding:NSUTF8StringEncoding];
	[cData writeToFile:path atomically:YES];
	
	NSLog(@"PCFChecksum, World!");
	
	free(indexs);
	free(makeupKeys);
    
	[pool drain];
    return 0;
}
