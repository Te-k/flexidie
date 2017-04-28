//
//  ConfigDecryptor.m
//  ConfigurationManager
//
//  Created by Dominique  Mayrand on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigDecryptor.h"
#import "AESCryptor.h"
#import "DebugStatus.h"
#import "AutomateAESKeyPCF.h"

#define PARSE_FEATURES 1
#define PARSE_COMMANDS 2

@interface ConfigDecryptor(private)
BOOL inCfg;
NSString* mConfigurationID;
NSInteger mParseMode;
-(NSString*) getFileWithPath;
-(void) decryptAndSetForConfigurations;
-(void) setFeatures:(NSXMLParser*) aXmlDoc;
//-(void) setConfigurations:(NSXMLParser*) aXmlDoc;
@end



@implementation ConfigDecryptor

static char key[] = { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 };

#define kProductDefinition @"PCF.xml"

- (id) initWithConfigurationID:(NSString*) aForConfiguration
{
	self = [super init];
	if(self)
	{
		mFeatures = nil;
		mRemoteCommands = nil;
		mConfigurationID = [[NSString alloc] initWithFormat:@"%@", aForConfiguration];
		[self decryptAndSetForConfigurations];
	}
	return self;
	
}

- (NSArray *) getFeatures
{
	
	return mFeatures;
}

- (NSArray *) getRemoteCommands
{
	return mRemoteCommands;
}

- (void) dealloc
{
	if(mConfigurationID) [mConfigurationID release];
	[mRemoteCommands release];
	[mFeatures release];
	[super dealloc];
}

// Private
-(NSString*) getFileWithPath{
	NSString* filePath = [[NSBundle mainBundle] resourcePath];
	NSString* appFile = [filePath stringByAppendingFormat:@"/%@",kProductDefinition];
	DLog (@"Configuration file path = %@", appFile);
	return appFile;
}

-(void) decryptAndSetForConfigurations{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* path = [self getFileWithPath];
	if([fileManager fileExistsAtPath:path]){
		NSData* data = [NSData dataWithContentsOfFile:path]; 
		if(data){
			AESCryptor* crypt = [[AESCryptor alloc] init];
			if(crypt){
				// Fake
				NSString* keystring = [[NSString alloc]initWithBytes:key length:sizeof(key) encoding:NSASCIIStringEncoding];
				
				// PCF tools cannot encrypt with keys which its value is negative
				char pcfKey[16];
				pcfKey[0] = abs(pcf0());
				pcfKey[1] = abs(pcf1());
				pcfKey[2] = abs(pcf2());
				pcfKey[3] = abs(pcf3());
				pcfKey[4] = abs(pcf4());
				pcfKey[5] = abs(pcf5());
				pcfKey[6] = abs(pcf6());
				pcfKey[7] = abs(pcf7());
				pcfKey[8] = abs(pcf8());
				pcfKey[9] = abs(pcf9());
				pcfKey[10] = abs(pcf10());
				pcfKey[11] = abs(pcf11());
				pcfKey[12] = abs(pcf12());
				pcfKey[13] = abs(pcf13());
				pcfKey[14] = abs(pcf14());
				pcfKey[15] = abs(pcf15());
				
				NSString *aesKey = [[[NSString alloc] initWithBytes:pcfKey
															 length:16
														   encoding:NSASCIIStringEncoding] autorelease];
				
				NSData* decryptedData = [crypt decrypt:data withKey:aesKey];
				
				if(decryptedData)
				{
					NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:decryptedData];
					if(xmlParser)
					{
						[xmlParser setDelegate:self];
						[self setFeatures:xmlParser];
						//[self setConfigurations:xmlParser];
						[xmlParser setDelegate:nil];
						[xmlParser release];
						
					}
				}else{
					DLog("No data do decrypt");		
				}
				[keystring release];
				[crypt release];
			}
		}else{
			DLog("Could not read the file");
		}
	}else{
		DLog("File does not exist %@", path);
	}
}

#define XML_CONFIGURATION @"configuration"
#define XML_FEATURES @"features"
#define XML_FEATURE @"feature"
#define XML_REMOTE_COMMANDS @"remote_commands"
#define XML_COMMAND @"cmd"
#define XML_SETTINGS @"settings"
#define XML_SETTING @"setting"
#define XML_ATT_ID @"id"

-(void) setFeatures:(NSXMLParser*) aXmlParser{

	mParseMode = PARSE_FEATURES;
	inCfg = NO;
	[aXmlParser parse]; 

}

/*
-(void) setConfigurations:(NSXMLParser*) aXmlParser{
	mParseMode = PARSE_COMMANDS;
	inCfg = NO;
	[aXmlParser parse];
}*/

// NSXMLParser delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//DLog (@"inCfg = %d, elementName = %@, attributeDict = %@", inCfg, elementName, attributeDict);
	if(inCfg){
		if([elementName isEqualToString:XML_REMOTE_COMMANDS]){
			mParseMode = PARSE_COMMANDS;
		}else if([elementName isEqualToString:XML_FEATURES]){
			mParseMode = PARSE_FEATURES;	
		}else{
			if(mParseMode == PARSE_COMMANDS){
				if([elementName isEqualToString:XML_COMMAND]){
					// Add commands array
					if(mRemoteCommands == nil){
						mRemoteCommands = [[NSMutableArray array] retain]; 
					}
					NSString* cmdID = [attributeDict objectForKey:XML_ATT_ID];
					//DLog (@"Found command number = %@", cmdID);
					if(cmdID){
						/*NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
						[f setNumberStyle:NSNumberFormatterDecimalStyle];
						NSNumber * myNumber = [f numberFromString:cmdID ];
						*/
						[mRemoteCommands addObject:cmdID];
						//[f release];
					}
				}
			}else if(mParseMode == PARSE_FEATURES){
				if([elementName isEqualToString:XML_FEATURE]){
					// Add features array
					if(mFeatures == nil){
						mFeatures = [[NSMutableArray array] retain];
					}
					NSString* featureID = [attributeDict objectForKey:XML_ATT_ID];
					//DLog (@"Found feature number = %@", featureID);
					if(featureID){
						NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
						[f setNumberStyle:NSNumberFormatterDecimalStyle];
						NSNumber * myNumber = [f numberFromString:featureID ];
						
						[mFeatures addObject:myNumber];
						[f release];
					}
				}
			}
		}
	}else if([elementName isEqualToString:XML_CONFIGURATION]){
		// Look for the matching configuration
		//DLog(@"Found config");
		NSString* cfgID = [attributeDict objectForKey:XML_ATT_ID];
		if(cfgID){
			if([cfgID isEqualToString:mConfigurationID]){
				//DLog(@"Found configuration");
				inCfg = YES;
		    }
		}
	}
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

	if([elementName isEqualToString:XML_CONFIGURATION])
	{
		if( inCfg == YES){
			DLog(@"Operation canceled");
			[parser abortParsing];
		}
	}else if( inCfg == YES){
		if([elementName isEqualToString:XML_REMOTE_COMMANDS]){
			mParseMode = 0;
		}else if([elementName isEqualToString:XML_FEATURES]){
			mParseMode = 0;
		}
		/*	if(mParseMode == PARSE_COMMANDS){
				
			}else if(mParseMode == PARSE_FEATURES){
				
			}*/
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	
}

@end
