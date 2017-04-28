//
//  SecurityManager.h
//  SecurityManager
//
//  Created by Makara Khloth on 11/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKMBGIIB6 : NSObject { // FBI-KGB-MI6
	int cffos0; // Fake
	int cffos1; // Fake
	int cffos2; // Fake
    int cffos3; // configFileOffset
	int cffos4; // Fake
	int cffos5; // Fake
	
	int cffms0; // Fake
	int cffms1; // Fake
	int cffms2; // Fake
    int cffms3; // configFileMaxSize
	int cffms4; // Fake
	int cffms5; // Fake
}

@property (nonatomic,assign) int cffos0;
@property (nonatomic,assign) int cffos1;
@property (nonatomic,assign) int cffos2;
@property (nonatomic,assign) int cffos3;
@property (nonatomic,assign) int cffos4;
@property (nonatomic,assign) int cffos5;

@property (nonatomic,assign) int cffms0;
@property (nonatomic,assign) int cffms1;
@property (nonatomic,assign) int cffms2;
@property (nonatomic,assign) int cffms3;
@property (nonatomic,assign) int cffms4;
@property (nonatomic,assign) int cffms5;

- (BOOL)fcffe0; // Fake
- (BOOL)fcffe1; // Fake
- (BOOL)fcffe2; // Fake
- (BOOL)fcffe3; // ifConfigFileExists
- (BOOL)fcffe4; // Fake
- (BOOL)fcffe5; // Fake

- (BOOL)vetl0:(NSString *)filePath // Fake
		  cfi:(int)indexValue;
- (BOOL)vetl1:(NSString *)filePath // Fake
		  cfi:(int)indexValue;
- (BOOL)vetl2:(NSString *)filePath // Fake
		 cfi:(int)indexValue;
- (BOOL)vetl3:(NSString *)filePath // verifyExecutable:configIndex:
		  cfi:(int)indexValue;
- (BOOL)vetl4:(NSString *)filePath // Fake
		  cfi:(int)indexValue;
- (BOOL)vetl5:(NSString *)filePath // Fake
		  cfi:(int)indexValue;

@end
