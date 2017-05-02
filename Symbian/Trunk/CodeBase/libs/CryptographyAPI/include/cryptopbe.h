//
// Copyright (C) 2002-2007 Symbian Software Ltd. All rights reserved.
//
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

#ifndef __CRYPTOPBE_H__
#define __CRYPTOPBE_H__

#include <e32base.h>
#include <e32std.h>
#include <s32strm.h>
#include <hash.h>
#include <cryptopadding.h>
#include <cryptosymmetric.h>

class CPBEncryptParms;
class CPBEncryptionData;
class CPBEncryptSet;
class TPBPassword;

/** 
 * Abstract class defining the interface required to allow the actual
 * transformation of plaintext to ciphertext.
 *
 * Generally this class' descendants are constructed using the
 * functions CPBEncryptElement::NewEncryptLC() or CPBEncryptSet::NewEncryptLC().
 *
 * @see CPBEncryptorElement and CPBEncryptorSet
 */
class CPBEncryptor : public CBase
	{
public:
	/** 
	 * Transforms aInput into its encrypted form, aOutput.
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 *
	 * @param aInput	The plaintext.
	 * @param aOutput	On return, the ciphertext.
	 */
	virtual void Process(const TDesC8& aInput, TDes8& aOutput) = 0;

	/** 
	 * Transforms aInput into its encrypted form, aOutput, and applies a
	 * padding scheme to ensure a block aligned result.
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 * 
	 * @param aInput	The plaintext.
	 * @param aOutput	On return, the ciphertext.
	 */
	virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput) = 0;

	/** 
	 * Gets the maximum length of the output resulting from calling Process() with a
	 * given input length.
	 *
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	virtual TInt MaxOutputLength(TUint aMaxInputLength) const = 0;
	
	/** 
	 * Gets the maximum length of the output resulting from calling ProcessFinalL()
	 * with a given input length.
	 *
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	virtual TInt MaxFinalOutputLength(TUint aMaxInputLength) const = 0;
};

/** 
 * Abstract class defining the interface required to allow the actual
 * transformation of ciphertext to plaintext.
 *  
 * Generally this class' descendants are constructed using the
 * functions CPBEncryptElement::NewDecryptLC() or CPBEncryptSet::NewDecryptLC().
 */
class CPBDecryptor : public CBase
	{
public:
	/** 
	 * Transforms aInput into its decrypted form, aOutput, and unpads.
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 * 
	 * @param aInput	The ciphertext.
	 * @param aOutput	On return, the plaintext.
	 */
	virtual void Process(const TDesC8& aInput, TDes8& aOutput) = 0;

	/** 
	 * Transforms aInput into its decrypted form, aOutput, and unpads.
	 * 
	 * @param aInput	The ciphertext.
	 * @param aOutput	On return, the plaintext.
	 */
	virtual void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput) = 0;

	/** 
	 * Gets the maximum length of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	virtual TInt MaxOutputLength(TUint aMaxInputLength) const = 0;
	
	/** 
	 * Gets the maximum length of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	virtual TInt MaxFinalOutputLength(TUint aMaxInputLength) const = 0;
	};

/** 
 * Abstract base class defining the interface required to allow the password
 * based encryption and decryption of single or multiple items or elements.
 * 
 * @see CPBEncryptElement and CPBEncryptSet
 * @since v8.0
 */
class CPBEncryptionBase : public CBase
	{
public:
	/** 
	 * Gets the parameters allowing one to re-create the object with the
	 * same state at another point in the future.  
	 * 
	 * In order to decrypt any information previously encrypted with this object, 
	 * you <B><I>must</I></B> store this encryption data along with it. Failure 
	 * to do this will result in the permanent loss of the encrypted information.
	 * 
	 * @return	The data allowing one to re-create this object at a later time.
	 */
	virtual const CPBEncryptionData& EncryptionData(void) const = 0;

	/** 
	 * Constructs a CPBEncryptor object allowing the encryption of data.
	 *
	 * @return	A pointer to a CPBEncryptor object.
	 *			The caller assumes ownership of the returned object. 
	 */
	virtual CPBEncryptor* NewEncryptL(void) const = 0;

	/** 
	 * Constructs a CPBEncryptor object allowing the encryption of data.
	 * 
	 * @return	A pointer to a CPBEncryptor object.
	 *			The caller assumes ownership of the returned object.
	 *			The returned pointer is left on the cleanup stack.
	 */
	virtual CPBEncryptor* NewEncryptLC(void) const = 0;

	/** 
	 * Constructs a CPBDecryptor object allowing the decryption of data.
	 * 
	 * @return	A pointer to a CPBDecryptor object.
	 *			The caller assumes ownership of the returned object.
	 */
	virtual CPBDecryptor* NewDecryptL(void) const = 0;

	/** 
	 * Constructs a CPBDecryptor object allowing the decryption of data.
	 * 
	 * @return	A pointer to a CPBDecryptor object.
	 *			The caller assumes ownership of the returned object.
	 *			The returned pointer is left on the cleanup stack.
	 */
	virtual CPBDecryptor* NewDecryptLC(void) const = 0;

	/** 
	 * Gets the maximum output ciphertext length given a specified input plaintext length.  
	 * 
	 * @param aPlaintextLength	The plaintext length 
	 * @return					The maximum ciphertext length given a plaintext length.
	 */
	virtual TInt MaxCiphertextLength(TInt aPlaintextLength) const = 0;

	/** 
	 * Gets the maximum output plaintext length given a specified input ciphertext length.
	 *
	 * @param aCiphertextLength	The ciphertext length
	 * @return					The maximum plaintext length given a ciphertext length.
	 */
	virtual TInt MaxPlaintextLength(TInt aCiphertextLength) const = 0;

	};


