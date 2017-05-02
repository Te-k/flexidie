
//	Copyright (c) 2002-2007 Symbian Software Ltd. All rights reserved.
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
#ifndef __CYPTOSYMMETRIC_H__
#define __CYPTOSYMMETRIC_H__


#include <e32base.h>
#include <e32std.h>
#include <securityerr.h>

/**
 * Top-level interface designed to collate the behaviour of all symmetric
 * ciphers under one interface.
 *
 * See the Cryptography api-guide documentation.
 *
 */
class CSymmetricCipher : public CBase
	{
public:
	/**
	 * Runs the underlying transformation on aInput and appends the result to
	 * aOutput.
	 *
	 * For incremental buffering rules see the Cryptography api-guide documentation.
	 *
	 * @param aInput	The input data to be processed.
	 * @param aOutput	The resulting processed data appended to aOutput.  aOutput must
	 *					have MaxOutputLength() empty bytes remaining in its length.
	 */
	virtual void Process(const TDesC8& aInput, TDes8& aOutput) = 0;

	/**
	 * Pads aInput to be block aligned using the underlying padding system, if any,
	 * and then runs the underlying transformation on aInput, and appends the result
	 * to aOutput.  
	 *
	 * For incremental buffering rules see the Cryptography api-guide documentation.
	 *
	 * @param aInput	The input data to be processed.
	 * @param aOutput	The resulting, possibly padded, processed data appended to
	 *					aOutput.  aOutput must have MaxFinalOutputLength() empty bytes
	 *					remaining in its length.
	 */
	virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput) = 0;

	/**	
	 * Gets a tight upper bound on the number of bytes that would be returned by a
	 * call to Process() with aInputLength bytes of data.
	 *
	 * @param aInputLength	The length of data to be supplied to Process() in bytes.
	 * @return				The length of data which would result from a call to 
	 *						Process() with an aInputLength number of bytes.
	 */
	virtual TInt MaxOutputLength(TInt aInputLength) const = 0;

	/**	
	 * Gets as tight an upper bound as possible on the number of bytes that would
	 * be returned by a call to ProcessFinalL() with aInputLength bytes of data.
	 *
	 * @param aInputLength	The length of data to be supplied to Process() in bytes.
	 * @return				An upper bound on the length of data which would result from 
	 *						a call to ProcessFinalL() with an aInputLength number of bytes.
	 */
	virtual TInt MaxFinalOutputLength(TInt aInputLength) const = 0;

	/**
	 * Resets the cipher back to its original state. Clears all its buffers.
	 */
	virtual void Reset() = 0;

	/**
	 * Gets the block size in bytes (1 for stream ciphers).
	 *
	 * @return	Block size of underlying cipher in bytes.
	 */
	virtual TInt BlockSize() const = 0;

	/**
	 * Gets the key size in bits.
	 *	
	 * @return	Key size in bits.
	 */
	virtual TInt KeySize() const = 0;
};


/**
* Abstract base class defining the interface to block transformation schemes.
*
* Block transformation schemes process a fixed-size block of input to return a
* block of output the same size.  
*
*/
class CBlockTransformation : public CBase
{
public:
	/**
	* Transforms the supplied block, returning the new value using the same
	* parameter. aBlock.Size() must be the same length as BlockSize().
	*
	* @param aBlock	On input, the data to be transformed;
	*				on return, the data after transformation.
	*/
	virtual void Transform(TDes8& aBlock) = 0;
	
	/**
	* Resets the transformation back to its original state. Clears all its buffers.
	*/	
	virtual void Reset() = 0;
	
	/**
	* Gets the block size in bytes.
	*
	* @return	Block size in bytes.
	*/
	virtual TInt BlockSize() const = 0;
	
	/**
	* Gets the key size in bits.	
	* 
	* @return	Key size in bits.
	*/
	virtual TInt KeySize() const = 0;
};



class CPadding;

/**
 * Abstract class, deriving from CSymmetricCipher, encapsulating the buffering
 * logic for block ciphers.
 *
 * It is responsible for feeding complete blocks of plaintext or ciphertext to
 * the underlying encryptor or decryptor.  Since the only difference between
 * block cipher encryption and decryption is the ProcessFinalL() call,
 * CBufferedTransformation implements all functions (by buffering and/or
 * forwarding to the encryptor/decryptor) except ProcessFinalL() and
 * MaxFinalOutputLength().
 *
 * See the Cryptography api-guide documentation for the rules that this class
 * and derived classes must follow.
 *
 */
