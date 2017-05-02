//
// Copyright (C) 2003-2007 Symbian Software Ltd.  All rights reserved.
//	You are free to copy and distribute these materials
//	You must not modify or adapt these materials
//	You must not include any parts of these materials in any other program whose source code is available for inspection by members of the public 
//	These materials otherwise remain the copyright works of Symbian Software Limited and supplied on an ‘as is’ basis
//	These materials make use of cryptography and may be subject to export, import and/or use control laws in your country. You should investigate whether government approval is required before accepting these terms
//  Symbian Software Limited accepts no responsibility for any access to, use of, transfer and/or export of these materials by you that is or may be contrary to applicable laws


/**  
* @file
* @publishedAll
* @released 
*/

#ifndef __CRYPTOASYMMETRIC_H__
#define __CRYPTOASYMMETRIC_H__

#include <e32base.h>
#include <cryptopadding.h>
#include <random.h>
#include <hash.h>
#include <cryptobasic.h>


/** 
* Defines the various ways of representing supported RSA private keys.
* 
*/
enum TRSAPrivateKeyType 
	{
	/** 
	 * Standard type of RSA private key
	 * 
	 * This consists of the modulus (n) and decryption exponent (d).
	 */
	EStandard,
	/** 
	 * CRT (Chinese Remainder Theorem) type of RSA private key
	 *
	 * This consists of the the first factor (p), the second factor (q), 
	 * the first factor's CRT exponent (dP), the second factor's CRT exponent (dQ),
	 * and the (first) CRT coefficient (qInv). The two factors, p and q, are the
	 * first two prime factors of the RSA modulus, n.
	 */
	EStandardCRT
	//We may support types like this in the future (currently these are a patent
	//minefield):
	//EMulti, //multi prime version of EStandard
	//EMultiCRT //multi prime version of EStandardCRT
	};

/** 
* Concrete class representing the parameters common to both an RSA public and
* private key.
* 
* See ANSI X9.31 and RSA PKCS#1
*
*/
class CRSAParameters : public CBase
	{
public:
	/** 
	 * Gets the RSA parameter, n (the modulus)
	 *
	 * @return	The RSA parameter, n
	 */
	IMPORT_C const TInteger& N(void) const;
	
	/** Destructor */
	IMPORT_C virtual ~CRSAParameters(void);
protected:
	/** 
	 * Constructor 
	 *
	 * @param aN	The RSA parameter, n (the modulus)
	 */
	IMPORT_C CRSAParameters(RInteger& aN);
	
	/** Default constructor */
	IMPORT_C CRSAParameters(void);
protected:
	/** The RSA modulus, n, a positive integer */
	RInteger iN;
	};

/** 
* Representation of an RSA public key.  
* 
* An RSA public key is identified by its modulus (n) and its encryption exponent
* (e).
* 
*/
class CRSAPublicKey : public CRSAParameters
	{
public:
	/**
	 * Creates a new CRSAPublicKey object from a specified 
	 * modulus and encryption exponent.
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aE	The RSA parameter, e (the encryption exponent)
	 * @return		A pointer to a new CRSAPublicKey object
	 *
	 * @leave KErrArgument	If either aN or aE are not positive integers,
	 *						and releases ownership. 
	 */
	IMPORT_C static CRSAPublicKey* NewL(RInteger& aN, RInteger& aE);

	/**
	 * Creates a new CRSAPublicKey object from a specified 
	 * modulus and encryption exponent.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aE	The RSA parameter, e (the encryption exponent)
	 * @return		A pointer to a new CRSAPublicKey object
	 * 
	 * @leave KErrArgument	If either aN or aE are not positive integers,
	 *	 					and releases ownership. 
	 */
	IMPORT_C static CRSAPublicKey* NewLC(RInteger& aN, RInteger& aE);

	/** 
	 * Gets the RSA parameter, e (the encryption exponent)
	 *
	 * @return	The RSA parameter, e
	 */
	IMPORT_C const TInteger& E(void) const;
	
	/** Destructor */
	IMPORT_C virtual ~CRSAPublicKey(void);
protected:
	/**
	 * Constructor 
	 *
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aE	The RSA parameter, e (the encryption exponent)
	 */	
	IMPORT_C CRSAPublicKey(RInteger& aN, RInteger& aE);
	
	/** Default constructor */
	IMPORT_C CRSAPublicKey(void);
protected:
	/** The RSA encryption exponent, e */
	RInteger iE;
	};

/** 
* Non-exported container class for the various ways of representing an RSA
* private key.
*
* To instantiate a representation of an RSA private key, find a
* subclass of this appropriate to your key type.  
*
*/
class CRSAPrivateKey : public CRSAParameters
	{
public:
	/**
	 * Gets the type of RSA private key
	 *
	 * @return	The RSA private key type
	 */
	inline const TRSAPrivateKeyType PrivateKeyType() const {return (iKeyType);};
protected:
	/** The type of the RSA private key */
	const TRSAPrivateKeyType iKeyType;
private:
	CRSAPrivateKey(const CRSAPrivateKey&);
	CRSAPrivateKey& operator=(const CRSAPrivateKey&);
	};