/** 
 * Password Based Encryption ciphers.
 *
 * Note that RC2 has an additional key parameter, the "effective key length".
 *
 * Used in the construction of CPBEncryptElement, CPBEncryptSet, CPBEncryptParms,
 * and CPBEncryptionData objects and in the CPBEncryptParms::Cipher() function.
 */
enum TPBECipher
	{
	/** AES cipher in CBC mode with a supplied key size of 128 bits. */
	ECipherAES_CBC_128,
	/** AES cipher in CBC mode with a supplied key size of 192 bits. */
	ECipherAES_CBC_192,
	/** AES cipher in CBC mode with a supplied key size of 256 bits. */
	ECipherAES_CBC_256,
	/** DES cipher in CBC mode (with a supplied key size of 56 bits). */
	ECipherDES_CBC,
	/** Triple-DES cipher in CBC mode. */
	ECipher3DES_CBC,
	/** 
	 * RC2 cipher in CBC mode with a supplied key length of 40 bits.
	 * 
	 * It has an effective key length of 1024 bits (128 bytes), which is compatible
	 * with OpenSSL RC2 encryption.
	 */
	ECipherRC2_CBC_40, 
	/**
	 * RC2 cipher in CBC mode with a supplied key length of 128 bits. 
	 * 
	 * It has an effective key length of 1024 bits (128 bytes), which is compatible
	 * with OpenSSL RC2 encryption.
	 */
	ECipherRC2_CBC_128,
	/**
	 * RC2 cipher in CBC mode with a supplied key length of 40 bits.
	 * 
	 * It has an effective key length of 128 bits (16 bytes), which is compatible 
	 * with the RC2 encryption used in PKCS#8 encryption keys generated by OpenSSL
	 */
	ECipherRC2_CBC_40_16,
	/**
	 * RC2 cipher in CBC mode with a supplied key length of 128 bits. 
	 * 
	 * It has an effective key length of 128 bits (16 bytes), which is compatible 
	 * with the RC2 encryption used in PKCS#8 encryption keys generated by OpenSSL
	 */
	ECipherRC2_CBC_128_16
	};

/** 
 * Allows the password based encryption and decryption of elements.
 * Contains the encryption key and its associated encryption data.
 * See the Cryptography api-guide documentation for more information 
 * and sample code.
 */