class CBufferedTransformation : public CSymmetricCipher
{
public:
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CBufferedTransformation();
public:
	/**
	 * Encrypts or decrypts the input using the underlying block cipher, buffering
	 * the input as necessary. 
	 *
	 * See the Cryptography api-guide documentation.
	 *
	 * @param aInput	The input is appended to the internal buffer (initially empty),
	 *					then all whole blocks are encrypted using the underlying block
	 *					transformation and written into aOutput. Any leftover bytes will
	 *					be buffered.
	 * @param aOutput	The resulting processed data appended to aOutput.  aOutput must
	 *					have at least MaxOutputLength() empty bytes remaining in its length.
	 */
	virtual void Process(const TDesC8& aInput, TDes8& aOutput);
	virtual TInt MaxOutputLength(TInt aInputLength) const;
	virtual void Reset();
	virtual TInt BlockSize() const;
	virtual TInt KeySize() const;
public:
	/** 
	 * Gets the underlying block transform.
	 *
	 * @return	A pointer to the CBlockTransformation object
	 */
	 IMPORT_C CBlockTransformation* BlockTransformer() const;
protected:
	/** @internalAll */
	CBufferedTransformation();
};

/**
 * Subclass of CBufferedTransformation for buffered encryption.
 *
 * Objects of this class are intialised with, and subsequently own, an encryptor
 * derived from CBlockTransformation and a subclass of CPadding.
 *
 */
class CBufferedEncryptor : public CBufferedTransformation
{
public:
	/**
	 * Creates a CBufferedEncryptor object taking ownership of aBT and aPadding.
	 *
	 * @param aBT		Block transformation object (encryptor)
	 * @param aPadding	Padding object (deriving from CPadding)
	 * @return			A pointer to the new CBufferedEncryptor object
	 */
	IMPORT_C static CBufferedEncryptor* NewL(CBlockTransformation* aBT, 
		CPadding* aPadding);

	/**
	 * Creates a CBufferedEncryptor object taking ownership of aBT and aPadding.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aBT		Block transformation object (encryptor)
	 * @param aPadding	Padding object (deriving from CPadding)
	 * @return			A pointer to the new CBufferedEncryptor object
	 */
	IMPORT_C static CBufferedEncryptor* NewLC(CBlockTransformation* aBT, 
		CPadding* aPadding);
public:
	/**
	 * Completes an encryption operation using the underlying block transformation, but
	 * first ensuring that input data is block aligned using the previously supplied
	 * CPadding object.  
	 *
	 * See the Cryptography api-guide documentation.
	 *
	 * @param aInput	The final input data to be processed.
	 * @param aOutput	The resulting processed data appended to aOutput.  aOutput must
	 *					have at least MaxFinalOutputLength() empty bytes remaining in its
	 *					length.
	 */
	virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);
	virtual TInt MaxFinalOutputLength(TInt aInputLength) const;
protected:
	/** @internalAll */
	CBufferedEncryptor();
};

/**
 * Subclass of CBufferedTransformation for buffered decryption.
 *
 * Objects of this class are intialised with, and subsequently own, a decryptor
 * derived from CBlockTransformation and a subclass of CPadding.
 *
 */
class CBufferedDecryptor : public CBufferedTransformation
{
public:
	/**
	 * Creates a CBufferedDecryptor object taking ownership of aBT and aPadding.
	 *
	 * @param aBT		Block transformation object (decryptor)
	 * @param aPadding	Padding object (deriving from CPadding)
	 * @return			A pointer to the CBufferedDecryptor object.
	 */
	IMPORT_C static CBufferedDecryptor* NewL(CBlockTransformation* aBT, 
		CPadding* aPadding);

