/** 
 - Project name: ProductInfoUtil
 - Class name: DataConvertion
 - Version: 1.0
 - Purpose: Provide UI to retrieve product information, encrypt product information and write it to a file
 - Copy right: 3/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@interface DataConvertion : NSObject {
@private
	NSString *mProductId;
	NSString *mProtocolLanguage;
	NSString *mProtocolVersion;
	NSString *mVersion;
	NSString *mName;
	NSString *mDescription;
	NSString *mLanguage;
	NSString *mHashtail;
	NSData *mProductData;
	NSData *mEncryptedProductData;
}

@property (nonatomic, copy) NSString *mProductId;
@property (nonatomic, copy) NSString *mProtocolLanguage;
@property (nonatomic, copy) NSString *mProtocolVersion;
@property (nonatomic, retain) NSString *mVersion;
@property (nonatomic, retain) NSString *mName;
@property (nonatomic, retain) NSString *mDescription;
@property (nonatomic, retain) NSString *mLanguage;
@property (nonatomic, retain) NSString *mHashtail;
@property (nonatomic, retain) NSData *mProductData;
@property (nonatomic, retain) NSData *mEncryptedProductData;

- (id) initWithProductInfoVersion: (NSString *) aVersion
							 name: (NSString *) aName
					  description: (NSString *) aDescription
						 language: (NSString *) aLanguage
						 hashtail: (NSString *) aHashtail;

- (void) encryptAndWriteToFile;
- (void) decryptAndRetrieveProductInfo;
	
@end

