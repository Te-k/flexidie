

#import "GetGsmInfo.h"

int main() {
	
   GetGsmInfo *gsm=[[GetGsmInfo alloc]init];
   [gsm getCellInfo];
    return 0;
	
}


	
/*	sc = _CTServerConnectionCreate(kCFAllocatorDefault, callback, NULL);
	if(sc){
		NSLog(@"Not Created");
	}
	NSString *imei;
    _CTServerConnectionCopyMobileIdentity(&result, sc, &imei);
	NSLog (@"IMEI is %@", imei);
	
	//GetGsmInfo *info=[[GetGsmInfo alloc]init];
//	[info getCellInfo];
	return 0;
}*/