	/**
	 * Creates a CBufferedDecryptor object taking ownership of aBT and aPadding.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aBT		Block transformation object (decryptor)
	 * @param aPadding	Padding object (deriving from CPadding)
	 * @return			A pointer to the new CBufferedDecryptor object
	 */
	IMPORT_C static CBufferedDecryptor* NewLC(CBlockTransformation* aBT, 
		CPadding* aPadding);
public:
	/**
	 * Completes a decryption operation using the underlying block transformation and
	 * unpads the decrypted data.
	 *
	 * @param aInput	The data to be processed and unpadded.  
	 *					aInput must be a whole number of blocks.
	 * @param aOutput	The resulting processed and unpadded data appened to aOutput.
	 *					aOutput must have at least MaxFinalOutputLength() empty bytes
	 *					remaining in its length.
	 */
	virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);
	virtual TInt MaxFinalOutputLength(TInt aInputLength) const;
protected:
	/** @internalAll */
	CBufferedDecryptor();
};


/**
* Abstract class defining the use of block transformation objects as block
* chaining modes.
*
* It is initialised with a subclass of CBlockTransformation,
* which it subsequently owns.  Calls to its Transform() function will call the
* Transform() function in the underlying CBlockTransformation object, and perform
* the additional transformation for block chaining in that mode.  This all means
* that if you want to do, say, AES encryption in CBC mode, you need to construct
* a CAESEncryptor object, then pass it to the CModeCBCEncryptor subclass of
* CBlockChainingMode, and subsequently use the CModeCBCEncryptor object to call
* Transform().
* 
*/
class CBlockChainingMode : public CBlockTransformation
{
public:
	virtual void Reset();
	virtual TInt BlockSize() const;
	virtual TInt KeySize() const;
public:
	/**
	* Sets the initialization vector.
	* 
	* @param aIV	The initialization vector.  The length of this descriptor must be
	*				the same as the underlying cipher's block size.
	*/
	virtual void SetIV(const TDesC8& aIV);
protected:
	/** Default constructor */
	IMPORT_C CBlockChainingMode();
	/** 
	 * Second phase constructor
	 * 
	 * This should be called last by derived classes' ContructL()s .
	 *
	 * @param aBT	A block transformation object
	 * @param aIV	Initialization vector, the length of this descriptor must be
	 *				the same as the underlying cipher's block size.
	 */
	IMPORT_C void ConstructL(CBlockTransformation* aBT, const TDesC8& aIV);
	
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CBlockChainingMode();
protected:
	/** A block transformation object */
	CBlockTransformation* iBT;

	/** 
	 * A buffer containing the feedback register
	 *
	 * This must equal the underlying cipher's block size in length. 
	 * Initially this register is filled with the initialization vector.
	 */
	HBufC8* iRegisterBuf;

	/** Encapsulates a pointer to iRegisterBuf */
	TPtr8 iRegister;

	/** 
	 * A buffer containing the Initialisation Vector (IV) 
	 *
	 * This must equal the underlying cipher's block size in length. 
	 */
	HBufC8* iIVBuf;

	/** Encapsulates a pointer to iIVBuf */
	TPtr8 iIV;
};


/**
* Concrete subclass of CBlockChainingMode implementing CBC mode block chaining
* for encryption.
*
*/
class CModeCBCEncryptor : public CBlockChainingMode
{
public:
	/**
	* Creates an object of this class for CBC mode encryption.
	*
	* @param aBT	An appropriate CBlockTransformation derived encryptor.
	* @param aIV	Initialization vector, the length of this descriptor must be
	*				the same as the underlying cipher's block size.
	* @return		A pointer to the new CModeCBCEncryptor object
	*/
	IMPORT_C static CModeCBCEncryptor* NewL(CBlockTransformation* aBT, 
		const TDesC8& aIV);

	/**
	* Creates an object of this class for CBC mode encryption.
	*
	* The returned pointer is put onto the cleanup stack.
	*
	* @param aBT	An appropriate CBlockTransformation derived encryptor.
	* @param aIV	Initialization vector, the length of this descriptor must be
	*				the same as the underlying cipher's block size.
	* @return		A pointer to the new CModeCBCEncryptor object
	*/
	IMPORT_C static CModeCBCEncryptor* NewLC(CBlockTransformation* aBT, 
		const TDesC8& aIV);
	virtual void Transform(TDes8& aBlock);	
protected:
	/**
	 * @internalAll
	 */
	CModeCBCEncryptor();
private:
	const CModeCBCEncryptor& operator=(const CModeCBCEncryptor&);
};