/** 
* The 'classical' representation of a RSA private key.
* 
* Such a private key is composed of a modulus (n) and a decryption exponent (d).
*   
*/
class CRSAPrivateKeyStandard : public CRSAPrivateKey
	{
public:
	/**
	 * Creates a new CRSAPrivateKeyStandard object from a specified 
	 * modulus and decryption exponent.
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aD	The RSA parameter, d (the decryption exponent)
	 * @return		A pointer to a new CRSAPrivateKeyStandard object
	 * 
	 * @leave KErrArgument	If either aN or aD are not positive integers,
	 *	 					and releases ownership. 
	 */
	IMPORT_C static CRSAPrivateKeyStandard* NewL(RInteger& aN, RInteger& aD);

	/**
	 * Creates a new CRSAPrivateKeyStandard object from a specified 
	 * modulus and decryption exponent.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aD	The RSA parameter, d (the decryption exponent)
	 * @return		A pointer to a new CRSAPrivateKeyStandard object
	 * 
	 * @leave KErrArgument	If either aN or aD are not positive integers,
	 *	 					and releases ownership. 
	 */
	IMPORT_C static CRSAPrivateKeyStandard* NewLC(RInteger& aN, RInteger& aD);

	/** 
	 * Gets the RSA parameter, d (the decryption exponent)
	 *
	 * @return	The RSA parameter, d
	 */
	IMPORT_C const TInteger& D(void) const;

	/** Destructor */
	IMPORT_C virtual ~CRSAPrivateKeyStandard(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aD	The RSA parameter, d (the decryption exponent)
	 */	 
	IMPORT_C CRSAPrivateKeyStandard(RInteger& aN, RInteger& aD);
protected:
	/** The RSA decryption exponent, d */
	RInteger iD;
private:
	CRSAPrivateKeyStandard(const CRSAPrivateKeyStandard&);
	CRSAPrivateKeyStandard& operator=(const CRSAPrivateKeyStandard&);
	};

/** 
* An alternate representation of an RSA private key providing significant
* speed enhancements through its use of the Chinese Remainder Theorem (CRT).
*
* Here, a private key is represented by a modulus (n), the two prime factors of
* the modulus (p, q), p's CRT exponent (dP), q's CRT exponent (dQ), and the CRT
* coefficient (qInv).  See PKCS#1 at http://www.rsasecurity.com/rsalabs/pkcs/
* for more information.
*
*/
class CRSAPrivateKeyCRT : public CRSAPrivateKey
	{
public:
	/**
	 * Creates a new CRSAPrivateKeyCRT object from a specified 
	 * modulus and decryption exponent.
	 * 
	 * @param iN	The RSA parameter, n (the modulus)
	 * @param aP	The RSA parameter, p (the first factor)
	 * @param aQ	The RSA parameter, q (the second factor)
	 * @param aDP	The RSA parameter, dP (the first factor's CRT exponent)
	 * @param aDQ	The RSA parameter, dQ (the second factor's CRT exponent)
	 * @param aQInv	The RSA parameter, qInv (the CRT coefficient)
	 * @return		A pointer to a new CRSAPrivateKeyCRT object
	 * 
	 * @leave KErrArgument	If any of the parameters are not positive integers,
	 *	 					and releases ownership. 
	 */
	IMPORT_C static CRSAPrivateKeyCRT* NewL(RInteger& iN, RInteger& aP, 
		RInteger& aQ, RInteger& aDP, RInteger& aDQ, RInteger& aQInv);

	/**
	 * Creates a new CRSAPrivateKeyCRT object from a specified 
	 * modulus and decryption exponent.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param iN	The RSA parameter, n (the modulus)
	 * @param aP	The RSA parameter, p (the first factor)
	 * @param aQ	The RSA parameter, q (the second factor)
	 * @param aDP	The RSA parameter, dP (the first factor's CRT exponent)
	 * @param aDQ	The RSA parameter, dQ (the second factor's CRT exponent)
	 * @param aQInv	The RSA parameter, qInv (the CRT coefficient)
	 * @return		A pointer to a new CRSAPrivateKeyCRT object
	 * 
	 * @leave KErrArgument	If any of the parameters are not positive integers,
	 *	 					and releases ownership. 
	 */
	IMPORT_C static CRSAPrivateKeyCRT* NewLC(RInteger& iN, RInteger& aP, 
		RInteger& aQ, RInteger& aDP, RInteger& aDQ, RInteger& aQInv);

	/** Destructor */
	IMPORT_C virtual ~CRSAPrivateKeyCRT(void);
	
	/**
	 * Gets the RSA parameter, p (the first factor) 
	 *
	 * @return	The first factor
	 */
	IMPORT_C const TInteger& P(void) const;
	
	/**
	 * Gets the RSA parameter, q (the second factor) 
	 *
	 * @return	The second factor
	 */
	IMPORT_C const TInteger& Q(void) const;
	
	/**
	 * Gets the RSA parameter, dP (the first factor's CRT exponent) 
	 *
	 * @return	The first factor's CRT exponent
	 */
	IMPORT_C const TInteger& DP(void) const;
	
	/**
	 * Gets the RSA parameter, dQ (the second factor's CRT exponent) 
	 *
	 * @return	The second factor's CRT exponent
	 */
	IMPORT_C const TInteger& DQ(void) const;
	
	/**
	 * Gets the RSA parameter, qInv (the CRT coefficient) 
	 *
	 * @return	The CRT coefficient
	 */
	IMPORT_C const TInteger& QInv(void) const;
protected:
	/**
	 * Constructor
	 * 
	 * @param aN	The RSA parameter, n (the modulus)
	 * @param aP	The RSA parameter, p (the first factor)
	 * @param aQ	The RSA parameter, q (the second factor)
	 * @param aDP	The RSA parameter, dP (the first factor's CRT exponent)
	 * @param aDQ	The RSA parameter, dQ (the second factor's CRT exponent)
	 * @param aQInv	The RSA parameter, qInv (the CRT coefficient)
	 */
	IMPORT_C CRSAPrivateKeyCRT(RInteger& aN, RInteger& aP, RInteger& aQ, 
		RInteger& aDP, RInteger& aDQ, RInteger& aQInv);
protected:
	/** The RSA parameter, p, which is the first factor */
	RInteger iP;
	/** The RSA parameter, q, which is the second factor */
	RInteger iQ;
	/** The RSA parameter, dP, which is the first factor's CRT exponent */
	RInteger iDP;
	/** The RSA parameter, dQ, which is the second factor's CRT exponent */
	RInteger iDQ;
	/** The RSA parameter, qInv, which is the CRT coefficient */
	RInteger iQInv;
private:
	CRSAPrivateKeyCRT(const CRSAPrivateKeyCRT&);
	CRSAPrivateKeyCRT& operator=(const CRSAPrivateKeyCRT&);
	};

/** 
* This class is capable of generating an RSA public/private key pair.
*
* By default, it generates 2 prime (standard) CRT private keys.
*
*/
class CRSAKeyPair : public CBase
	{
public:
	/**
	 * Creates a new RSA key pair
	 * 
	 * @param aModulusBits	The length of the modulus, n (in bits)
	 * @param aKeyType		The type of the RSA key
	 * @return				A pointer to a new CRSAKeyPair object
	 * 
	 * @leave KErrNotSupported	If the type of RSA key is not supported
	 */
	IMPORT_C static CRSAKeyPair* NewL(TUint aModulusBits, 
		TRSAPrivateKeyType aKeyType = EStandardCRT);

	/**
	 * Creates a new RSA key pair
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aModulusBits	The length of the modulus, n (in bits)
	 * @param aKeyType		The type of the RSA key
	 * @return				A pointer to a new CRSAKeyPair object
	 * 
	 * @leave KErrNotSupported	If the type of RSA key is not supported
	 */
	IMPORT_C static CRSAKeyPair* NewLC(TUint aModulusBits, 
		TRSAPrivateKeyType aKeyType = EStandardCRT);
	
	/** 
	 * Gets the RSA public key
	 *
	 * @return	A CRSAPublicKey object
	 */
	IMPORT_C const CRSAPublicKey& PublicKey(void) const;
	
	/** 
	 * Gets the RSA private key
	 *
	 * @return	A CRSAPrivateKey object
	 */
	IMPORT_C const CRSAPrivateKey& PrivateKey(void) const;
	
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CRSAKeyPair(void);
protected:
	/** Default constructor */
	IMPORT_C CRSAKeyPair(void);
protected:
	/** The RSA public key */
	CRSAPublicKey* iPublic;
	/** The RSA private key */
	CRSAPrivateKey* iPrivate;
private:
	CRSAKeyPair(const CRSAKeyPair&);
	CRSAKeyPair& operator=(const CRSAKeyPair&);
	};

/** 
* Representation of the parameters used to generate the primes in a
* CDSAParameters object.
* 
* Given such a certificate, one can ensure that the DSA
* primes contained in CDSAParameters were generated correctly.
* 
* @see CDSAParameters::ValidatePrimesL() 
* 
*/
class CDSAPrimeCertificate : public CBase
	{
public:
	/** 
	 * Creates a new DSA prime certificate from a specified 
	 * seed and counter value.
	 * 
	 * @param aSeed		The seed from a DSA key generation process
	 * @param aCounter	The counter value from a DSA key generation process
	 * @return			A pointer to a new CDSAPrimeCertificate object
	 */
	IMPORT_C static CDSAPrimeCertificate* NewL(const TDesC8& aSeed, 
		TUint aCounter);

	/** 
	 * Creates a new DSA prime certificate from a specified 
	 * seed and counter value.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aSeed		The seed from a DSA key generation process
	 * @param aCounter	The counter value from a DSA key generation process
	 * @return			A pointer to a new CDSAPrimeCertificate object
	 */
	IMPORT_C static CDSAPrimeCertificate* NewLC(const TDesC8& aSeed,
		TUint aCounter);

	/**
	 * Gets the seed of the DSA prime certificate
	 *
	 * @return	The seed
	 */ 
	IMPORT_C const TDesC8& Seed(void) const;
	
	/**
	 * Gets the counter value of the DSA prime certificate
	 *
	 * @return	The counter's value
	 */
	IMPORT_C TUint Counter(void) const;
	
	/** Destructor */
	IMPORT_C virtual ~CDSAPrimeCertificate(void);
protected:
	/** 
	 * Constructor 
	 *
	 * @param aCounter	The DSA key generation counter
	 */
	IMPORT_C CDSAPrimeCertificate(TUint aCounter);

	/** Default constructor */
	IMPORT_C CDSAPrimeCertificate(void);
	
protected:
	/** The DSA key generation seed */
	const HBufC8* iSeed;
	/** The DSA key generation counter */
	TUint iCounter;
private:
	CDSAPrimeCertificate(const CDSAPrimeCertificate&);
	CDSAPrimeCertificate& operator=(const CDSAPrimeCertificate&);
	};

/** 
* Concrete class representing the parameters common to both a DSA public and
* private key. 
*
* See FIPS 186-2, Digital Signature Standard
* 
*/
class CDSAParameters : public CBase
	{
public:
	/**
	 * Gets the DSA parameter, p (the prime)
	 * 
	 * @return	The DSA parameter, p
	 */
	IMPORT_C const TInteger& P(void) const;

	/**
	 * Gets the DSA parameter, q (the subprime)
	 * 
	 * @return	The DSA parameter, q
	 */
	IMPORT_C const TInteger& Q(void) const;

	/**
	 * Gets the DSA parameter, g (the base)
	 * 
	 * @return	The DSA parameter, g
	 */
	IMPORT_C const TInteger& G(void) const;

	/**
	 * Validates the primes regenerated from a DSA prime certificate 
	 *
	 * @param aCert	The DSA prime certificate that contains the seed and 
	 *				counter value from a DSA key generation process
	 * @return		Whether or not the primes are valid	
	 */
	IMPORT_C TBool ValidatePrimesL(const CDSAPrimeCertificate& aCert) const;

	/** 
	 * Whether or not the prime is of a valid length 
	 * 
	 * It is valid if the length of the prime modulus is between KMinPrimeLength
	 * and KMaxPrimeLength bits, and the prime is a multiple of KPrimeLengthMultiple. 
	 *
	 * @param aPrimeBits	The prime modulus
	 * @return				ETrue, if within the constraints; EFalse, otherwise.
	 */
	IMPORT_C static TBool ValidPrimeLength(TUint aPrimeBits);
	
	/** Destructor */
	IMPORT_C virtual ~CDSAParameters(void);

	/** 
	 * Creates a new DSA parameters object from a specified 
	 * prime, subprime, and base.
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, g (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @return		A pointer to a new CDSAParameters object
	 */
	IMPORT_C static CDSAParameters* NewL(RInteger& aP, RInteger& aQ, 
		RInteger& aG);

protected:
	/** 
	 * Constructor
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, g (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 */
	IMPORT_C CDSAParameters(RInteger& aP, RInteger& aQ, RInteger& aG);
	
	/** Default constructor */
	IMPORT_C CDSAParameters(void);
protected:
	/** 
	 * The DSA parameter, p (the prime).
	 * 
	 * A prime modulus whose length is between KMinPrimeLength and KMaxPrimeLength bits,
	 * and is a multiple of KPrimeLengthMultiple. 
	 */
	RInteger iP;
	
	/** 
	 * The DSA parameter, q (the subprime)
	 * 
	 * This is a 160-bit prime divisor of <code>p-1</code>. 
	 */
	RInteger iQ;
	
	/** 
	 * The DSA parameter, g (the base)
	 * 
	 * <code>g = h^((p-1)/q) mod p</code>,
	 * 
	 * where h is any integer less than <code>p-1</code> such that <code>g &gt; 1</code> 
	 */
	RInteger iG;
private:
	CDSAParameters(const CDSAParameters&);
	CDSAParameters& operator=(const CDSAParameters&);
	};

/**
* Representation of a DSA public key.  
*
*/
class CDSAPublicKey : public CDSAParameters
	{
public:
	/** 
	 * Creates a new DSA public key object from a specified
	 * primes, base, and public key. 
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aY	The DSA parameter, y (the public key)
	 * @return		A pointer to a new CDSAPublicKey object
	 */
	IMPORT_C static CDSAPublicKey* NewL(RInteger& aP, RInteger& aQ, 
		RInteger& aG, RInteger& aY);

	/** 
	 * Creates a new DSA public key object from a specified
	 * primes, base, and public key. 
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aY	The DSA parameter, y (the public key)
	 * @return		A pointer to a new CDSAPublicKey object
	 */
	IMPORT_C static CDSAPublicKey* NewLC(RInteger& aP, RInteger& aQ, 
		RInteger& aG, RInteger& aY);

	/**
	 * Gets the DSA parameter, y (the public key)
	 *
	 * @return	The DSA parameter, y
	 */
	IMPORT_C const TInteger& Y(void) const;

	/** Destructor */
	IMPORT_C virtual ~CDSAPublicKey(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aY	The DSA parameter, y (the public key)
	 */
	IMPORT_C CDSAPublicKey(RInteger& aP, RInteger& aQ, RInteger& aG, 
		RInteger& aY);
	
	/** Default constructor */
	IMPORT_C CDSAPublicKey(void);
protected:
	/** 
	 * The DSA parameter, y, which is the public key 
	 *
	 * <code>y = g^x mod p</code>
	 */
	RInteger iY;
private:
	CDSAPublicKey(const CDSAPublicKey&);
	CDSAPublicKey& operator=(const CDSAPublicKey&);
	};

/** 
* Representation of a DSA private key.  
* 
*/
class CDSAPrivateKey : public CDSAParameters
	{
public:
	/** 
	 * Creates a new DSA private key object from a specified
	 * primes, base, and private key. 
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aX	The DSA parameter, x (the private key)
	 * @return		A pointer to a new CDSAPrivateKey object
	 */
	IMPORT_C static CDSAPrivateKey* NewL(RInteger& aP, RInteger& aQ, 
		RInteger& aG, RInteger& aX);

	/** 
	 * Creates a new DSA private key object from a specified
	 * primes, base, and private key. 
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aX	The DSA parameter, x (the private key)
	 * @return		A pointer to a new CDSAPrivateKey object
	 */
	IMPORT_C static CDSAPrivateKey* NewLC(RInteger& aP, RInteger& aQ, 
		RInteger& aG, RInteger& aX);

	/**
	 * Gets the DSA parameter, x (the private key)
	 *
	 * @return	The DSA parameter, x
	 */
	IMPORT_C const TInteger& X(void) const;

	/** Destructor */
	IMPORT_C virtual ~CDSAPrivateKey(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aP	The DSA parameter, p (the prime)
	 * @param aQ	The DSA parameter, q (the subprime)
	 * @param aG	The DSA parameter, g (the base)
	 * @param aX	The DSA parameter, x (the private key)
	 */
	IMPORT_C CDSAPrivateKey(RInteger& aP, RInteger& aQ, RInteger& aG, 
		RInteger& aX);
		
	/** Default constructor */
	IMPORT_C CDSAPrivateKey(void);
protected:
	/** 
	 * The DSA parameter, x, which is the private key 
	 *
	 * A pseudorandomly generated integer whose value is between 0 and q.
	*/
	RInteger iX;
private:
	CDSAPrivateKey(const CDSAPrivateKey&);
	CDSAPrivateKey& operator=(const CDSAPrivateKey&);
	};

/** 
* This class is capable of generating a DSA public/private key pair.
* 
*/
class CDSAKeyPair : public CBase
	{
public:
	/** 
	 * Creates a new DSA key pair and also a DSA prime certificate
	 * 
	 * @param aSize	The length (in bits) of the DSA parameter, p (the prime)
	 * @return		A pointer to a new CDSAKeyPair object
	 */
	IMPORT_C static CDSAKeyPair* NewL(TUint aSize);

	/** 
	 * Creates a new DSA key pair and also a DSA prime certificate
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aSize	The length (in bits) of the DSA parameter, p (the prime)
	 * @return		A pointer to a new CDSAKeyPair object
	 */
	IMPORT_C static CDSAKeyPair* NewLC(TUint aSize);
	
	/** 
	 * Gets the DSA public key
	 *
	 * @return	The DSA public key object
	 */
	IMPORT_C const CDSAPublicKey& PublicKey(void) const;
	
	/** 
	 * Gets the DSA private key
	 *
	 * @return	The DSA private key object
	 */
	IMPORT_C const CDSAPrivateKey& PrivateKey(void) const;
	
	/** 
	 * Gets the DSA prime certificate (i.e., the seed and counter)
	 *
	 * @return	The DSA prime certificate object
	 */
	IMPORT_C const CDSAPrimeCertificate& PrimeCertificate(void) const;
	
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CDSAKeyPair(void);
protected:
	/** Default constructor */
	IMPORT_C CDSAKeyPair(void);
protected:
	/** The DSA public key */
	CDSAPublicKey* iPublic;
	/** The DSA private key */
	CDSAPrivateKey* iPrivate;
	/** The DSA prime certificate */
	CDSAPrimeCertificate* iPrimeCertificate;
private:
	CDSAKeyPair(const CDSAKeyPair&);
	CDSAKeyPair& operator=(const CDSAKeyPair&);
	};

/** 
* Concrete class representing the parameters common to both 
* a Diffie-Hellman (DH) public and private key.  
* 
*/
class CDHParameters : public CBase
	{
public:
	/**
	 * Gets the DH parameter, n
	 *
	 * @return	An integer representing the DH parameter, n
	 */
	IMPORT_C const TInteger& N(void) const;

	/**
	 * Gets the DH parameter, g
	 *
	 * @return	An integer representing the DH parameter, g
	 */
	IMPORT_C const TInteger& G(void) const;
	
	/** Destructor */
	IMPORT_C virtual ~CDHParameters(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aN	The DH parameter, n
	 * @param aG	The DH parameter, g
	 */
	IMPORT_C CDHParameters(RInteger& aN, RInteger& aG);
	
	/** Default constructor */
	IMPORT_C CDHParameters(void);
protected:
	/**
	 * The DH parameter, n (a prime number)
	 * 
	 * <code>X = g^x mod n</code> (note the case sensitivity)
	 */
	RInteger iN;
	/** 
	 * The DH parameter, g (the generator) 
	 *
	 * <code>X = g^x mod n</code> (note the case sensitivity)
	 */
	RInteger iG;
private:
	CDHParameters(const CDHParameters&);
	CDHParameters& operator=(const CDHParameters&);
	};

/** 
* Representation of a Diffie-Hellman (DH) public key.  
* 
*/
class CDHPublicKey : public CDHParameters
	{
public:
	/** 
	 * Creates a new DH public key from a specified 
	 * large prime, generator, and random large integer.
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param aX	The DH value, X
	 * @return		A pointer to a new CDHPublicKey object
	 */
	IMPORT_C static CDHPublicKey* NewL(RInteger& aN, RInteger& aG, 
		RInteger& aX);

	/** 
	 * Creates a new DH public key from a specified 
	 * large prime, generator, and random large integer.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param aX	The DH value, X
	 * @return		A pointer to a new CDHPublicKey object
	 */
	IMPORT_C static CDHPublicKey* NewLC(RInteger& aN, RInteger& aG, 
		RInteger& aX);
	
	/** 
	 * Gets the DH value, X
	 * 
	 * @return	The DH value, X
	 */	
	IMPORT_C const TInteger& X(void) const;

	/** Destructor */
	IMPORT_C virtual ~CDHPublicKey(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param aX	The DH value, X
	 */
	IMPORT_C CDHPublicKey(RInteger& aN, RInteger& aG, RInteger& aX);

	/** Constructor */
	IMPORT_C CDHPublicKey(void);
protected:
	/** 
	 * The DH value, X
	 *
	 * <code>X = g^x mod n</code> (note the case sensitivity)
	 */
	RInteger iX;
private:
	CDHPublicKey(const CDHPublicKey&);
	CDHPublicKey& operator=(const CDHPublicKey&);
	};

/** 
* Representation of a Diffie-Hellman (DH) private key.  
* 
*/
class CDHPrivateKey : public CDHParameters
	{
public:
	/** 
	 * Creates a new DH private key from a specified 
	 * large prime, generator, and random large integer.
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 * @return		A pointer to a new CDHPrivateKey object
	 */
	IMPORT_C static CDHPrivateKey* NewL(RInteger& aN, RInteger& aG, 
		RInteger& ax);

	/** 
	 * Creates a new DH private key from a specified 
	 * large prime, generator, and random large integer.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 * @return		A pointer to a new CDHPrivateKey object
	 */
	IMPORT_C static CDHPrivateKey* NewLC(RInteger& aN, RInteger& aG, 
		RInteger& ax);
	
	/** 
	 * Gets the DH value, x, which is a random large integer.
	 * 
	 * @return	The DH value, x
	 */	
	IMPORT_C const TInteger& x(void) const;
	
	/** Destructor */
	IMPORT_C virtual ~CDHPrivateKey(void);
protected:
	/** 
	 * Constructor
	 * 
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 */
	IMPORT_C CDHPrivateKey(RInteger& aN, RInteger& aG, RInteger& ax);
	
	/** Constructor */
	IMPORT_C CDHPrivateKey(void);
protected:
	/** 
	 * The DH value, x, which is a random large integer.
	 *
	 * <code>X = g^x mod n</code> (note the case sensitivity)
	 */
	RInteger ix;
private:
	CDHPrivateKey(const CDHPrivateKey&);
	CDHPrivateKey& operator=(const CDHPrivateKey&);
	};

/** 
* This class is capable of generating a Diffie-Hellman (DH) public/private key pair.
* 
*/
class CDHKeyPair : public CBase
	{
public:
	/**
	 * Creates a new DH key pair from a random large integer,
	 * and a specified large prime and generator.
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @return		A pointer to a new CDHKeyPair object
	 * 
	 * @leave KErrArgument	If aG is out of bounds 
	 */
	IMPORT_C static CDHKeyPair* NewL(RInteger& aN, RInteger& aG);

	/**
	 * Creates a new DH key pair from a random large integer,
	 * and a specified large prime and generator.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @return		A pointer to a new CDHKeyPair object
	 * 
	 * @leave KErrArgument	If aG is out of bounds 
	 */
	IMPORT_C static CDHKeyPair* NewLC(RInteger& aN, RInteger& aG);

	/**
	 * Creates a new DH key pair from a specified 
	 * large prime, generator, and random large integer.
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 * @return		A pointer to a new CDHKeyPair object
	 * 
	 * @leave KErrArgument	If either aG or ax are out of bounds 
	 */
	IMPORT_C static CDHKeyPair* NewL(RInteger& aN, RInteger& aG, RInteger& ax);

	/**
	 * Creates a new DH key pair from a specified 
	 * large prime, generator, and random large integer.
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 * @return		A pointer to a new CDHKeyPair object
	 * 
	 * @leave KErrArgument	If either aG or ax are out of bounds 
	 */
	IMPORT_C static CDHKeyPair* NewLC(RInteger& aN, RInteger& aG, RInteger& ax);

	/**
	 * Gets the DH public key
	 *
	 * @return	The DH public key
	 */
	IMPORT_C const CDHPublicKey& PublicKey(void) const;

	/**
	 * Gets the DH private key
	 *
	 * @return	The DH private key
	 */
	IMPORT_C const CDHPrivateKey& PrivateKey(void) const;
	
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CDHKeyPair(void);
protected:
	/** Default constructor */
	IMPORT_C CDHKeyPair(void);
	
	/** 
	 * Constructor
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 */
	IMPORT_C void ConstructL(RInteger& aN, RInteger& aG);

	/** 
	 * Constructor
	 *
	 * @param aN	The DH parameter, n (a large prime)
	 * @param aG	The DH parameter, g (the generator)
	 * @param ax	The DH value, x (a random large integer)
	 */
	IMPORT_C void ConstructL(RInteger& aN, RInteger& aG, RInteger& ax);
protected:	
	/** The DH public key */
	CDHPublicKey* iPublic;
	/** The DH private key */
	CDHPrivateKey* iPrivate;
private:
	CDHKeyPair(const CDHKeyPair&);
	CDHKeyPair& operator=(const CDHKeyPair&);
	};


// All the classes in this file have their default constructors and
// assignment operators defined private, but not implemented, in order to
// prevent their use.

/** 
* Mixin class defining common operations for public key encryption and
* decryption classes.
* 
*/
class MCryptoSystem 
	{
public:
	/**
	 * Gets the maximum size of input accepted by this object.
	 *	
	 * @return	The maximum input length allowed in bytes.
	 */	 
	virtual TInt MaxInputLength(void) const = 0;
	
	/**
	 * Gets the maximum size of output that can be generated by this object.
	 *
	 * @return	The maximum output length in bytes.
	 */	 
	virtual TInt MaxOutputLength(void) const = 0;
protected:
	/**
	 * Constructor
 	 */	 
	IMPORT_C MCryptoSystem(void);
private:
	MCryptoSystem(const MCryptoSystem&);
	MCryptoSystem& operator=(const MCryptoSystem&);
	};

/** 
* Abstract base class for all public key encryptors.
* 
*/
class CEncryptor : public CBase, public MCryptoSystem
	{
public:
	/**
	 * Encrypts the specified plaintext into ciphertext.
	 * 
	 * @param aInput	The plaintext
	 * @param aOutput	On return, the ciphertext
	 *
	 * @panic KCryptoPanic	If the input data is too long.
	 *						See ECryptoPanicInputTooLarge
	 * @panic KCryptoPanic	If the supplied output descriptor is not large enough to store the result.
	 *						See ECryptoPanicOutputDescriptorOverflow
	 */	 
	virtual void EncryptL(const TDesC8& aInput, TDes8& aOutput) const = 0;
protected:
	/** Default constructor */	 
	IMPORT_C CEncryptor(void);
private:
	CEncryptor(const CEncryptor&);
	CEncryptor& operator=(const CEncryptor&);
	};

/** 
* Abstract base class for all public key decryptors.
* 
*/
class CDecryptor : public CBase, public MCryptoSystem
	{
public:
	/**
	 * Decrypts the specified ciphertext into plaintext
	 *
	 * @param aInput	The ciphertext to be decrypted
	 * @param aOutput	On return, the plaintext
	 *
	 * @panic KCryptoPanic		If the input data is too long.
	 *							See ECryptoPanicInputTooLarge
	 * @panic KCryptoPanic		If the supplied output descriptor is not large enough to store the result.
	 *							See ECryptoPanicOutputDescriptorOverflow
	 */	 
	virtual void DecryptL(const TDesC8& aInput, TDes8& aOutput) const = 0;
protected:
	/** Default constructor */	 
	IMPORT_C CDecryptor(void);
private:
	CDecryptor(const CDecryptor&);
	CDecryptor& operator=(const CDecryptor&);
	};

/**
* Implementation of RSA encryption as described in PKCS#1 v1.5.
* 
*/
class CRSAPKCS1v15Encryptor : public CEncryptor
	{
public:
	/**
	 * Creates a new RSA encryptor object using PKCS#1 v1.5 padding.
	 * 
	 * @param aKey	The RSA encryption key
	 * @return		A pointer to a new CRSAPKCS1v15Encryptor object
	 *
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 *								See TCrypto::IsAsymmetricWeakEnoughL()
	 * @leave KErrKeySize			If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Encryptor* NewL(const CRSAPublicKey& aKey);

	/**
	 * Creates a new RSA encryptor object using PKCS#1 v1.5 padding.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The RSA encryption key
	 * @return		A pointer to a new CRSAPKCS1v15Encryptor object
	 *
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 *								See TCrypto::IsAsymmetricWeakEnoughL()
	 * @leave KErrKeySize			If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Encryptor* NewLC(const CRSAPublicKey& aKey);
	void EncryptL(const TDesC8& aInput, TDes8& aOutput) const;
	TInt MaxInputLength(void) const;
	TInt MaxOutputLength(void) const;
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	virtual ~CRSAPKCS1v15Encryptor(void);
protected:
	/** @internalAll */
	CRSAPKCS1v15Encryptor(const CRSAPublicKey& aKey);	
private:
	CRSAPKCS1v15Encryptor(const CRSAPKCS1v15Encryptor&);
	CRSAPKCS1v15Encryptor& operator=(const CRSAPKCS1v15Encryptor&);
	};

/** 
* Implementation of RSA decryption as described in PKCS#1 v1.5.
*
*/
class CRSAPKCS1v15Decryptor : public CDecryptor
	{
public:
	/**
	 * Creates a new RSA decryptor object using PKCS#1 v1.5 padding.
	 *
	 * @param aKey	The RSA private key for decryption
	 *
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 * 								See TCrypto::IsAsymmetricWeakEnoughL()
	 * @leave KErrKeySize			If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Decryptor* NewL(const CRSAPrivateKey& aKey);
	
	/**
	 * Creates a new RSA decryptor object using PKCS#1 v1.5 padding
	 *
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The RSA private key for decryption
	 *
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 * 								See TCrypto::IsAsymmetricWeakEnoughL()
	 * @leave KErrKeySize			If the key length is too small
	 * @leave KErrNotSupported	    If the RSA private key is not a supported TRSAPrivateKeyType
	 */
	IMPORT_C static CRSAPKCS1v15Decryptor* NewLC(const CRSAPrivateKey& aKey);
	void DecryptL(const TDesC8& aInput, TDes8& aOutput) const;
	TInt MaxInputLength(void) const;
	TInt MaxOutputLength(void) const;
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	virtual ~CRSAPKCS1v15Decryptor(void);
protected:
	/** @internalAll */
	CRSAPKCS1v15Decryptor(const CRSAPrivateKey& aKey);
	
private:
	CRSAPKCS1v15Decryptor(const CRSAPKCS1v15Decryptor&);
	CRSAPKCS1v15Decryptor& operator=(const CRSAPKCS1v15Decryptor&);
	};

/** 
* Mixin class defining operations common to all public key signature systems.
*
*/
class MSignatureSystem 
	{
public:
	/**
	 * Gets the maximum size of input accepted by this object.
	 *	
	 * @return	The maximum length allowed in bytes
	 */	 
	virtual TInt MaxInputLength(void) const = 0;
protected:
	/** Constructor */
	IMPORT_C MSignatureSystem(void);
private:
	MSignatureSystem(const MSignatureSystem&);
	MSignatureSystem& operator=(const MSignatureSystem&);
	};

/** 
* Abstract base class for all public key signers.
*
* The template parameter, CSignature, should be a class that encapsulates the
* concept of a digital signature.  Derived signature classes must own their
* respective signatures (and hence be CBase derived).  There are no other
* restrictions on the formation of the signature classes.
* 
*/
template <class CSignature> class CSigner : public CBase, public MSignatureSystem
	{
public:
	/**
	 * Digitally signs the specified input message
	 *
	 * @param aInput	The raw data to sign, typically a hash of the actual message
	 * @return			A pointer to a new CSignature object
	 *
	 * @panic ECryptoPanicInputTooLarge	If aInput is larger than MaxInputLength(),
	 *									which is likely to happen if the caller
	 *									has passed in something that has not been
	 *									hashed.
	 */
	virtual const CSignature* SignL(const TDesC8& aInput) const = 0;
protected:
	/** @internalAll */
	CSigner(void);
private:
	CSigner(const CSigner&);
	CSigner& operator=(const CSigner&);
	};

/** 
* Abstract class for all public key verifiers.
*
* The template parameter, CSignature, should be a class that encapsulates the
* concept of a digital signature.  Derived signature classes must own their
* respective signatures (and hence be CBase derived).  There are no other
* restrictions on the formation of the signature classes.
* 
*/
template <class CSignature> class CVerifier : public CBase, public MSignatureSystem
	{
public:
	/**
	 * Verifies the specified digital signature
	 *
	 * @param aInput		The message digest that was originally signed
	 * @param aSignature	The signature to be verified
	 * 
	 * @return				Whether the signature is the result of signing
	 *						aInput with the supplied key
	 */
	virtual TBool VerifyL(const TDesC8& aInput, 
		const CSignature& aSignature) const = 0;
protected:
	/** @internalAll */
	CVerifier(void);
private:
	CVerifier(const CVerifier&);
	CVerifier& operator=(const CVerifier&);
	};

/* Template for CVerifier and CSigner in asymmetric.inl */

template <class CSignature> 
CSigner<CSignature>::CSigner(void) 
    {
    }

/* CVerifier */
template <class CSignature> 
CVerifier<CSignature>::CVerifier(void) 
    {
    }


/** 
* An encapsulation of a RSA signature.
* 
*/
class CRSASignature : public CBase
	{
public:
	/**
	 * Creates a new CRSASignature object from the integer value 
	 * output of a previous RSA signing operation.
	 * 
	 * @param aS	The integer value output from a previous RSA signing operation
	 * @return		A pointer to the new CRSASignature object.
	 */
	IMPORT_C static CRSASignature* NewL(RInteger& aS);
	
	/**
	 * Creates a new CRSASignature object from the integer value 
	 * output of a previous RSA signing operation.
	 * 
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aS	The integer value output from a previous RSA signing operation
	 * @return		A pointer to the new CRSASignature object.
	 */
	IMPORT_C static CRSASignature* NewLC(RInteger& aS);
	
	/**
	 * Gets the integer value of the RSA signature
	 * 
	 * @return	The integer value of the RSA signature
	 */
	IMPORT_C const TInteger& S(void) const;
	
	/**
	 * Whether this RSASignature is identical to a specified RSASignature
	 *
	 * @param aSig	The RSASignature for comparison
	 * @return		ETrue, if the two signatures are identical; EFalse, otherwise.
	 */
	IMPORT_C TBool operator== (const CRSASignature& aSig) const;
	
	/** Destructor */
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CRSASignature(void);
protected:
	/** 
	 * Second phase constructor
	 *
	 * @see CRSASignature::NewL()
	 *
	 * @param aS	The integer value output from a previous RSA signing operation	
	 */
	IMPORT_C CRSASignature(RInteger& aS);

	/** Default constructor */
	IMPORT_C CRSASignature(void);
protected:
	/** An integer value; the output from a previous RSA signing operation. */
	RInteger iS;
private:
	CRSASignature(const CRSASignature&);
	CRSASignature& operator=(const CRSASignature);
	};

/** 
* Abstract base class for all RSA Signers.
* 
*/
class CRSASigner : public CSigner<CRSASignature>
	{
public:
	/**
	 * Gets the maximum size of output that can be generated by this object.
	 *
	 * @return	The maximum output length in bytes
	 */	 
	virtual TInt MaxOutputLength(void) const = 0;
protected:
	/** Default constructor */
	IMPORT_C CRSASigner(void);
private:
	CRSASigner(const CRSASigner&);
	CRSASigner& operator=(const CRSASigner&);
	};

/**
* Implementation of RSA signing as described in PKCS#1 v1.5.
* 
* This class creates RSA signatures following the RSA PKCS#1 v1.5 standard (with
* the one caveat noted below) and using PKCS#1 v1.5 signature padding.  The only
* exception is that the SignL() function simply performs a 'raw' PKCS#1 v1.5 sign
* operation on whatever it is given.  It does <b>not</b> hash or in any way
* manipulate the input data before signing.  
* 
*/
class CRSAPKCS1v15Signer : public CRSASigner
	{
public:
	/**
	 * Creates a new CRSAPKCS1v15Signer object from a specified RSA private key.
	 *  
	 * @param aKey	The RSA private key to be used for signing
	 * @return		A pointer to the new CRSAPKCS1v15Signer object
	 *
	 * @leave KErrKeySize	If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Signer* NewL(const CRSAPrivateKey& aKey);

	/**
	 * Creates a new CRSAPKCS1v15Signer object from a specified RSA private key.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The RSA private key to be used for signing
	 * @return		A pointer to the new CRSAPKCS1v15Signer object
	 *
	 * @leave KErrKeySize	If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Signer* NewLC(const CRSAPrivateKey& aKey);
	/**
	 * Digitally signs the specified input message
	 *
	 * @param aInput	The raw data to sign, typically a hash of the actual message
	 * @return			A pointer to a new CSignature object
	 *
	 * @leave KErrNotSupported			If the private key is not a supported TRSAPrivateKeyType
	 * @panic ECryptoPanicInputTooLarge	If aInput is larger than MaxInputLength(),
	 *									which is likely to happen if the caller
	 *									has passed in something that has not been hashed.
	 */
	virtual const CRSASignature* SignL(const TDesC8& aInput) const;
	virtual TInt MaxInputLength(void) const;
	virtual TInt MaxOutputLength(void) const;
	/** The destructor frees all resources owned by the object, prior to its destruction. 
	 * @internalAll */
	~CRSAPKCS1v15Signer(void);
protected:
	/** @internalAll */
	CRSAPKCS1v15Signer(const CRSAPrivateKey& aKey);
private:
	CRSAPKCS1v15Signer(const CRSAPKCS1v15Signer&);
	CRSAPKCS1v15Signer& operator=(const CRSAPKCS1v15Signer&);
	};

/** 
* Abstract base class for all RSA Verifiers.
*
*/
class CRSAVerifier : public CVerifier<CRSASignature>
	{
public:
	/**
	 * Gets the maximum size of output that can be generated by this object.
	 *
	 * @return	The maximum output length in bytes
	 */	 
	virtual TInt MaxOutputLength(void) const = 0;

	/**
	 * Performs a decryption operation on a signature using the public key.
	 *
	 * This is the inverse of the sign operation, which performs a encryption
	 * operation on its input data using the private key.  Although this can be
	 * used to verify signatures, CRSAVerifier::VerifyL should be used in
	 * preference.  This method is however required by some security protocols.
	 * 
	 * @param aSignature	The signature to be verified
	 * @return				A pointer to a new buffer containing the result of the
	 *						operation. The pointer is left on the cleanup stack.
	 */
	virtual HBufC8* InverseSignLC(const CRSASignature& aSignature) const = 0;

	IMPORT_C virtual TBool VerifyL(const TDesC8& aInput, 
		const CRSASignature& aSignature) const;
protected:
	/** Default constructor */
	IMPORT_C CRSAVerifier(void);
private:
	CRSAVerifier(const CRSAVerifier&);
	CRSAVerifier& operator=(const CRSAVerifier&);
	};

/**
* This class verifies RSA signatures given a message and its supposed
* signature.  It follows the RSA PKCS#1 v1.5 with PKCS#1 v1.5 padding specification
* with the following exception: the VerifyL() function does <b>not</b> hash or
* in any way manipulate the input data before checking.  
* 
*/
class CRSAPKCS1v15Verifier : public CRSAVerifier
	{
public:
	/**
	 * Creates a new CRSAPKCS1v15Verifier object from a specified RSA public key.
	 *
	 * @param aKey	The RSA public key to be used for verifying
	 * @return		A pointer to the new CRSAPKCS1v15Verifier object
	 *
	 * @leave KErrKeySize	If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Verifier* NewL(const CRSAPublicKey& aKey);

	/**
	 * Creates a new CRSAPKCS1v15Verifier object from a specified RSA public key.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The RSA public key to be used for verifying
	 * @return		A pointer to the new CRSAPKCS1v15Verifier object
	 *
	 * @leave KErrKeySize	If the key length is too small
	 */
	IMPORT_C static CRSAPKCS1v15Verifier* NewLC(const CRSAPublicKey& aKey);
	virtual HBufC8* InverseSignLC(const CRSASignature& aSignature) const;
	virtual TInt MaxInputLength(void) const;
	virtual TInt MaxOutputLength(void) const;
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	virtual ~CRSAPKCS1v15Verifier(void);
protected:
	/** @internalAll */
	CRSAPKCS1v15Verifier(const CRSAPublicKey& aKey);
private:
	CRSAPKCS1v15Verifier(const CRSAPKCS1v15Verifier&);
	CRSAPKCS1v15Verifier& operator=(const CRSAPKCS1v15Verifier&);
	};
	
/** 
* An encapsulation of a DSA signature.
* 
*/
class CDSASignature : public CBase
	{
public:
	/**
	 * Creates a new CDSASignature object from the specified R and S values.
	 *
	 * @param aR 	The DSA signature's R value
	 * @param aS	The DSA signature's S value
	 * @return		A pointer to the new CDSASignature object
	 */
	IMPORT_C static CDSASignature* NewL(RInteger& aR, RInteger& aS);

	/**
	 * Creates a new CDSASignature object from the specified R and S values.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aR 	The DSA signature's R value
	 * @param aS	The DSA signature's S value
	 * @return		A pointer to the new CDSASignature object
	 */
	IMPORT_C static CDSASignature* NewLC(RInteger& aR, RInteger& aS);
	
	/**
	 * Gets the DSA signature's R value
	 * 
	 * @return	The R value
	 */
	IMPORT_C const TInteger& R(void) const;
	
	/**
	 * Gets the DSA signature's S value
	 * 
	 * @return	The S value
	 */
	IMPORT_C const TInteger& S(void) const;
	
	/**
	 * Whether this DSASignature is identical to a specified DSASignature
	 *
	 * @param aSig	The DSASignature for comparison
	 * @return		ETrue, if the two signatures are identical; EFalse, otherwise.
	 */
	IMPORT_C TBool operator== (const CDSASignature& aSig) const;
	
	/** The destructor frees all resources owned by the object, prior to its destruction. */
	IMPORT_C virtual ~CDSASignature(void);
protected:
	/**
	 * Protected constructor
	 *
	 * @param aR 	The DSA signature's R value
	 * @param aS	The DSA signature's S value
	 */
	IMPORT_C CDSASignature(RInteger& aR, RInteger& aS);
	
	/** Default constructor */
	IMPORT_C CDSASignature(void);
protected:
	/** The DSA signature's R value */
	RInteger iR;
	/** The DSA signature's S value */
	RInteger iS;
private:
	CDSASignature(const CDSASignature&);
	CDSASignature& operator=(const CDSASignature&);
	};

/**
* Implementation of DSA signing as specified in FIPS 186-2 change request 1.
* 
*/
class CDSASigner : public CSigner<CDSASignature>
	{
public:
	/**
	 * Creates a new CDSASigner object from a specified DSA private key.
	 *
	 * @param aKey	The DSA private key to be used for signing
	 * @return		A pointer to the new CDSASigner object
	 */
	IMPORT_C static CDSASigner* NewL(const CDSAPrivateKey& aKey);

	/**
	 * Creates a new CDSASigner object from a specified DSA private key.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The DSA private key to be used for signing
	 * @return		A pointer to the new CDSASigner object
	 */
	IMPORT_C static CDSASigner* NewLC(const CDSAPrivateKey& aKey);
	/**
	 * Digitally signs the specified input message
	 *
	 * Note that in order to be interoperable and compliant with the DSS, aInput
	 * must be the result of a SHA-1 hash.
	 *
	 * @param aInput	A SHA-1 hash of the message to sign
	 * @return			A pointer to a new CSignature object
	 *
	 * @panic ECryptoPanicInputTooLarge	If aInput is larger than MaxInputLength(),
	 *									which is likely to happen if the caller
	 *									has passed in something that has not been hashed.
	 */
	virtual const CDSASignature* SignL(const TDesC8& aInput) const;
	virtual TInt MaxInputLength(void) const;
protected:
	/** @internalAll */
	CDSASigner(const CDSAPrivateKey& aKey);

private:
	CDSASigner(const CDSASigner&);
	CDSASigner& operator=(const CDSASigner&);
	};

/**
* Implementation of DSA signature verification as specified in FIPS 186-2 change
* request 1.
* 
*/
class CDSAVerifier : public CVerifier<CDSASignature>
	{
public:
	/**
	 * Creates a new CDSAVerifier object from a specified DSA public key.
	 *
	 * @param aKey	The DSA public key to be used for verifying
	 * @return		A pointer to the new CDSAVerifier object
	 */
	IMPORT_C static CDSAVerifier* NewL(const CDSAPublicKey& aKey);

	/**
	 * Creates a new CDSAVerifier object from a specified DSA public key.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aKey	The DSA public key to be used for verifying
	 * @return		A pointer to the new CDSAVerifier object
	 */
	IMPORT_C static CDSAVerifier* NewLC(const CDSAPublicKey& aKey);
	/**
	 * Verifies the specified digital signature
	 *
	 * Note that in order to be interoperable and compliant with the DSS, aInput
	 * must be the result of a SHA-1 hash.
	 *
	 * @param aInput		A SHA-1 hash of the received message
	 * @param aSignature	The signature to be verified
	 * 
	 * @return				Whether the signature is the result of signing
	 *						aInput with the supplied key
	 */
	virtual TBool VerifyL(const TDesC8& aInput, const CDSASignature& aSignature) const;
	virtual TInt MaxInputLength(void) const;
protected:
	/** @internalAll */
	CDSAVerifier(const CDSAPublicKey& aKey);

private:
	CDSAVerifier(const CDSAVerifier&);
	CDSAVerifier& operator=(const CDSAVerifier&);
	};

/**
* Implementation of Diffie-Hellman key agreement as specified in PKCS#3.
* 
*/
class CDH : public CBase
	{
public:
	/**
	 * Creates a new CDH object from a specified DH private key.
	 *
	 * @param aPrivateKey	The private key of this party
	 * @return				A pointer to the new CDH object
	 */
	IMPORT_C static CDH* NewL(const CDHPrivateKey& aPrivateKey);

	/**
	 * Creates a new CDH object from a specified DH private key.
	 *  
	 * The returned pointer is put onto the cleanup stack.
	 *
	 * @param aPrivateKey	The private key of this party
	 * @return				A pointer to the new CDH object
	 */
	IMPORT_C static CDH* NewLC(const CDHPrivateKey& aPrivateKey);
	
	/**
	 * Performs the key agreement operation.
	 *
	 * @param aPublicKey	The public key of the other party
	 * @return				The agreed key
	 */
	IMPORT_C const HBufC8* AgreeL(const CDHPublicKey& aPublicKey) const;
protected:
	/**
	 * Constructor
	 *
	 * @param aPrivateKey	The DH private key
	 */
	IMPORT_C CDH(const CDHPrivateKey& aPrivateKey);
protected:
	/** The DH private key */
	const CDHPrivateKey& iPrivateKey;
private:
	CDH(const CDH&);
	CDH& operator=(const CDH&);
	};

#endif