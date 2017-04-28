/** 
 - Project name: SystemUtils
 - Class name: NONE (Filename: DeviceConstant)
 - Version: 1.0
 - Purpose: 
 - Copy right: 15/02/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

// https://github.com/erica/uidevice-extension/blob/master/UIDevice-Hardware.m
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk

// iPod ============================
#define kIpodTouch		@"iPod1,1"		// 1G
#define kIpodTouch2nd	@"iPod2,1"		// 2G
#define kIpodTouch3rd	@"iPod3,1"		// 3G
#define kIpodTouch4th	@"iPod4,1"		// 4G
#define kIpodTouch5th	@"iPod5,1"		// 5G

// iPhone ============================
// iphone 1G
#define kIphone			@"iPhone1,1" 
// iphone 3G
#define kIphone3G		@"iPhone1,2" 
// iphone 3GS
#define kIphone3GS		@"iPhone2,1"
// iphone 4
#define kIphone4		@"iPhone3,1"		// iPhone 4/AT&T, N89
#define kIphone4_1		@"iPhone3,2"		// iPhone 4/Other Carrier?, ??
#define kIphone4_2		@"iPhone3,3"		// iPhone 4/Verizon, TBD
// iphone 4s
#define kIphone4S		@"iPhone4,1"		// iPhone 4S/GSM, TBD
#define kIphone4S_2		@"iPhone4,2"		// iPhone 4S/CDMA, TBD
#define kIphone4S_3		@"iPhone4,3"		// iPhone 4S/???
// iphone 5
#define kIphone51		@"iPhone5,1"
#define kIphone52		@"iPhone5,2"
// iphone 5c
#define kIphone53       @"iPhone5,3"
#define kIphone54       @"iPhone5,4"
// iphone 5s
#define kIphone61       @"iPhone6,1"
#define kIphone62       @"iPhone6,2"
// iphone 6
#define kIphone72       @"iPhone7,2"
// iphone 6 plus
#define kIphone71       @"iPhone7,1"

// iPad ============================
// Ipad 1
#define kIpad			@"iPad1,1"			// iPad 1G, WiFi and 3G, K48
// Ipad 2
#define kIpad21			@"iPad2,1"			// iPad 2G, WiFi, K93
#define kIpad22			@"iPad2,2"			// iPad 2G, GSM 3G, K94
#define kIpad23			@"iPad2,3"			// iPad 2G, CDMA 3G, K95
#define kIpad24			@"iPad2,4"
// Ipad 3rd Gen
#define kIpad31			@"iPad3,1"			// iPad 3G, WiFi
#define kIpad32			@"iPad3,2"			// iPad 3G, GSM
#define kIpad33			@"iPad3,3"			// iPad 3G, CDMA
// Ipad 4th Gen
#define kIpad34			@"iPad3,4"			// WiFi
#define kIpad35			@"iPad3,5"
#define kIpad36			@"iPad3,6"			// GSM+CDMA
// Ipad mini
#define kIpad25			@"iPad2,5"
#define kIpad26			@"iPad2,6"
#define kIpad27			@"iPad2,7"
// Ipad Air
#define kIpad41			@"iPad4,1"
#define kIpad42			@"iPad4,2"
#define kIpad43         @"iPad4,3"
// Ipad mini 2
#define kIpad44			@"iPad4,4"
#define kIpad45			@"iPad4,5"
#define kIpad46         @"iPad4,6"
// Ipad Air 2
#define kIpad53         @"iPad5,3"
#define kIpad54         @"iPad5,4"
// Ipad mini 3
#define kIpad47         @"iPad4,7"
#define kIpad48         @"iPad4,8"
#define kIpad49         @"iPad4,9"

#define kiPhoneSimulator		@"i386"
#define kiPadSimulator			@"x86_64"