/**
* Concrete subclass of CBlockChainingMode implementing CBC mode block chaining
* for decryption.
*
*/
class CModeCBCDecryptor : public CBlockChainingMode
{
public:
	/**
	* Creates an object of this class for CBC mode decryption.
	* 
	* @param aBT	An appropriate CBlockTransformation derived decryptor.
	* @param aIV	Initialization vector, the length of this descriptor must be
	*				the same as the underlying cipher's block size.
	* @return		A pointer to the CModeCBCDecryptor new object.
	*/
	IMPORT_C static CModeCBCDecryptor* NewL(CBlockTransformation* aBT, 
		const TDesC8& aIV);

	/**
	* Creates an object of this class for CBC mode decryption.
	*
	* The returned pointer is put onto the cleanup stack.
	* 
	* @param aBT	An appropriate CBlockTransformation derived decryptor.
	* @param aIV	Initialization vector, the length of this descriptor must be
	*				the same as the underlying cipher's block size.
	* @return		A pointer to the CModeCBCDecryptor new object.
	*/
	IMPORT_C static CModeCBCDecryptor* NewLC(CBlockTransformation* aBT, 
		const TDesC8& aIV);
	virtual ~CModeCBCDecryptor(void);
public:
	virtual void Transform(TDes8& aBlock);	
protected:
	/** @internalAll */
	CModeCBCDecryptor();
private:
	const CModeCBCDecryptor& operator=(const CModeCBCDecryptor&);
};


/** The size of the key schedule array (in 32-bit words).
* 
*/
const TUint KDESScheduleSizeInWords = 32;

/**
* Abstract base class for DES, implementing features common between DES encryption and
* decryption. From CBlockTransformation
* 
*/
class CDES : public CBlockTransformation
{
public:	
	virtual void Transform(TDes8& aBlock);
	virtual TInt BlockSize() const;
	virtual TInt KeySize() const;
	virtual void Reset();
	virtual ~CDES();
protected:
	/** @internalAll */
	CDES();
};

