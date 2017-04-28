#ifndef _CRYPTOWORKERTHREAD_H
#define _CRYPTOWORKERTHREAD_H

#include <vector>

#include <cryptography.h>
#include <string_exception.h>

using namespace Thread;

namespace Cryptography
{


/**
* Worker Thread Class
*
* Is the thread that will perform the CRC for asychronous calls
*/

class cCryptoWorkerThread
{
private:
	cCrypto*		m_pCrypto;
	std::string		m_sFileName;
	std::string		m_sOutputFileName;
	std::vector < ICryptoListener* > m_vecListeners;	
	Thread::cMutexHandler*	m_pMutex; 

public:
	
	/**
	* ctor
	*/
	cCryptoWorkerThread();

	/**
	* dtor
	*/
	virtual ~cCryptoWorkerThread();

	/**
	*	Add a callback 
	*
	*/ 
	void addListener ( ICryptoListener* pNewListener ); 
	
	/**
	* Notify all the listener. 
	*
	* @param e	Exception
	*/ 
	void notifyError ( eCryptoOP eOP, StringException e );

	/**
	* Notify all the listeners the result.
	*
	* @param sFilePath	FilePath
	*/ 
	void notifyResult ( eCryptoOP eOP, std::string sFilePath ); 

	/**
	* Set up parameters
	*
	* @param cCrypto	crypto Item
	* @param sFileName	The name of a file to be calculated
	* @param sOutputFile	Path of the output file
	* @param pMutex		Mutex object for thrad locking
	*/
	void setParams ( cCrypto* pCrypto, std::string sFileName, std::string sOutputFile, Thread::cMutexHandler* pMutex );

	/**
	* call encrypt 
	*/
	void encrypt ();

	/**
	* call decrypt
	*/
	void decrypt ();

};

} // name space


#endif
