//
//  SecurityToolTestAppViewController.m
//  SecurityToolTestApp
//
//  Created by admin on 10/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SecurityToolTestAppViewController.h"

@implementation SecurityToolTestAppViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	BOOL isVerified;
	isVerified=NO;
	
	if([self ifConfigFileExists:@"/var/Test/config.dat"/*[[NSBundle mainBundle] pathForResource:@"config" ofType:@"dat"]*/]) {
		
		isVerified = [self verifyExecutable:/*[[NSBundle mainBundle] pathForResource:@"config" ofType:@"dat"]*/@"/var/Test/config.dat" 
								hashKeyText:@"0856a1f1c4f3d7e42e5b83588a80fe3a" 
							  configKeyText:@"06728e8019bb3449471b2e3e0d984605"];
	}
	
	if(isVerified) {
		
		UIAlertView *alert;
		alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
										 message:@"Successfully   Verified Executable Checksum!!!"
										delegate:nil 
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
	}
	
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Config file exists or not
- (BOOL)ifConfigFileExists:(NSString *)configFilePath {
	
	//Check whether the config file exists at path
	if(![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]){
		
		UIAlertView *alert;
		alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
										 message:@"File does not exists!!!"
										delegate:self 
							   cancelButtonTitle:@"OK" 
							   otherButtonTitles:nil];
		[alert show];
		[alert release];
		alert=nil;
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark Verifying the executable checksum
- (BOOL)verifyExecutable:(NSString *)configFilePath 
			 hashKeyText:(NSString *)hashKey
		   configKeyText:(NSString *)configKey{
	
	char binaryCheckSum[33];
	char binaryCheckSumFromConfigFile[49];
	char binaryDecryptedCheckSumFromConfigFile[33];
	
	char configCheckSum[33];
	char configCheckSumFromConfigFile[49];
	char decryptedConfigCheckSumFromConfigFile[33];
	
	char configData[512];
	char *configFile;
	
	int indexFile[96];
	
	BOOL isSuccess;
	
	//Fecthing the index file
	dataManager=[[KeyDataManager alloc] init];
	
	//Fetching and decrypting config file data
	cryptor=[[AESCryptor alloc] init];
	
	for (int i=0; i<2; i++) {
	
		int configFileCounter=0,configFileMaxCount=512;

		NSMutableArray *indexofChecksum=[dataManager getKeyDataForFileAtIndex:1];	

		for (int i=0; i<96; i++) {
		
			NSNumber *indexValue=[indexofChecksum objectAtIndex:i];
			indexFile[i]=(int)[indexValue intValue];
		}
	
		//Decryption the config file
		NSData *encryptedConfigData=[NSData dataWithContentsOfFile:configFilePath];
	
		NSData *decryptedConfig=[cryptor decrypt:encryptedConfigData 
										 withKey:configKey];
	
		//Check decryption status
		if(decryptedConfig==nil){
		
			UIAlertView *alert;
			NSString *keyused=[NSString stringWithFormat:@"Config  File Check sum DECR Failed!!!with key%@",configKey];
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:keyused
											delegate:self 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
			return NO;
		}
	
		int configFileSize=[decryptedConfig length];
		configFile=(char *)malloc(configFileSize);
		//Getting bytes from decrypted data
		[decryptedConfig getBytes:configFile 
						   length:configFileSize];
	
		for (int i=configFileCounter,j=0; i<configFileMaxCount; i++,j++) {
		
			configData[j]=configFile[i];
		}
		
		configFileCounter=configFileMaxCount;
		configFileMaxCount+=512;
	
		//Creating the hash for config data
		DataMD5HashCreate(configData, 
						  FileHashDefaultChunkSizeForReadingData,
						  configCheckSum , 
						  512);
	
		//Check config is created or not
		if(configCheckSum==nil){
		
			UIAlertView *alert;
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:@"New Config File check sum Failed!!!"
											delegate:self 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
			return NO;
		}
	
		//Getting the check sum from confile itself
		for (int i=48,j=0; i<96; j++,i++) {
		
			int n=indexFile[i];
			configCheckSumFromConfigFile[j]=configFile[n];
		}
	
		//If any of the check sum data is nil no need to go further
		if(configCheckSumFromConfigFile==nil || configFile==nil){
		
			UIAlertView *alert;
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:@"Config File Check sum fetch Failed!!!"
											delegate:self 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
			return NO;
		}
	
		NSData *decryptedConfigCheckSum=[cryptor decrypt:[NSData dataWithBytes:configCheckSumFromConfigFile length:48] 
												 withKey:configKey];
	
		//Decrypting the check sum data from config file
		if(decryptedConfigCheckSum==nil){
		
			UIAlertView *alert;
			NSString *keyused=[NSString stringWithFormat:@"Config File Check sum DECR Failed!!!with key%@",configKey];
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:keyused
											delegate:self 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
			return NO;
		}
	
		[decryptedConfigCheckSum getBytes:decryptedConfigCheckSumFromConfigFile 
							   length:32];
		//Verifying config file check sum
		for (int i=0; i<32; i++) {
		
			int decryptedConfigCheckSumValue=decryptedConfigCheckSumFromConfigFile[i];
			int configCheckSumValue=configCheckSum[i];
		
			if(decryptedConfigCheckSumValue!=configCheckSumValue) {
			
				UIAlertView *alert;
				alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
												 message:@"Config file has been modified"
												delegate:self 
									   cancelButtonTitle:@"OK" 
									   otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert=nil;
				return NO;
			}
			else {
		
				NSString *data=[NSString stringWithFormat:@"ConfigCheckSumFile=%d   newCheckSum=%d",decryptedConfigCheckSumFromConfigFile[i],configCheckSum[i]];
				UIAlertView *alert;
				alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
												 message:data
												delegate:nil 
									   cancelButtonTitle:@"OK" 
									   otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert=nil;
			}
		}
	
		//getting the binary check sum from file
		for (int i=0; i<48; i++) {
		
			int n=indexFile[i];
			binaryCheckSumFromConfigFile[i]=configFile[n];
		
			NSString *data=[NSString stringWithFormat:@"binaryCheckSum=%d Index=%d",binaryCheckSumFromConfigFile[i],n];
			UIAlertView *alert;
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:data
											delegate:nil 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
		
		}
		binaryCheckSumFromConfigFile[48]='\0';
				
		
		//Decrypting the binary checksum from config
	
		NSData *encryptedBinaryCheckSum=[NSData dataWithBytes:binaryCheckSumFromConfigFile length:48];
		NSData *decryptedBinaryCheckSum=[cryptor decrypt:encryptedBinaryCheckSum 
												 withKey:hashKey];
	
		if(decryptedBinaryCheckSum==nil){
		
			UIAlertView *alert;
			NSString *keyused=[NSString stringWithFormat:@"DECR FAILED with key %@",hashKey];
			alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
											 message:keyused
											delegate:nil 
								   cancelButtonTitle:@"OK" 
								   otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
		}
	
		[decryptedBinaryCheckSum getBytes:binaryDecryptedCheckSumFromConfigFile 
								   length:[decryptedBinaryCheckSum length]];
	
	
		//Calculating the checksum for the current executable
		NSString *currentExecutablePath=[[NSBundle mainBundle] executablePath];
		FileMD5HashCreateWithPath((CFStringRef)currentExecutablePath, FileHashDefaultChunkSizeForReadingData, binaryCheckSum);
	
		isSuccess=NO;
	
		//Verifying the calculated checksum with the checksum from config file
		for (int i=0; i<32; i++) {
			
			isSuccess=YES;
		
			char binaryCheckSumValueFromConfig=binaryDecryptedCheckSumFromConfigFile[i];
			char binaryCheckSumValueOfExecutable=binaryCheckSum[i];
		
			if(binaryCheckSumValueFromConfig!=binaryCheckSumValueOfExecutable) {
			
				UIAlertView *alert;
				NSString *strValue=[NSString stringWithFormat:@"File has been modified!!! actual - %d current - %d",binaryCheckSumValueOfExecutable,binaryCheckSumValueFromConfig];
				alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
												 message:strValue
												delegate:self 
									   cancelButtonTitle:@"OK" 
									   otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert=nil;
				isSuccess=NO;
				//break;
			}
			else {
			
				NSString *strValue=[NSString stringWithFormat:@"actual - %d current - %d",binaryCheckSumValueOfExecutable,binaryCheckSumValueFromConfig];
				UIAlertView *alert;
				alert=[[UIAlertView alloc] initWithTitle:@"Custom Message" 
												 message:strValue
												delegate:nil 
									   cancelButtonTitle:@"OK" 
									   otherButtonTitles:nil];
				[alert show];
				[alert release];
				alert=nil;
			}

		}
		
		//configFileCounter=configFileMaxCount;
		//configFileMaxCount+=512;
	}
	
	[dataManager release];
	dataManager=nil;
	[cryptor release];
	cryptor=nil;
	
	return isSuccess;
	
}

#pragma mark -
#pragma mark UIAlertView delegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	//exit(0);
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Memory management 
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