/**
* Concrete class for DES encryption.
* 
*/
class CDESEncryptor : public CDES
{
public:
	/**
	* Creates an instance of this class.
	* 
	* @param aKey			The key to be used for encryption. The key length must be
	*						KDESKeySize = 8 bytes.
	* @param aCheckWeakKey	Boolean determining whether to check the key against
	*						a set of known weak key values. Defaults to ETrue. 
	* @return				A pointer to the new CDESEncryptor object.
	*
	* @leave KErrWeakKey			If the key is a weak one, the function leaves having
	*								previously cleaned up any previously allocated memory.
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	* 								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CDESEncryptor* NewL(const TDesC8& aKey, TBool aCheckWeakKey = ETrue);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey			The key to be used for encryption. The key length must be
	*						KDESKeySize = 8 bytes.
	* @param aCheckWeakKey	Boolean determining whether to check the resultant key against
	*						a set of known weak key values. Defaults to ETrue. 
	* @return				A pointer to the new CDESEncryptor object.
	*
	* @leave KErrWeakKey			If the key is a weak one, the function leaves having
	*								previously cleaned up any previously allocated memory.
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CDESEncryptor* NewLC(const TDesC8& aKey, TBool aCheckWeakKey = ETrue);
private:
	CDESEncryptor(void);
};

/**
* Concrete class for DES decryption.
*
*/
class CDESDecryptor : public CDES
{
public:
	/**
	* Creates an instance of this class.
	*
	* @param aKey			The key to be used for decryption. The key length must be
	*						KDESKeySize = 8 bytes.
	* @param aCheckWeakKey	Boolean determining whether to check the resultant key against
	*						a set of known weak key values. Defaults to ETrue.
	* @return				A pointer to the new CDESDecryptor object.
	*
	* @leave KErrWeakKey			If the key is a weak one, the function leaves having
	*								previously cleaned up any previously allocated memory.
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CDESDecryptor* NewL(const TDesC8& aKey, TBool aCheckWeakKey = ETrue);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	* 
	* @param aKey			The key to be used for decryption. The key length must be
	*						KDESKeySize = 8 bytes.
	* @param aCheckWeakKey	Boolean determining whether to check the resultant key against
	*						a set of known weak key values. Defaults to ETrue.
	* @return				A pointer to the new CDESDecryptor object.
	*
	* @leave KErrWeakKey			If the key is a weak one, the function leaves having
	*								previously cleaned up any previously allocated memory.
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CDESDecryptor* NewLC(const TDesC8& aKey, TBool aCheckWeakKey = ETrue);
private:
	CDESDecryptor(void);
};


/**
* Abstract base class for triple-DES.
*
* Implements features common to triple-DES encryption and decryption.
*
*/
class C3DES : public CDES
{
public:
	virtual void Transform(TDes8& aBlock);
	virtual void Reset();
	virtual TInt BlockSize() const;
	virtual TInt KeySize() const;
protected:
	/** @internalAll */
	C3DES();
};

/**
* Concrete class for triple-DES encryption.
*
*/
class C3DESEncryptor : public C3DES
{
public:
	/**
	* Creates an instance of this class.
	*
	* @param aKey	The key to be used for encryption. The key length
	*				must be K3DESKeySize = 24 bytes.
	* @return		A pointer to the new C3DESEncryptor object.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static C3DESEncryptor* NewL(const TDesC8& aKey);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey	The key to be used for encryption. The key length
	*				must be K3DESKeySize = 24 bytes.
	* @return		A pointer to the new C3DESEncryptor object.
	*
	* @leave KErrKeyNotWeakEnough 	If the key size is larger than that allowed by the
	* 								cipher strength restrictions of the crypto library.
	* 								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static C3DESEncryptor* NewLC(const TDesC8& aKey);

};

/**
* Concrete class for triple-DES decryption.
*
*/
class C3DESDecryptor : public C3DES
{
public:
	/**
	* Creates an instance of this class.
	*
	* @param aKey	The key to be used for decryption. The key length
	*				must be K3DESKeySize = 24 bytes.
	* @return		A pointer to the new C3DESDecryptor object.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static C3DESDecryptor* NewL(const TDesC8& aKey);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey	The key to be used for decryption. The key length
	*				must be K3DESKeySize = 24 bytes.
	* @return		A pointer to the new C3DESDecryptor object.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.  
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static C3DESDecryptor* NewLC(const TDesC8& aKey);

};


/**
* Abstract base class for Rijndael, implementing the parts of Rijndael common to both
* Rijndael encryption and decryption.
*
*/
class CRijndael : public CBlockTransformation
{
public:	//	From CBlockTransformation
	virtual void Reset(void);
	virtual TInt KeySize(void) const;
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CRijndael(void);
protected:
	/** Default constructor */
	IMPORT_C CRijndael(void);
	virtual void SetKey(const TDesC8& aKey);
	virtual void ConstructL(const TDesC8& aKey);
protected:
	/** 
	 * The key schedule 
	 *
	 * The maximum size is (((KAESMaxBlockSize/4)+6)+1)*4
	 */
	TUint32 iK[60];
	/** The number of rounds */
	TUint iRounds;
	/** 
	 * The input key 
	 *
	 * The key length (in bytes) must be one of the following:
	 * - KAESKeySize128 (=16)
	 * - KAESKeySize192 (=24)
	 * - KAESKeySize256 (=32).
	 */
	HBufC8* iKey;
private:
	CRijndael(const CRijndael&);
	const CRijndael& operator= (const CRijndael&);
};

/**
* Concrete class for AES encryption.
*
*/
class CAESEncryptor : public CRijndael
{
public:	//	From CBlockTransformation
	/**
	* Creates an instance of this class.
	*
	* @param aKey	The key to be used for encryption. The key length must be either
	*				KAESKeySize128 (=16), KAESKeySize192 (=24) or KAESKeySize256 (=32) bytes.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CAESEncryptor* NewL(const TDesC8& aKey);
	
	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey	The key to be used for encryption. The key length must be either
	*				KAESKeySize128 (=16), KAESKeySize192 (=24) or KAESKeySize256 (=32) bytes.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CAESEncryptor* NewLC(const TDesC8& aKey);
	virtual TInt BlockSize() const;
	virtual void Transform(TDes8& aBlock);
protected:
	/** @internalAll */
	CAESEncryptor(void);
private:
	CAESEncryptor(const CAESEncryptor&);
	const CAESEncryptor& operator= (const CAESEncryptor&);
};

/**
* Concrete class for AES decryption.
*
*/
class CAESDecryptor : public CRijndael
{
public:	//	From CBlockTransformation
	/**
	* Creates an instance of this class.
	*
	* @param aKey	The key to be used for decryption. The key length must be either
	*				KAESKeySize128 (=16), KAESKeySize192 (=24) or KAESKeySize256 (=32) bytes.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library. 
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CAESDecryptor* NewL(const TDesC8& aKey);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey	The key to be used for decryption. The key length must be either
	*				KAESKeySize128 (=16), KAESKeySize192 (=24) or KAESKeySize256 (=32) bytes.
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CAESDecryptor* NewLC(const TDesC8& aKey);
	virtual TInt BlockSize() const;
	virtual void Transform(TDes8& aBlock);
protected:
	/** @internalAll */
	CAESDecryptor(void);
private:
	CAESDecryptor(const CAESDecryptor&);
	const CAESDecryptor& operator= (const CAESDecryptor&);
};


/** SSL Effective Key Length Compatibility.*/
const TUint KSSLCompatibilityBits = 1024;

/** The maximum size in bytes for a RC2 key.*/
const TUint KRC2MaxKeySizeBytes = 128;	//	Max key size in this implementation = 128 bytes

/**
* Abstract base class for RC2 encipherment.
*
*/
class CRC2 : public CBlockTransformation
{
public:	
	virtual void Reset();
	virtual TInt BlockSize() const;
	virtual TInt KeySize() const;
protected:
	/** @internalAll */
	CRC2(void);
};

/**
* Concrete class for RC2 encryption.
*
*/
class CRC2Encryptor : public CRC2
{
public:
	/**
	* Creates an instance of this class.
	*
	* @param aKey					The key to be used for encryption. The key length must fall between 
	*								1 and KRC2MaxKeySizeBytes (=128) bytes inclusive.
	* @param aEffectiveKeyLenBits	Effective key length bits
	*								(defaults KSSLCompatibilityBits = 1024).
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CRC2Encryptor* NewL(const TDesC8& aKey, 
		TInt aEffectiveKeyLenBits = KSSLCompatibilityBits);
	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey					The key to be used for encryption. The key length must fall between 
	*								1 and KRC2MaxKeySizeBytes (=128) bytes inclusive.
	* @param aEffectiveKeyLenBits	Effective key length bits 
	*								(defaults KSSLCompatibilityBits = 1024).
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CRC2Encryptor* NewLC(const TDesC8& aKey, 
		TInt aEffectiveKeyLenBits = KSSLCompatibilityBits);
	virtual void Transform(TDes8& aBlock);
protected:
	/** @internalAll */
	CRC2Encryptor(void);
};

/**
* Concrete class for RC2 decryption.
*
*/
class CRC2Decryptor : public CRC2
{
public:
	/**
	* Creates an instance of this class.
	*
	* @param aKey					The key to be used for decryption. The key length must fall between 
	*								1 and KRC2MaxKeySizeBytes (=128) bytes inclusive.
	* @param aEffectiveKeyLenBits	Effective key length bits 
	*								(defaults KSSLCompatibilityBits = 1024).
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CRC2Decryptor* NewL(const TDesC8& aKey, 
		TInt aEffectiveKeyLenBits = KSSLCompatibilityBits);

	/**
	* Creates an instance of this class and leaves it on the cleanup stack.
	*
	* @param aKey					The key to be used for decryption. The key length must fall between 
	*								1 and KRC2MaxKeySizeBytes (=128) bytes inclusive.
	* @param aEffectiveKeyLenBits	Effective key length bits 
	*								(defaults KSSLCompatibilityBits = 1024).
	*
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CRC2Decryptor* NewLC(const TDesC8& aKey, 
		TInt aEffectiveKeyLenBits = KSSLCompatibilityBits);
	virtual void Transform(TDes8& aBlock);
protected:
	/** @internalAll */
	CRC2Decryptor(void);

};


/**
*	Abstract interface class to be implemented by Stream Ciphers.
*/
class CStreamCipher : public CSymmetricCipher
{
public:	//	From CSymmetricCipher
	/**	
	*	Implemented by calling the DoProcess() pure virtual function, 
	*	to be implemented by subclasses.
	*
	*	@param aInput	Input text.
	*	@param aOutput	Text after processing.
	*/
	IMPORT_C virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);

