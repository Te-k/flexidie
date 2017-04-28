//
//  FXLog.m
//  CommPlugin
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FXLogger.h"
#import <time.h>
#import <sys/time.h>
#import <stdio.h>
#import <pthread.h>
#import <unistd.h>


//#define LOG_TO_CONSOLE


#define FX_LOGGER_MAX_MESSAGE_SIZE 1024
#define FX_LOGGER_LOG_FILE_PATH "/loger/plugin.log"


pthread_mutex_t gLogMutex = PTHREAD_MUTEX_INITIALIZER;


void FXLog(const char *tag, 
           const char *file,
           int line, 
           FXLogLevel level, 
           NSString *format, ...) {
    pthread_mutex_lock(&gLogMutex);
    
    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    NSString *msg;
    char timeString[64];
   
    va_list list;
    
    va_start(list, format);
    msg = [[NSString alloc] initWithFormat:format arguments:list];
    va_end(list);
    
#ifdef LOG_TO_CONSOLE
    FILE *flog = stdout;
#else
    FILE *flog = fopen(FX_LOGGER_LOG_FILE_PATH, "a");
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
        
        if (level == kFXLogLevelError) {
            strcpy(levelLabel, "E");
        }
        else if (level == kFXLogLevelDebug) {
            strcpy(levelLabel, "D");
        }
        else if (level == kFXLogLevelVerbose) {
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
        
        const char *shortFile = strrchr(file, '/');
        
        if (shortFile == NULL) {
            shortFile = file;
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
                tag, 
                shortFile, 
                line);
        
        NSString *aPrettyMessage1 = [msg 
                                     stringByReplacingOccurrencesOfString:@"\r" 
                                     withString:@"\\r"];
        NSString *aPrettyMessage2 = [aPrettyMessage1 
                                     stringByReplacingOccurrencesOfString:@"\n" 
                                     withString:@"\\n"];
        
        fprintf(flog, "%s\n", [aPrettyMessage2 UTF8String]);
        
        [msg release];
        
#ifndef LOG_TO_CONSOLE
        fclose(flog);
#endif
    }
    
    [autoreleasePool release];
    
    pthread_mutex_unlock(&gLogMutex);
}


