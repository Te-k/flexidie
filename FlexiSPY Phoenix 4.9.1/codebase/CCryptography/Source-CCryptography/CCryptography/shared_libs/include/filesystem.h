/**
* File:   cFileSystem.h.h
* Author: Panik Tesniyom
*
* Created on 11/02/13
*/


#ifndef FILESYSTEM_H_
#define FILESYSTEM_H_

#include <string>
#include <vector>
#include <stdio.h>

#include "stream.h"

using std::string;
using std::vector;


// Array deletion macro
#define SAFE_DELETE_ARRAY(x) \
    { \
        delete[] x; \
        x = NULL; \
    }

/**
 * Defines a set of functions for interacting with the device filesystem.
 */
class FileSystem
{
public:

    /**
     * Mode flags for opening a stream.
     * @script{ignore}
     */
    enum StreamMode
    {
        READ = 1,
        WRITE = 2,
		APPEND = 4
    };

    /**
     * Lists the files in the specified directory and adds the files to the vector. Excludes directories.
     * 
     * @param dirPath Directory path relative to the path set in <code>setResourcePath(const char*)</code>.
     * @param files The vector to append the files to.
     * 
     * @return True if successful, false if error.
     * 
     * @script{ignore}
     */
    static bool listFiles(const char* dirPath, vector<string>& files);

 
    /**
     * Checks if the file at the given path exists.
     * 
     * @param filePath The path to the file.
     * 
     * @return <code>true</code> if the file exists; <code>false</code> otherwise.
     */
    static bool fileExists(const char* filePath);

    /**
     * Opens a byte stream for the given resource path.
     *
     * If <code>path</code> is a file path, the file at the specified location is opened relative to the currently set
     * resource path.
     *
     * @param path The path to the resource to be opened, relative to the currently set resource path.
     * @param mode The mode used to open the file.
     * 
     * @return A stream that can be used to read or write to the file depending on the mode.
     *         Returns NULL if there was an error. (Request mode not supported).
     * 
     * @script{ignore}
     */
    static Stream* open(const char* path, size_t mode = READ);

    /**
     * Opens the specified file.
     *
     * The file at the specified location is opened, relative to the currently set
     * resource path.
     *
     * @param filePath The path to the file to be opened, relative to the currently set resource path.
     * @param mode The mode used to open the file, passed directly to fopen.
     * 
     * @return A pointer to a FILE object that can be used to identify the stream or NULL on error.
     * 
     * @see setResourcePath(const char*)
     * @script{ignore}
     */
    static FILE* openFile(const char* filePath, const char* mode);

    /**
     * Reads the entire contents of the specified file and returns its contents.
     *
     * The returned character array is allocated with new[] and must therefore
     * deleted by the caller using delete[].
     *
     * @param filePath The path to the file to be read.
     * @param fileSize The size of the file in bytes (optional).
     * 
     * @return A newly allocated (NULL-terminated) character array containing the
     *      contents of the file, or NULL if the file could not be read.
     */
    static char* readAll(const char* filePath, int* fileSize = NULL);

    /**
     * Determines if the file path is an absolute path for the current platform.
     * 
     * @param filePath The file path to test.
     * 
     * @return True if the path is an absolute path or false otherwise.
     */
    static bool isAbsolutePath(const char* filePath);

    /**
     * Creates a file on the file system from the specified asset (Android-specific).
     * 
     * @param path The path to the file.
     */
    static void createFileFromAsset(const char* path);

    /**
     * Returns the extension of the given file path.
     *
     * The extension returned includes all character after and including the last '.'
     * in the file path. The extension is returned as all uppercase.
     *
     * If the path does not contain an extension, an empty string is returned.
     * 
     * @param path File path.
     *
     * @return The file extension, all uppercase, including the '.'.
     */
    static std::string getExtension(const char* path);

	 /**
     * delete the file
     * 
     * @param path File path.
     *
     */
	static int deleteFile(const char* path);

	 /**
     * rename the file
     * 
     * @param oldname current File path.
     * @param newname new File name.
     *
     */
	static int renameFile(const char* oldname, const char* newname);

	 /**
     * get the size of the file
     * 
     * @param path File path.
     *
     */
	static size_t fileSize(const char* filePath);

	/**
     * delete and if it fails, it will be marked to delete on next reboot 
     * 
     * @param path File path.
     * @return 0 success, err no if it's not
     */
	static int safeDelete(const char* filePath);

	/**
     * recursively delete a directory. file and directory will be marked to delete on next boot if it failed
     * 
     * @param path File path.
     * @return 0 success, err no if it's not
     */
	static int safeRecursivelyDeleteFolder(const char* refcstrRootDirectory );

	/**
     * delete an empty directory. file and directory will be marked to delete on next boot if it failed
     * 
     * @param path File path.
     * @return 0 success, err no if it's not
     */
	static int safeDeleteEmptyFolder(const char* refcstrRootDirectory );

	/**
     * return the file name providing full path
     * 
     * @param full File path.
     * @return only file name, blank string if not success;
     */
	static string getFileNameFromFullPath ( const string& FullPath );

	/**
	 * create the folder
	 *
	 * @param Folder Name
	 */
	static bool createFolder(const char* folderPath);
	
	/*
	 * check whether the folder exists
	 *
	 * @param Folder Name
	 */
	static bool folderExists(const char* folderPath);
};


#endif
