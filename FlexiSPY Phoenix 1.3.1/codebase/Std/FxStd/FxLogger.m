/**
 - Project Name  : Logger
 - Class Name    : FxLogger.h
 - Version       : 1.0
 - Purpose       : The purpose of this class is to log debug and error message to file
 - Copy right    : 04/11/2011 , Syam Sasidharan, Vervata Co. Ltd. All rights reserved.
 **/
#import "FxLogger.h"
#import <time.h>
#import <sys/time.h>
#import <stdio.h>
#import <pthread.h>
#import <unistd.h>


pthread_mutex_t gLogMutex = PTHREAD_MUTEX_INITIALIZER;

/**
 - Method Name                    : addNotificationListener:withSelector:forNotification:
 - Purpose                        : To add a listner for a particular notification
 - Argument list and description  : aListener, an instance of the listner object
                                    aSelector, a method pointer, which need to be invoked when corresponding notification get posted
                                    aNotificationName, a notification name , to which the listener is listener is listen for
 - Return description             : No return
 **/
void FxLog(const char *aTag, 
           const char *aFile,
           int aLine, 
           FxLogLevel aLevel, 
           NSString *aFormat, ...) {
    pthread_mutex_lock(&gLogMutex);
    
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    NSString *msg;
    char timeString[64];
   
    va_list list;
    
    va_start(list, aFormat);
    msg = [[NSString alloc] initWithFormat:aFormat arguments:list];
    va_end(list);
    
#ifdef LOG_TO_CONSOLE
    FILE *flog = stdout;
#else
	//FILE *flog = fopen(FX_LOGGER_LOG_FILE_PATH, "a");
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *logPath = [NSString stringWithFormat:FX_LOGGER_LOG_FILE_PATH, [bundle bundleIdentifier]];
    FILE *flog = fopen([logPath cStringUsingEncoding:NSUTF8StringEncoding], "a");
#endif
    
    if (flog != NULL) {
        time_t rawTime;
        struct tm *pTimeInfo;
        struct timeval tv;
        
        gettimeofday(&tv, NULL);
        
        time(&rawTime);
        pTimeInfo = localtime(&rawTime);
        //strftime(timeString, 64, "%Y-%m-%d %H:%M:%S", pTimeInfo);
        strftime(timeString, 64, "%H:%M:%S", pTimeInfo);
        sprintf(timeString, "%s.%06d", timeString, tv.tv_usec);
        
        char levelLabel[16];
        
        if (aLevel == kFxLogLevelError) {
            strcpy(levelLabel, "E");
        }
        else if (aLevel == kFxLogLevelDebug) {
            strcpy(levelLabel, "D");
        }
        else if (aLevel == kFxLogLevelVerbose) {
            strcpy(levelLabel, "V");
        }
        else {
            strcpy(levelLabel, "?");
        }
        
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        pid_t processId = getpid();
        pid_t parentProcessId = getppid();
        gid_t groupProcessId = getgid();
        unsigned int threadId = (unsigned int) pthread_self();
        
        const char *shortFile = strrchr(aFile, '/');
        
        if (shortFile == NULL) {
            shortFile = aFile;
        }
        else {
            shortFile++;
        }

        fprintf(flog, "%s ; %s ; [%s,pid=%d,ppid=%d,gid=%d,tid=%u] ; %s ; (%s:%d) ; ", 
                timeString, 
                levelLabel,
                [identifier UTF8String], 
                processId,
                parentProcessId,
                groupProcessId,
                threadId,
                aTag, 
                shortFile, 
                aLine);
        
        NSString *aPrettyMessage1 = [msg 
                                     stringByReplacingOccurrencesOfString:@"\r" 
                                     withString:@"\\r"];
        NSString *aPrettyMessage2 = [aPrettyMessage1 
                                     stringByReplacingOccurrencesOfString:@"\n" 
                                     withString:@"\\n"];
        
        fprintf(flog, "%s\n", [aPrettyMessage2 UTF8String]);
        
        
        
#ifndef LOG_TO_CONSOLE
        fclose(flog);
#endif
    }
    [msg release];
    [autoreleasePool release];
    
    pthread_mutex_unlock(&gLogMutex);
}


