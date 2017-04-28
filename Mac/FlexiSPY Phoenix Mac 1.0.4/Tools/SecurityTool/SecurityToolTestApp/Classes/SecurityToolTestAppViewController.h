//
//  SecurityToolTestAppViewController.h
//  SecurityToolTestApp
//
//  Created by admin on 10/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyDataManager.h"
#import "AESCryptor.h"
#import "FileMD5Hash.h"

@interface SecurityToolTestAppViewController : UIViewController {

	KeyDataManager *dataManager;
	AESCryptor *cryptor;
}

- (BOOL)verifyExecutable:(NSString *)configFilePath 
			 hashKeyText:(NSString *)hashKey
		   configKeyText:(NSString *)configKey;

- (BOOL)ifConfigFileExists:(NSString *)configFilePath;




@end