	/**	
	*	Implemented by calling the DoProcess() pure virtual function, 
	*	to be implemented by subclasses.
	*
	*	@param aInput	Input text.
	*	@param aOutput	Text after processing.
	*/
	IMPORT_C virtual void Process(const TDesC8& aInput, TDes8& aOutput);	

	/**
	*	Gets the block size in bytes (always = 1 for stream ciphers).
	*
	*	@return	Cipher block size (in bytes).
	*/
	IMPORT_C virtual TInt BlockSize(void) const;
	IMPORT_C virtual TInt MaxOutputLength(TInt aInputLength) const;
	IMPORT_C virtual TInt MaxFinalOutputLength(TInt aInputLength) const;
protected:
	/**	
	*	DoProcess() pure virtual function, 
	*	to be implemented by subclasses.
	*
	*	@param aData	On input, text to be processed; on return, processed text.
	*/
	IMPORT_C virtual void DoProcess(TDes8& aData) = 0;
};

/** Number of bytes to discard by default from an ARC4 key stream. */
const TUint KDefaultDiscardBytes = 768;

/**
* Implements an RC4-compatible stream cipher that outputs a pseudorandom stream
* of bits, having been initialised with a key. 
*
*/
class CARC4 : public CStreamCipher
{
public:
	/**
	* Constructs an instance of a CARC4 object, and initialises it with a key and
	* (optionally) the number of initial bytes to discard. Defaults to 256. 
	*
	* The number of dropped bytes <b>must</b> be agreed with the other
	* party, with which information is to be exchanged, prior to encipherment.
	*
	* @note	Several papers have been published indicating that there are weaknesses 
	*		in the first bytes of an ARC4 byte stream.  A search for "ARC4
	*		discard" should find these papers.  Recommended practice is to drop the first
	*		KDefaultDiscardBytes bytes of the key stream.  
	*
	* @param aKey			The key to use.  aKey must be less than or equal to
	*						KRC4MaxKeySizeBytes.  
	* @param aDiscardBytes	The number of bytes to drop from the beginning of the key
	*						stream.
	* @return				A pointer to the new CARC4 object.
	*  
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CARC4* NewL(const TDesC8& aKey, 
		TUint aDiscardBytes = KDefaultDiscardBytes);

	/**
	* Constructs an instance of a CARC4 object, and initialises it with a key and
	* (optionally) the number of initial bytes to discard. Defaults to 256. 
	*
	* The number of dropped bytes <b>must</b> be agreed with the other
	* party, with which information is to be exchanged, prior to encipherment.
	*
	* @see CARC4::NewL()
	*
	* @param aKey			The key to use.  aKey must be less than or equal to
	*						KRC4MaxKeySizeBytes.  
	* @param aDiscardBytes	The number of bytes to drop from the beginning of the key
	*						stream.
	* @return				A pointer to the new CARC4 object.
	*  
	* @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	*								cipher strength restrictions of the crypto library.
	*								See TCrypto::IsSymmetricWeakEnoughL()
	*/
	IMPORT_C static CARC4* NewLC(const TDesC8& aKey, 
		TUint aDiscardBytes = KDefaultDiscardBytes);
public:	
	virtual void Reset(void);
	virtual TInt KeySize(void) const;

private:
	CARC4(const TDesC8& aKey, TUint aDiscardBytes);
};


/**
* Stream cipher that does no encryption or decryption, but simply returns the
* data given to it.
* From CBlockTransformation
*
*/
class CNullCipher : public CStreamCipher
{
public:	
	/**
	 * Creates a new CNullCipher object.
	 * 
	 * @return	A pointer to a new CNullCipher object
	 */
	IMPORT_C static CNullCipher* NewL(void);

	/**
	 * Creates a new CNullCipher object.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @return	A pointer to a new CNullCipher object
	 */
	IMPORT_C static CNullCipher* NewLC(void);
	virtual void Reset(void);
	virtual TInt KeySize(void) const;
protected:
	/**
	 * @internalAll
	 */
	CNullCipher();
};

#endif //__CYPTOSYMMETRIC_H__