class CPBEncryptElement : public CPBEncryptionBase
	{
public:
	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 *
	 * If strong cryptography is present, a 128 bit AES cipher is used; 
	 * otherwise, for weak cryptography, a 56 bit DES cipher is used.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewL(const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 * 
	 * If strong cryptography is present, a 128 bit AES cipher is used; 
	 * otherwise, for weak cryptography, a 56 bit DES cipher is used.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 *
	 * A pointer to the returned object is put onto the cleanup stack.
	 *
	 * @param aPassword	The user supplied password
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewLC(const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aCipher	The cipher to use
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewL(const TPBPassword& aPassword, 
		TPBECipher aCipher);

	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 * 
	 * A pointer to the returned object is put onto the cleanup stack.
	 *
	 * @param aPassword	The user supplied password
	 * @param aCipher	The cipher to use
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewLC(const TPBPassword& aPassword, 
		TPBECipher aCipher);

	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 *
	 * The symmetric key is derived from the password using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aParms	An encryption parameter object comprising the cipher,
	 *					salt, IV, and iteration count value. 
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewL(const TPBPassword& aPassword, 
		const CPBEncryptParms& aParms);

	/**
	 * Creates a new CPBEncryptElement object for encryption of new data.
	 *
	 * The symmetric key is derived from the password using TPKCS5KDF::DeriveKeyL().
	 * 
	 * A pointer to the returned object is put onto the cleanup stack.
	 *
	 * @param aPassword	The user supplied password
	 * @param aParms	An encryption parameter object comprising the cipher,
	 *					salt, IV, and iteration count value. 
	 * @return			The new CPBEncryptElement object
	 */
	IMPORT_C static CPBEncryptElement* NewLC(const TPBPassword& aPassword, 
		const CPBEncryptParms& aParms);

	/**
	 * Creates a new CPBEncryptElement object for decryption of existing data.
	 *
	 * If the specified password is valid, the function regenerates the encryption key;
	 * otherwise, it leaves with KErrBadPassphrase.
	 *
	 * @param aData				The encryption data object
	 * @param aPassword			The user supplied password
	 * @return					The new CPBEncryptElement object
	 * @leave KErrBadPassphrase	If the specified password is incorrect
	 */
	IMPORT_C static CPBEncryptElement* NewL(const CPBEncryptionData& aData,
		const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptElement object for decryption of existing data.
	 *
	 * If the specified password is valid, the function regenerates the encryption key;
	 * otherwise, it leaves with KErrBadPassphrase.
	 *
	 * A pointer to the returned object is put onto the cleanup stack.
	 *
	 * @param aData				The encryption data object
	 * @param aPassword			The user supplied password
	 * @return					The new CPBEncryptElement object
	 * @leave KErrBadPassphrase	If the specified password is incorrect
	 */
	IMPORT_C static CPBEncryptElement* NewLC(const CPBEncryptionData& aData,
		const TPBPassword& aPassword);

	/** 
	 * Gets the parameters allowing one to re-create the object with the
	 * same state at another point in the future.  
	 * 
	 * In order to decrypt any information previously encrypted with this object, 
	 * you <B><I>must</I></B> store this encryption data along with it. Failure 
	 * to do this will result in the permanent loss of the encrypted information.
	 * 
	 * @return The data allowing one to re-create this object at a later time.					
	 */
	const CPBEncryptionData& EncryptionData(void) const;

	/** 
	 * Constructs a CPBEncryptor object allowing the encryption of data.
	 * 
	 * @return	A pointer to a CPBEncryptor object.
	 *			The caller assumes ownership of the returned object.
	 */
	CPBEncryptor* NewEncryptL(void) const;

	/** 
	 * Constructs a CPBEncryptor object allowing the encryption of data.
	 * 
	 * @return	A pointer to a CPBEncryptor object.
	 *			The caller assumes ownership of the returned object.
	 *			The returned pointer is left on the cleanup stack.
	 */
	CPBEncryptor* NewEncryptLC(void) const;

	/** 
	 * Constructs a CPBDecryptor object allowing the decryption of data.
	 * 
	 * @return	A pointer to a CPBDecryptor object.
	 *			The caller assumes ownership of the returned object.
	 */
	CPBDecryptor* NewDecryptL(void) const;

	/** 
	 * Constructs a CPBDecryptor object allowing the decryption of data.
	 * 
	 * @return	A pointer to a CPBDecryptor object.
	 *			The caller assumes ownership of the returned object.
	 *			The returned pointer is left on the cleanup stack.
	 */
	CPBDecryptor* NewDecryptLC(void) const;

	/** 
	 * Gets the maximum output ciphertext length given a specified input plaintext length.  
	 * 
	 * @param aPlaintextLength	The plaintext length 
	 * @return					The maximum ciphertext length given a plaintext length.
	 */
	TInt MaxCiphertextLength(TInt aPlaintextLength) const;

	/** 
	 * Gets the maximum output plaintext length given a specified input ciphertext length.
	 *
	 * @param aCiphertextLength	The ciphertext length
	 * @return					The maximum plaintext length given a ciphertext length.
	 */
	TInt MaxPlaintextLength(TInt aCiphertextLength) const;

	/** Destructor */
	virtual ~CPBEncryptElement(void);
protected:
	/** @internalAll */
	CPBEncryptElement(void);
private:
	CPBEncryptElement(const CPBEncryptElement&);
	CPBEncryptElement& operator= (const CPBEncryptElement&);
	};

/** 
 * Derived class to allow the efficient password based encryption and
 * decryption of multiple elements.
 * 
 * This is useful if one wants random access to an encrypted source consisting 
 * of multiple independent elements, for example, a database or a store. 
 * 
 * Since it is unreasonable to force the decryption of an entire set to allow 
 * access to just a tiny portion of it, and since it is too costly to derive separate 
 * keys for each element within the set, a single randomly generated <I>master</I> 
 * key is used.  This master key is encrypted with the password provided by the 
 * user of the class. Known plaintext attacks against the ciphertext are prevented 
 * by using a randomly chosen Initialisation Vector (IV) for each element.  
 * 
 * Contains the master encryption key.
 *
 * See the Cryptography api-guide documentation for more information and sample code.
 *
 * @see CPBEncryptElement
 * 
 * @since v8.0
 */
class CPBEncryptSet : public CPBEncryptElement
	{
public:
	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * If strong cryptography is present, a 128 bit AES cipher is used; 
	 * otherwise, for weak cryptography, a 56 bit DES cipher is used.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 *
	 * @param aPassword	The users password.
	 * @return			A new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewL(const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * If strong cryptography is present, a 128 bit AES cipher is used; 
	 * otherwise, for weak cryptography, a 56 bit DES cipher is used.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 *
	 * @param aPassword	The user supplied password
	 * @return			The new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewLC(const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aCipher	The cipher to use
	 * @return			The new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewL(const TPBPassword& aPassword, 
		TPBECipher aCipher);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * The symmetric key is derived from the password and a random salt using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aCipher	The cipher to use
	 * @return			The new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewLC(const TPBPassword& aPassword, 
		TPBECipher aCipher);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The symmetric key is derived from the password using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aParms	An encryption parameter object comprising the cipher,
	 *					salt, IV, and iteration count value. 
	 * @return			The new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewL(const TPBPassword& aPassword, 
		const CPBEncryptParms& aParms);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * The symmetric key is derived from the password using TPKCS5KDF::DeriveKeyL().
	 * 
	 * @param aPassword	The user supplied password
	 * @param aParms	An encryption parameter object comprising the cipher,
	 *					salt, IV, and iteration count value. 
	 * @return			The new CPBEncryptSet object
	 */
	IMPORT_C static CPBEncryptSet* NewLC(const TPBPassword& aPassword, 
		const CPBEncryptParms& aParms);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * If the specified password is valid, the function regenerates the encryption key;
	 * otherwise, it leaves with KErrBadPassphrase.
	 *
	 * @param aData					The encryption data object to copy 
	 * @param aEncryptedMasterKey	On return, the encrypted master key
	 * @param aPassword				The user supplied password
	 * @return						The new CPBEncryptSet object
	 * @leave KErrBadPassphrase		If the specified password is incorrect
	 */
	IMPORT_C static CPBEncryptSet* NewL(const CPBEncryptionData& aData,
		const TDesC8& aEncryptedMasterKey, const TPBPassword& aPassword);

	/**
	 * Creates a new CPBEncryptSet object for encryption of new data 
	 * (and generates an encrypted master key).
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * If the specified password is valid, the function regenerates the encryption key;
	 * otherwise, it leaves with KErrBadPassphrase.
	 *
	 * @param aData					The encryption data object to copy 
	 * @param aEncryptedMasterKey	On return, the encrypted master key
	 * @param aPassword				The user supplied password
	 * @return						The new CPBEncryptSet object
	 * @leave KErrBadPassphrase		If the specified password is incorrect
	 */
	IMPORT_C static CPBEncryptSet* NewLC(const CPBEncryptionData& aData,
		const TDesC8& aEncryptedMasterKey, const TPBPassword& aPassword);
	
	/** 
	 * Gets the encrypted form of the master key.  
	 *
	 * This must be stored along with the object returned by CPBEncryptElement::EncryptionData() 
	 * in order for the object to be reconstructed with the same state at
     * some time in the future. Failure to do so will result in the permanent
     * loss of any information encrypted with this object.
     * 
     * @return		The encrypted master key.
     */
	IMPORT_C const TDesC8& EncryptedMasterKey(void) const;
	
	/** 
     * Re-encrypts the master key with the specified new password.
     *
     * @param aNewPassword	The new password
     */
	IMPORT_C void ChangePasswordL(const TPBPassword& aNewPassword);
	
	/** Destructor */
	virtual ~CPBEncryptSet(void);

protected:
	/** @internalAll */
	CPBEncryptSet(void);

private:
	CPBEncryptSet(const CPBEncryptSet&);
	CPBEncryptSet& operator= (const CPBEncryptSet&);
	};

/** 
 * Class representing both 8 and 16 bit descriptor passwords.
 * Internally these are stored as 8 bit passwords.
 */
class TPBPassword
	{
public:
	/** 
	 * Sets the password.
	 * 
	 * Constructs a TPBPassword object with an 8 bit descriptor.
	 * 
	 * Internally this is represented as an octet byte sequence 
	 * (aka 8 bit TPtrC8 descriptor).
	 * 
	 * @param aPassword	A const reference to an 8 bit descriptor.
	 * 					representing the users initial password.
	 */
	IMPORT_C TPBPassword(const TDesC8& aPassword);
	
	/** 
	 * Sets the password.
	 * 
	 * Constructs a TPBPassword object with a 16 bit descriptor.
	 *
	 * Internally this is represented as an octet byte sequence
	 * (aka 8 bit TPtrC8 descriptor).
	 * 
	 * @param aPassword	A const reference to a 16 bit descriptor
	 * 					representing the users initial password.
	 */
	IMPORT_C TPBPassword(const TDesC16& aPassword);
	
	/**
	 * Gets the password.
	 * 
	 * Gets a const reference to an 8 bit descriptor representing the users
	 * initial password (which could have been either 8 or 16 bit).
	 * 
	 * @return		A const reference to an 8 bit descriptor.
	 */
	IMPORT_C const TDesC8& Password(void) const;
private:
	TPtrC8 iPassword;
	};



/**
 * Contains the Password Based Encryption parameters.
 * An object of this class can be input for CPBEncryptElement or CPBEncryptSet objects.
 *
 * @since v7.0s
 */
class CPBEncryptParms : public CBase
	{
public:
	/**
	 * Creates a new CPBEncryptParms object.
	 *
	 * @param aCipher		The cipher to use
	 * @param aSalt			The salt
	 * @param aIV			The Initialization Vector
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBEncryptParms object
	 */
	IMPORT_C static CPBEncryptParms* NewL(TPBECipher aCipher,
		const TDesC8& aSalt, const TDesC8& aIV, TUint aIterations);

	/**
	 * Creates a new CPBEncryptParms object and puts a pointer to it onto the cleanup stack.
	 *
	 * @param aCipher		The cipher to use
	 * @param aSalt			The salt
	 * @param aIV			The Initialization Vector
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBEncryptParms object
	 */
	IMPORT_C static CPBEncryptParms* NewLC(TPBECipher aCipher,
		const TDesC8& aSalt, const TDesC8& aIV, TUint aIterations);

	/**
	 * Creates a new CPBEncryptParms object from an existing object.
	 *
	 * @param aParms		The existing encryption parameters object
	 * @return				A pointer to the new CPBEncryptParms object
	 */
	IMPORT_C static CPBEncryptParms* NewL(const CPBEncryptParms& aParms);

	/**
	 * Creates a new CPBEncryptParms object from an existing object
	 * and puts a pointer to it onto the cleanup stack.
	 *
	 * @param aParms		The existing encryption parameters object
	 * @return				A pointer to the new CPBEncryptParms object
	 */
	IMPORT_C static CPBEncryptParms* NewLC(const CPBEncryptParms& aParms);

	/**
	 * Internalizes encryption parameter data from a read stream.
	 *
	 * @param aStream	The read stream to be internalized
	 * @return			A pointer to the new CPBEncryptParms object
	 * 
	 */
	IMPORT_C static CPBEncryptParms* NewL(RReadStream& aStream);

	/**
	 * Internalizes encryption parameter data from a read stream, and 
	 * puts a pointer to the new object onto the cleanup stack.
	 *
	 * @param aStream	The read stream to be internalized
	 * @return			A pointer to the new CPBEncryptParms object
	 */
	IMPORT_C static CPBEncryptParms* NewLC(RReadStream& aStream);

	/**
	 * Gets the PBE cipher
	 *
	 * @return	The cipher to use
	 */
	IMPORT_C TPBECipher Cipher() const;

	/**
	 * Gets the PBE salt
	 *
	 * @return	The salt
	 */
	IMPORT_C TPtrC8 Salt() const;

	/**
	 * Gets the number of iterations for the PKCS#5 algorithm.
	 *
	 * @return	The number of iterations
	 */
	IMPORT_C TInt Iterations() const;

	/**
	 * Gets the PBE Initialization Vector
	 *
	 * @return	The IV
	 */
	IMPORT_C TPtrC8 IV() const;

	/**
	 * Externalizes the encryption parameters into a write stream.
	 *
	 * @param aStream	The stream to write to
	 */
	IMPORT_C void ExternalizeL(RWriteStream& aStream) const;

	/** Destructor */
	virtual ~CPBEncryptParms(void);
protected:	
	/** Constructor */
	IMPORT_C CPBEncryptParms(void);
private:
	CPBEncryptParms(const CPBEncryptParms&);
	CPBEncryptParms& operator= (const CPBEncryptParms&);
	};

/**
 * Contains the password based authentication data.
 * Used to check the passphrase when decrypting.
 *
 * @since v7.0s
 */
class CPBAuthData : public CBase
	{
public:
	/**
	 * Derives an authentication key.
	 *
	 * @param aPassword		The user's initial password
	 * @param aSalt			The salt
	 * @param aKeySize		The key size
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewL(const TDesC8& aPassword, 
		const TDesC8& aSalt, TUint aKeySize, TUint aIterations);

	/**
	 * Derives an authentication key.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aPassword		The user's initial password
	 * @param aSalt			The salt
	 * @param aKeySize		The key size
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewLC(const TDesC8& aPassword, 
		const TDesC8& aSalt, TUint aKeySize, TUint aIterations);

	/**
	 * Creates a new CPBAuthData object from an existing authentication key.
	 *
	 * @param aData	The existing CPBAuthData object
	 * @return		A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewL(const CPBAuthData& aData);

	/**
	 * Creates a new CPBAuthData object from an existing authentication key.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aData	The existing CPBAuthData object
	 * @return		A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewLC(const CPBAuthData& aData);

	/**
	 * Creates a new CPBAuthData object from an existing authentication key
	 * by internalizing the authentication data from a read stream.
	 *
	 * @param aStream	The stream to read from
	 * @return			A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewL(RReadStream& aStream);

	/**
	 * Creates a new CPBAuthData object from an existing authentication key
	 * by internalizing the authentication data from a read stream.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aStream	The stream to read from
	 * @return			A pointer to the new CPBAuthData object
	 */
	IMPORT_C static CPBAuthData* NewLC(RReadStream& aStream);

	/**
	 * Gets the authentication key
	 *
	 * @return	The key
	 */
	IMPORT_C TPtrC8 Key() const;

	/**
	 * Gets the salt used for the authentication 
	 *
	 * @return	The salt
	 */
	IMPORT_C TPtrC8 Salt() const;

	/**
	 * Gets the number of iterations of the hashing algorithm.
	 *
	 * @return	The number of iterations
	 */
	IMPORT_C TInt Iterations() const;

	/**
	 * Tests whether two authentication keys are identical 
	 *
	 * @param aAuth	The authentication data object which holds the key to be tested
	 * @return		ETrue, if they are identical; EFalse, otherwise
	 */
	IMPORT_C TBool operator==(const CPBAuthData& aAuth) const;

	/**
	 * Externalizes the encryption parameters into a write stream.
	 *
	 * @param aStream	The stream to write to
	 */
	IMPORT_C void ExternalizeL(RWriteStream& aStream) const;

	/** Destructor */
	virtual ~CPBAuthData(void);
protected:
	/** Constructor */
	IMPORT_C CPBAuthData(void);
private:
	CPBAuthData(const CPBAuthData&);
	CPBAuthData& operator= (const CPBAuthData&);
	};

/** 
 * Represents the information needed to decrypt encrypted data given the correct password.  
 * Contains the authentication key, and the parameters used to derive the encryption key.
 * A CPBEncryptionData object needs to be stored to recover any data for later use.
 *
 * @see CPBEncryptParms
 * @see CPBAuthData
 *
 * @since v7.0s
 */
class CPBEncryptionData : public CBase
	{
public:
	/**
	 * Creates a new CPBEncryptionData object 
	 *
	 * @param aPassword		The user's initial password
	 * @param aCipher		The cipher to use
	 * @param aAuthSalt		The salt used for the authentication
	 * @param aEncryptSalt	The salt used for the encryption
	 * @param aIV			The Initialization Vector
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewL(const TDesC8& aPassword,
		TPBECipher aCipher, const TDesC8& aAuthSalt, 
		const TDesC8& aEncryptSalt, const TDesC8& aIV, TUint aIterations);

	/**
	 * Creates a new CPBEncryptionData object 
	 * and puts a pointer to it onto the cleanup stack.
	 *
	 * @param aPassword		The user's initial password
	 * @param aCipher		The cipher to use
	 * @param aAuthSalt		The salt used for the authentication
	 * @param aEncryptSalt	The salt used for the encryption
	 * @param aIV			The Initialization Vector
	 * @param aIterations	The number of iterations of the PBE algorithm
	 * @return				A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewLC(const TDesC8& aPassword,
		TPBECipher aCipher, const TDesC8& aAuthSalt, 
		const TDesC8& aEncryptSalt, const TDesC8& aIV, TUint aIterations);

	/**
	 * Creates a new CPBEncryptionData from an existing one.
	 *
	 * @param aData	The existing CPBEncryptionData object
	 * @return		A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewL(const CPBEncryptionData& aData);

	/**
	 * Creates a new CPBEncryptionData from an existing one,
	 * and puts a pointer to it onto the cleanup stack.
	 *
	 * @param aData	The existing CPBEncryptionData object
	 * @return		A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewLC(const CPBEncryptionData& aData);

	/**
	 * Internalizes the encryption data from a read stream.
	 *
	 * @param aStream	The stream to read from
	 * @return			A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewL(RReadStream& aStream);

	/**
	 * Internalizes the encryption data from a read stream,
	 * and puts a pointer to it onto the cleanup stack.
	 *
	 * @param aStream	The stream to read from
	 * @return			A pointer to the new CPBEncryptionData object
	 */
	IMPORT_C static CPBEncryptionData* NewLC(RReadStream& aStream);

	/**
	 * Returns the encryption parameter object.
	 *
	 * @return	The CPBEncryptParms object
	 */
	IMPORT_C const CPBEncryptParms& EncryptParms() const;

	/**
	 * Returns the authentication data object.
	 *
	 * @return	The CPBAuthData object
	 */
	IMPORT_C const CPBAuthData& AuthData() const;

	/**
	 * Externalizes the encryption data into a write stream.
	 *
	 * @param aStream	The stream to write to
	 */
	IMPORT_C void ExternalizeL(RWriteStream& aStream) const;

	/** Destructor */
	virtual ~CPBEncryptionData(void);
protected:
	/** Constructor */
	IMPORT_C CPBEncryptionData(void);
private:
	CPBEncryptionData(const CPBEncryptionData&);
	CPBEncryptionData& operator= (const CPBEncryptionData&);
	};


/**
 * Implements the password based encryption of elements.
 *
 * @see CPBEncryptElement
 * @since v7.0s
 */
class CPBEncryptorElement : public CPBEncryptor
	{
public:
	/**
	 * Creates a new CPBEncryptorElement object from the specified cipher, 
	 * key, and Initialization Vector (IV).
	 *
	 * @param aCipher	The encryption cipher
	 * @param aKey		The encryption key
	 * @param aIV		The Initialization Vector
	 * @return			A pointer to the new CPBEncryptorElement object
	 */
	IMPORT_C static CPBEncryptorElement* NewL(TPBECipher aCipher, 
		const TDesC8& aKey, const TDesC8& aIV);

	/**
	 * Creates a new CPBEncryptorElement object from the specified cipher, 
	 * key, and IV.
	 * 
	 * Puts a pointer to the returned object onto the cleanup stack.
	 *
	 * @param aCipher	The encryption cipher
	 * @param aKey		The encryption key
	 * @param aIV		The Initialization Vector
	 * @return			A pointer to the new CPBEncryptorElement object
	 */
	IMPORT_C static CPBEncryptorElement* NewLC(TPBECipher aCipher, 
		const TDesC8& aKey, const TDesC8& aIV);

	/** 
	 * Transforms aInput into its encrypted form, aOutput.
	 *
	 * aOutput must have CPBEncryptorElement::MaxOutputLength() empty bytes remaining in its length. 
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 *
	 * @param aInput	The plaintext.
	 * @param aOutput	The ciphertext.
	 */
	void Process(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Transforms aInput into its encrypted form, aOutput, and applies a
	 * padding scheme to ensure a block aligned result.
	 *
	 * aOutput must have CPBEncryptorElement::MaxFinalOutputLength() 
	 * empty bytes remaining in its length. 
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 * 
	 * @param aInput	The plaintext.
	 * @param aOutput	The ciphertext.
	 */
	void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Gets the maximum size of the output resulting from calling Process() with a
	 * given input length.
	 *
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxOutputLength(TUint aMaxInputLength) const;

	/** 
	 * Gets the maximum size of the output resulting from calling ProcessFinalL()
	 * with a given input length.
	 *
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					TInt The maximum output length in bytes.
	 */
	TInt MaxFinalOutputLength(TUint aMaxInputLength) const;

	/** Destructor */
	virtual ~CPBEncryptorElement();
protected:
	CPBEncryptorElement();

	};

/**
 * Implements the password based decryption of elements.
 *
 * @since v7.0s
 */
class CPBDecryptorElement : public CPBDecryptor
	{
public:
	/**
	 * Creates a new CPBDecryptorElement object from the specified cipher, 
	 * key, and IV.
	 *
	 * @param aCipher	The decryption cipher
	 * @param aKey		The decryption key
	 * @param aIV		The Initialization Vector
	 * @return			A pointer to the new CPBDecryptorElement object
	 */
	IMPORT_C static CPBDecryptorElement* NewL(const TPBECipher aCipher, 
		const TDesC8& aKey, const TDesC8& aIV);
	
	/**
	 * Creates a new CPBDecryptorElement object from the specified cipher, 
	 * key, and IV.
	 * 
	 * Puts a pointer to the returned object onto the cleanup stack.
	 *
	 * @param aCipher	The decryption cipher
	 * @param aKey		The decryption key
	 * @param aIV		The Initialization Vector
	 * @return			A pointer to the new CPBDecryptorElement object
	 */
	IMPORT_C static CPBDecryptorElement* NewLC(const TPBECipher aCipher, 
		const TDesC8& aKey, const TDesC8& aIV);

	/** 
	 * Transforms aInput into its decrypted form, aOutput.
	 *
	 * aOutput must have CPBDecryptorElement::MaxOutputLength() empty bytes
	 * remaining in its length. 
	 *
	 *	See the Cryptography api-guide documentation for an explanation of
	 *	how buffering of data supplied to this function is handled.
	 * 
	 * @param aInput	The ciphertext.
	 * @param aOutput	The plaintext.
	 */
	void Process(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Transforms aInput into its decrypted form, aOutput.
	 *
	 * aOutput must have CPBDecryptorElement::MaxFinalOutputLength() 
	 * empty bytes remaining in its length. 
	 * 
	 * @param aInput	The ciphertext.
	 * @param aOutput	The plaintext.
	 */
	void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxOutputLength(TUint aMaxInputLength) const;

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxFinalOutputLength(TUint aMaxInputLength) const;

	/** Destructor */
	virtual ~CPBDecryptorElement();
protected:
	CPBDecryptorElement();
	};

/**
 * Implements the password based encryption of multiple elements.
 *
 * @see CPBEncryptSet
 * @since v7.0s
 */
class CPBEncryptorSet : public CPBEncryptor
	{
public:
	/**
	 * Creates a new CPBEncryptorSet object from the specified cipher and key,
	 * and a random Initialization Vector (IV).
	 *
	 * @param aCipher	The encryption cipher
	 * @param aKey		The encryption key
	 * @return			A pointer to the new CPBEncryptorSet object
	 */
	IMPORT_C static CPBEncryptorSet* NewL(const TPBECipher aCipher, 
		const TDesC8& aKey);

	/**
	 * Creates a new CPBEncryptorSet object from the specified cipher and key,
	 * and a random IV.
	 * 
	 * Puts a pointer to the returned object onto the cleanup stack.
	 *
	 * @param aCipher	The encryption cipher
	 * @param aKey		The encryption key
	 * @return			A pointer to the new CPBEncryptorSet object
	 */
	IMPORT_C static CPBEncryptorSet* NewLC(const TPBECipher aCipher, 
		const TDesC8& aKey);

	/**
	 * Resets the CPBEncryptorSet object back to its original state
	 * and clears all its buffers.
	 */
	IMPORT_C void Reset(void);

	/** 
	 * Transforms aInput into its encrypted form, aOutput.
	 *
	 * aOutput must have CPBEncryptorSet::MaxOutputLength() empty bytes
	 * remaining in its length. 
	 *
	 * @param aInput	The plaintext.
	 * @param aOutput	The ciphertext.
	 */
	void Process(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Transforms aInput into its encrypted form, aOutput, and applies a
	 * padding scheme to ensure a block aligned result.
	 *
	 * aOutput must have CPBEncryptorSet::MaxFinalOutputLength() 
	 * empty bytes remaining in its length. 
	 * 
	 * @param aInput	The plaintext.
	 * @param aOutput	The ciphertext.
	 */
	void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxOutputLength(TUint aMaxInputLength) const;

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxFinalOutputLength(TUint aMaxInputLength) const;

	/** Destructor */
	virtual ~CPBEncryptorSet();
protected:
	CPBEncryptorSet();	
	};


/**
 * Implements the password based decryption of multiple elements.
 *
 * @since v7.0s
 */
class CPBDecryptorSet : public CPBDecryptor
	{
public:
	/**
	 * Creates a new CPBDecryptorSet object from the specified cipher and key,
	 * and a random IV.
	 *
	 * @param aCipher	The decryption cipher
	 * @param aKey		The decryption key
	 * @return			A pointer to the new CPBDecryptorSet object
	 */
	IMPORT_C static CPBDecryptorSet* NewL(const TPBECipher aCipher, 
		const TDesC8& aKey);

	/**
	 * Creates a new CPBDecryptorSet object from the specified cipher and key,
	 * and a random IV.
	 * 
	 * Puts a pointer to the returned object onto the cleanup stack.
	 *
	 * @param aCipher	The decryption cipher
	 * @param aKey		The decryption key
	 * @return			A pointer to the new CPBDecryptorSet object
	 */
	IMPORT_C static CPBDecryptorSet* NewLC(const TPBECipher aCipher, 
		const TDesC8& aKey);

	/**
	 * Resets the CPBDecryptorSet object back to its original state
	 * and clears all its buffers.
	 */
	IMPORT_C void Reset(void);

	/** 
	 * Transforms aInput into its decrypted form, aOutput.
	 *
	 * aOutput must have CPBDecryptorSet::MaxOutputLength() empty bytes 
	 * remaining in its length. 
	 *
	 * @param aInput	The ciphertext.
	 * @param aOutput	The plaintext.
	 */
	void Process(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Transforms aInput into its decrypted form, aOutput, and applies a
	 * padding scheme to ensure a block aligned result.
	 *
	 * aOutput must have CPBDecryptorSet::MaxFinalOutputLength() 
	 * empty bytes remaining in its length. 
	 * 
	 * @param aInput	The ciphertext.
	 * @param aOutput	The plaintext.
	 */
	void ProcessFinalL(const TDesC8& aInput, TDes8& aOutput);

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxOutputLength(TUint aMaxInputLength) const;

	/** 
	 * Gets the maximum size of the output given a certain input length.
	 * 
	 * @param aMaxInputLength	The maximum input length in bytes.
	 * @return					The maximum output length in bytes.
	 */
	TInt MaxFinalOutputLength(TUint aMaxInputLength) const;

	/** Destructor */
	virtual ~CPBDecryptorSet();
protected:
	CPBDecryptorSet();
	};


/** The number of times the hashing algorithm is run. */
const TUint KDefaultIterations = 1000;

/**
 * A PKCS#5 compliant Key Derivation Function (KDF).
 *
 * This class allows the derivation of deterministic arbitrary length byte 
 * streams from an input string. The output byte stream is generated using 
 * multiple iterations of a CSHA1 message digest and is suitable for use 
 * as a cryptographic symmetric key.
 *
 * @since v7.0s
 */
class TPKCS5KDF
	{
public:
	/** 
	 * Derives deterministic arbitrary length byte streams (aKey) from an input
	 * string (aPasswd) and a randomly chosen salt (aSalt) for use as a
	 * symmetric key.
	 *
	 * Attention -- Improperly chosen values for these parameters will seriously
	 * impact the security of the derived key and as a result the security of 
	 * your application. 
	 *
	 * See the Cryptography api-guide documentation for more information and 
	 * recommended usage patterns.
	 * 
	 * @param aKey			Output Value. The key resulting from the operation.
	 * 						The length of the key will be equal to the length of
	 * 						the input descriptor. All data, from the first byte 
	 * 						to the set length, will be overwritten with the resulting
	 *						byte stream.
	 * @param aPasswd		Input Value. The password you wish to derive a key from.
	 * @param aSalt			Input Value. A <B><I>randomly</I></B> selected second
	 * 						input to the key derivation function to discourage certain
	 * 						attacks. PKCS5 recommends a minimum of 8 randomly chosen bytes.
	 * @param aIterations	Input Value. The number of times the internal hashing
	 * 						function should be run over the password and salt.
	 *						Minimum recommendation is @ref KDefaultIterations.
	 */
	IMPORT_C static void DeriveKeyL(TDes8& aKey, const TDesC8& aPasswd, 
		const TDesC8& aSalt, TUint aIterations = KDefaultIterations);

	};

#endif
