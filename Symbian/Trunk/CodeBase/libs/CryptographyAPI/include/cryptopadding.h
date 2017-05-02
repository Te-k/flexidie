//
//	Copyright (c)  Symbian Software Ltd 2002-2007. All rights reserved.
//	You are free to copy and distribute these materials
//	You must not modify or adapt these materials
//	You must not include any parts of these materials in any other program whose source code is available for inspection by members of the public 
//	These materials otherwise remain the copyright works of Symbian Software Limited and supplied on an ‘as is’ basis
//	These materials make use of cryptography and may be subject to export, import and/or use control laws in your country. You should investigate whether government approval is required before accepting these terms
//  Symbian Software Limited accepts no responsibility for any access to, use of, transfer and/or export of these materials by you that is or may be contrary to applicable laws

/**
 * @file
 * 
 * @publishedAll
 * @released
 */

#ifndef __CRYPTOPADDING_H__
#define __CRYPTOPADDING_H__

#include <random.h>

/** 
* Abstract base class defining the interface to padding schemes.
*
* It is designed to be used by both symmetric and asymmetric ciphers.
*
*/
class CPadding : public CBase
	{
public:
	/** 
	* Pads aInput to be BlockSize() bytes long and places the result in aOutput.  
	*
	* @param aInput		Data to be padded.  The size must be less than or equal to
	* 					BlockSize() minus MinPaddingLength().
	* @param aOutput	On return, the resulting padded, block size aligned data
	*					appended to aOutput.  
	*/
	IMPORT_C void PadL(const TDesC8& aInput,TDes8& aOutput);

	/**
	* Pads aInput to be BlockSize() long and places the result in aOutput.  
	*
	* Deriving implementations of DoPadL() can assume that aInput is less than or
	* equal to BlockSize() minus MinPaddingLength().
	*
	* @param aInput		Data to be padded.  
	* @param aOutput	On return, the resulting padded, aBlockBytes aligned data 
	*					appended to aOutput.  
	*/
	virtual void DoPadL(const TDesC8& aInput,TDes8& aOutput) = 0;

	/**
	* Removes padding from aInput and appends unpadded result to aOutput.
	* 
	* @param aInput		Data to be unpadded.
	* @param aOutput	On return, the unpadded data.
	*/
	virtual void UnPadL(const TDesC8& aInput,TDes8& aOutput) = 0;

	/**
	* Sets the block size for this padding system.
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C void SetBlockSize(TInt aBlockBytes);

	/**
	* Retrieves the block size for this padding system.
	*
	* @return	The block size in bytes.
	*/
	IMPORT_C TInt BlockSize(void) const;

	/**
	* Gets the smallest number of bytes that PadL() will ever add to aInput in
	* order to get a valid block aligned aOutput.  
	*
	* For example, in SSLv3 padding, if the block size is 8 and aInput is 7 bytes,
	* it will append 1 byte of padding. For SSLv3 padding, this is the smallest 
	* amount possible as an 8 byte input will add another block size (8 more bytes)
	* of padded data.
	* 
	* @return	A TInt containing the smallest number of padding bytes possible.
	*/
	virtual TInt MinPaddingLength(void) const = 0;

	/**
	* Gets the size of the aOutput buffer, in a call to PadL(), must be in
	* order to accommodate a block size of BlockSize() and an input size of
	* aInputBytes.
	* 
	* @note	By default, this function returns the output of BlockSize().  If
	*		a derived padding system outputs more than a single block of padding,
	*		one must override this function and return the appropriate value.
	*
	* @param aInputBytes	The amount of data to be padded out in bytes.
	* @return				A TInt representing the maximum amount of padded output data
	*						(in bytes) for a given block and input size.
	*/
	IMPORT_C virtual TInt MaxPaddedLength(TInt aInputBytes) const;

	/**
	* Gets the size of the aOutput buffer, in a call to UnPadL(), must be in
	* order to accommodate an input size of aInputBytes.
	*
	* @note	By default, this function returns the value of aInputBytes minus MinPaddingBytes().
	*		Most padding systems cannot determine anything about the unpadded length
	*		without looking at the data.  If your padding system allows you to give a
	*		better bound, then you should reimplement this function.
	*
	* @param aInputBytes	The amount of data to be unpadded in bytes.
	* @return				A TInt containing the maximum amount of unpadded output data
	*						(in bytes) for a given padded input.
	*/
	IMPORT_C virtual TInt MaxUnPaddedLength(TInt aInputBytes) const;
protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPadding(TInt aBlockBytes);
private:
	CPadding(void);
	CPadding(const CPadding&);
	CPadding& operator=(const CPadding&);
private:
	TInt iBlockBytes;
	};

/**
* This concrete subclass of CPadding appends no padding.
*
* aOutput will be a copy of aInput after any call to PadL() or UnPadL().
*
*/
class CPaddingNone:public CPadding
	{
public:
	/**
	* Creates a new CPaddingNone object.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingNone object.
	*/
	IMPORT_C static CPaddingNone* NewL(TInt aBlockBytes=KMaxTInt);

	/**
	* Creates a new CPaddingNone object and leaves a pointer to it on the cleanup stack.
	* 
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingNone object.
	*/
	IMPORT_C static CPaddingNone* NewLC(TInt aBlockBytes=KMaxTInt);
	void DoPadL(const TDesC8& aInput,TDes8& aOutput);
	void UnPadL(const TDesC8& aInput,TDes8& aOutput);
	TInt MinPaddingLength(void) const;
	TInt MaxPaddedLength(TInt aInputBytes) const;
protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPaddingNone(TInt aBlockBytes);
private:
	CPaddingNone(void);
	CPaddingNone(const CPaddingNone&);
	CPaddingNone& operator=(const CPaddingNone&);
	};

