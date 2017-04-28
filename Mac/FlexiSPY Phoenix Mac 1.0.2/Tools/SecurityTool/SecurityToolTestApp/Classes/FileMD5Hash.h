/*
 *  FileMD5Hash.h
 *  FileMD5Hash
 * 
 *  Copyright © 2010 Joel Lopes Da Silva. All rights reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

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

FILEMD5HASH_EXTERN CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath, 
                                                         size_t chunkSizeForReadingData,
														 char *outputBuffer);

FILEMD5HASH_EXTERN CFStringRef DataMD5HashCreate(char *inputBuffer, 
                                                 size_t chunkSizeForReadingData,
												 char *outputBuffer,
												int inputBufferLength);

#endif
