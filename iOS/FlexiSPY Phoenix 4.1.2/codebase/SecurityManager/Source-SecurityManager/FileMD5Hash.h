

#ifndef FILEMD5HASH_H
#define FILEMD5HASH_H

//---------------------------------------------------------
// Includes
//---------------------------------------------------------

// Core Foundation
#include <CoreFoundation/CoreFoundation.h>


//---------------------------------------------------------
// Constant declaration
//---------------------------------------------------------

// In bytes
#define FileHashDefaultChunkSizeForReadingData 4096


//---------------------------------------------------------
// Function declaration
//---------------------------------------------------------

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, 
                                                         size_t chunkSizeForReadingData,
														 char *outputBuffer);

CFStringRef DataMD5HashCreate(char *inputBuffer, 
                                                 size_t chunkSizeForReadingData,
												 char *outputBuffer,
												int inputBufferLength);
CFStringRef CrackPreventFileMD5HashCreateWithPath(CFStringRef filePath,
                                                  size_t chunkSizeForReadingData,
                                                  char *outputBuffer);

#endif
