//
//  ProtocolParserUtil.m
//  ProtocolBuilder
//
//  Created by Khaneid Hantanasiriskul on 9/29/2558 BE.
//
//

#import "ProtocolParserUtil.h"
#include <sys/stat.h>

@implementation ProtocolParserUtil

+ (BOOL)isDeviceJailbroken{
#if TARGET_OS_IPHONE
#if !TARGET_OS_SIMULATOR
    //Apps and System check list
//    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
//        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
//        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
//        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
//        [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
//        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
//        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])  {
//        return YES;
//    }
    
    // SandBox Integrity Check
    int pid = fork();
    if(!pid){
        exit(0);
    }
    if(pid>=0)
    {
        return YES;
    }
    
    FILE *f = NULL ;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r")))  {
        fclose(f);
        return YES;
    }
    fclose(f);
    
    //Symbolic link verification
    struct stat s;
    if(lstat("/Applications", &s) || lstat("/var/stash/Library/Ringtones", &s) || lstat("/var/stash/Library/Wallpaper", &s)
       || lstat("/var/stash/usr/include", &s) || lstat("/var/stash/usr/libexec", &s)  || lstat("/var/stash/usr/share", &s) || lstat("/var/stash/usr/arm-apple-darwin9", &s))
    {
        if(s.st_mode & S_IFLNK){
            return YES;
        }
    }
    
    //Try to write file in private
    NSError *error;
    
    [[NSString stringWithFormat:@"Jailbreak test string"]
     writeToFile:@"/private/test_jb.txt"
     atomically:YES
     encoding:NSUTF8StringEncoding error:&error];
    
    if(nil==error){
        //Wrote?: JB device
        //cleanup what you wrote
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
        return YES;
    }
#endif
    return NO;
#else
    return NO;
#endif
}

+ (UIImage *)normalizedImage: (UIImage *)image {
#if TARGET_OS_IPHONE
    if (image.imageOrientation == UIImageOrientationUp) return image;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
#else
    return nil;
#endif
}

+ (NSString *)fetchStringWithOriginalString:(NSString *)originalString withByteLength:(NSUInteger)length
{
    NSData* originalData=[originalString dataUsingEncoding:NSUTF8StringEncoding];
    const char *originalBytes = originalData.bytes;
    
    //make sure to use a loop to get a not nil string.
    //because your certain length data may be not decode by NSString
    for (NSUInteger i = length; i > 0; i--) {
        NSData *data = [NSData dataWithBytes:originalBytes length:i];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (string) {
            return [string autorelease];
        }
        [string release];
    }
    return @"";
}

@end