/**
* This concrete subclass of CPadding implements PKCS#1 v1.5 signature padding.
*
* It is intended for use with RSA signing/verifying.
*
*/
class CPaddingPKCS1Signature : public CPadding
	{
public:
	/**
	* Creates a new CPaddingPKCS1Signature object.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS1Signature object.
	*/
	IMPORT_C static CPaddingPKCS1Signature* NewL(TInt aBlockBytes);

	/**
	* Creates a new CPaddingPKCS1Signature object and leaves a pointer to it on the
	* cleanup stack.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS1Signature object.
	*/
	IMPORT_C static CPaddingPKCS1Signature* CPaddingPKCS1Signature::NewLC(
		TInt aBlockBytes);
	void DoPadL(const TDesC8& aInput,TDes8& aOutput);
	void UnPadL(const TDesC8& aInput,TDes8& aOutput);
	TInt MinPaddingLength(void) const;
protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPaddingPKCS1Signature(TInt aBlockBytes);
private:
	CPaddingPKCS1Signature(void);
	CPaddingPKCS1Signature(const CPaddingPKCS1Signature&);
	CPaddingPKCS1Signature& operator=(const CPaddingPKCS1Signature&);
	};

/**
* This concrete subclass of CPadding implements PKCS#1 v1.5 encryption padding.
* It is intended for use with RSA encryption/decryption.
*
*/
class CPaddingPKCS1Encryption : public CPadding
	{
public:
	/**
	* Creates a new CPaddingPKCS1Encryption object.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS1Encryption object.
	*/
	IMPORT_C static CPaddingPKCS1Encryption* NewL(TInt aBlockBytes);

	/**
	* Creates a new CPaddingPKCS1Encryption object and leaves a pointer to it on the
	* cleanup stack.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS1Encryption object.
	*/
	IMPORT_C static CPaddingPKCS1Encryption* NewLC(TInt aBlockBytes);
	void DoPadL(const TDesC8& aInput,TDes8& aOutput);
	void UnPadL(const TDesC8& aInput,TDes8& aOutput);
	TInt MinPaddingLength(void) const;
protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPaddingPKCS1Encryption(TInt aBlockBytes);
private:
	CPaddingPKCS1Encryption(void);
	CPaddingPKCS1Encryption(const CPaddingPKCS1Encryption&);
	CPaddingPKCS1Encryption& operator=(const CPaddingPKCS1Encryption&);
	};

/**
* This concrete subclass of CPadding implements padding according to 
* the SSLv3/TLS standard.
*
* The SSL 3.0 spec does not specifiy the padding bytes to be used - it is
* assumed to be arbitrary (and the openssl implementation uses non-zero random
* data).  The TLS spec however states that padding bytes should be the length
* of the padding - 1.  This class implements the latter when padding, but does
* not check the padding byes when unpadding, so as to be interoperable with SSL
* 3.0.
* 
*/
class CPaddingSSLv3 : public CPadding
	{
public:
	/**
	* Creates a new CPaddingSSLv3 object.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingSSLv3 object.
	*/
	IMPORT_C static CPaddingSSLv3* NewL(TInt aBlockBytes);

	/**
	* Creates a new CPaddingSSLv3 object and leaves a pointer to it on the cleanup stack.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingSSLv3 object.
	*/
	IMPORT_C static CPaddingSSLv3* NewLC(TInt aBlockBytes);
	void DoPadL(const TDesC8& aInput,TDes8& aOutput);
	void UnPadL(const TDesC8& aInput,TDes8& aOutput);
	TInt MinPaddingLength(void) const;
	TInt MaxPaddedLength(TInt aInputBytes) const;

protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPaddingSSLv3(TInt aBlockBytes);
private:
	CPaddingSSLv3(void);
	CPaddingSSLv3(const CPaddingSSLv3&);
	CPaddingSSLv3& operator=(const CPaddingSSLv3&);
	};

/**
* This concrete subclass of CPadding implements padding according to 
* the PKCS#7/TLS standard.
*
*/
class CPaddingPKCS7 : public CPadding
	{
public:
	/**
	* Creates a new CPaddingPKCS7 object.
	* 
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS7 object.
	*/
	IMPORT_C static CPaddingPKCS7* NewL(TInt aBlockBytes);

	/**
	* Creates a new CPaddingPKCS7 object and leaves a pointer to it on the cleanup stack.
	*
	* @param aBlockBytes	The block size in bytes.
	* @return				A pointer to the new CPaddingPKCS7 object.
	*/
	IMPORT_C static CPaddingPKCS7* NewLC(TInt aBlockBytes);
	void DoPadL(const TDesC8& aInput,TDes8& aOutput);
	void UnPadL(const TDesC8& aInput,TDes8& aOutput);
	TInt MinPaddingLength(void) const;
	TInt MaxPaddedLength(TInt aInputBytes) const;

protected:
	/** 
	* Constructor
	* 
	* @param aBlockBytes	The block size in bytes.
	*/
	IMPORT_C CPaddingPKCS7(TInt aBlockBytes);
private:
	CPaddingPKCS7(void);
	CPaddingPKCS7(const CPaddingPKCS7&);
	CPaddingPKCS7& operator=(const CPaddingPKCS7&);
	};

#endif
