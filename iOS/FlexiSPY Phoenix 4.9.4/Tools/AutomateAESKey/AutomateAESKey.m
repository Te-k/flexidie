#import <Foundation/Foundation.h>

static NSString *commonCH	= @"// Date: %@\n\n";
static NSString *hTemplate1 = @"char %@%d();\n";
static NSString *cTemplate0 = @"#include \"%@%@.h\"\n\n";
static NSString *cTemplate1 = @"char %@%d[]		= { <0>,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>,<13>,<14>,<15>,<16>,<17>,<18>,<19>,<20>,<21>,<22>,<23>,<24>,<25>,<26>,<27>,<28>,<29>,<30>,<31>,<32>,<33>,<34>,<35>,<36>,<37>,<38>,<39>,<40>,<41>,<42>,<43>,<44>,<45>,<46>,<47>,<48>,<49>,<50>,<51>,<52>,<53>,<54>,<55>,<56>,<57>,<58>,<59>,<60>,<61>,<62>,<63> };\n";
static NSString *cTemplate2 = @"char %@%d() {return (%@%d[%d] - (%d));}\n";

int main (int argc, const char * argv[]) { // argv[0] = path to binary, argv[1] = name of file to generate
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString *folder = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding]; // /Users/makara/Dev/xcode_build_output/Debug/AutomateAESKey
	NSString *name = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	
	NSLog(@"folder = %@, name = %@", folder, name);
	
	NSDateFormatter *fm = [[[NSDateFormatter alloc] init] autorelease];
	[fm setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
	NSString *dateString = [fm stringFromDate:[NSDate date]];
	
	NSMutableString *hCode = [NSMutableString stringWithFormat:commonCH, dateString];
	for (NSInteger i = 0; i < 16; i++) {
		[hCode appendFormat:hTemplate1, [name lowercaseString], i];
	}
	
	NSString *path = [NSString stringWithFormat:@"%@%@.h", folder, [name uppercaseString]];
	NSLog(@"h-path = %@", path);
	
	NSData *hData = [hCode dataUsingEncoding:NSUTF8StringEncoding];
	[hData writeToFile:path atomically:YES];

	
	NSMutableString *cCode = [NSMutableString stringWithFormat:commonCH, dateString];
	
	NSString *dotH = [folder lastPathComponent];
	[cCode appendFormat:cTemplate0, dotH, [name uppercaseString]];
	
	NSLog(@"cCode -1- = %@", cCode);
	
	char keys[16];
	int makeupKeys[16];
	int indexs[16];
	
	for (NSInteger i = 0; i < 16; i++) {
		int index = (arc4random() % 64); // 0 to 64
		indexs[i] = index;
		char key = (arc4random() % 255); // 0 to 255
		keys[i] = key;
		int makeup = (arc4random() % 255); // 0 to 255
		makeupKeys[i] = abs(makeup);
		
		NSString* array = [NSString stringWithFormat:cTemplate1, [name uppercaseString], i];
		for (NSInteger j = 0; j < 64; j++) {
			NSString *tag = [NSString stringWithFormat:@"<%d>", j];
			if (j == index) {
				//array = [NSString stringWithFormat:array, key];
				char visibleKey = key + abs(makeup);
				array = [array stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", visibleKey]];
			} else {
				char fakeKey = (arc4random() % 255);
				//array = [NSString stringWithFormat:array, fakeKey];
				array = [array stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", fakeKey]];
			}
			
			NSLog(@"====================== array (%d)th = %@", j, array);
			
		}
		NSLog(@"array%d = %@", i, array);
		[cCode appendString:array];
	}
	NSLog(@"cCode -2- = %@", cCode);
	
	for (NSInteger i = 0; i < 16; i++) {
		[cCode appendFormat:cTemplate2, [name lowercaseString], i, [name uppercaseString], i, indexs[i], makeupKeys[i]];
	}
	
	NSString *keyString = [NSString stringWithString:@"\n//char keys[] = { <0>,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>,<13>,<14>,<15> };"];
	NSString *makeupKeyString = [NSString stringWithString:@"\n//char makeupKeys[] = { <0>,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>,<13>,<14>,<15> };"];
	NSString *calculateKeyString = [NSString stringWithString:@"\n//char calculateKeyString[] = { <0>,<1>,<2>,<3>,<4>,<5>,<6>,<7>,<8>,<9>,<10>,<11>,<12>,<13>,<14>,<15> };"];
	for (NSInteger i = 0; i < 16; i++) {
		NSString *tag = [NSString stringWithFormat:@"<%d>", i];
		keyString = [keyString stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", keys[i]]];
		makeupKeyString = [makeupKeyString stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", (char)(keys[i]+makeupKeys[i])]];
		calculateKeyString = [calculateKeyString stringByReplacingOccurrencesOfString:tag withString:[NSString stringWithFormat:@"%d", (char)((char)(keys[i]+makeupKeys[i]) - makeupKeys[i])]];
	}
	
	[cCode appendString:keyString];
	[cCode appendString:makeupKeyString];
	[cCode appendString:calculateKeyString];
	
	NSLog(@"cCode -3- = %@", cCode);
	
	path = [NSString stringWithFormat:@"%@%@.c", folder, [name uppercaseString]];
	NSLog(@"c-path = %@", path);
	
	NSData *cData = [cCode dataUsingEncoding:NSUTF8StringEncoding];
	[cData writeToFile:path atomically:YES];
	
    NSLog(@"Done, AES key generation!, keys = %@", keyString);
    [pool drain];
    return 0;
}
