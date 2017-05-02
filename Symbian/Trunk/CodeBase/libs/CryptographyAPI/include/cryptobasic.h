// Copyright (c) 2003-2007 Symbian Software Ltd.  All rights reserved.
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

#ifndef __CRYPTOBASIC_H__
#define __CRYPTOBASIC_H__

#include <random.h>
#include <e32base.h>

/**
 * Some builds of the crypto library have restrictions that only allow weak
 * ciphers to be used.  This class provides static helper functions for
 * determining these restrictions.
 */
class TCrypto
	{
public:
	/**
	 * Defines the strength of the cipher. 
	 */
	enum TStrength 
		{ 
		EWeak, EStrong
		};
public:
	/**
	 * Gets the allowed cipher strength.
	 *
	 * @return The allowed cipher strength.	
	 */	
	static IMPORT_C TCrypto::TStrength Strength();

	/**
	 * Indicates whether a symmetric key is small enough to be allowed. Note
	 * that this function leaves if the key is too large - in other words it can
	 * never return EFalse.
	 * 
	 * @param aSymmetricKeyBits	    The size (in bits) of the symmetric key
	 * @return						Whether the key is small enough to be allowed
	 * 
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 */
	static IMPORT_C TBool IsSymmetricWeakEnoughL(TInt aSymmetricKeyBits);

	/**
	 * Indicates whether an asymmetric key is small enough to be allowed.  Note
	 * that this function leaves if the key is too large - in other words it can
	 * never return EFalse.
	 *
	 * @param aAsymmetricKeyBits	The size (in bits) of the asymmetric key
	 * @return						Whether the key is small enough to be allowed
	 * 
	 * @leave KErrKeyNotWeakEnough	If the key size is larger than that allowed by the
	 *								cipher strength restrictions of the crypto library.
	 */
	static IMPORT_C TBool IsAsymmetricWeakEnoughL(TInt aAsymmetricKeyBits);
	};

/** @internalComponent */
const TUint KSignMask = 0x1L;

class RInteger;

/**
 * Abstract base class defining the interface for handling and manipulating big
 * integers.
 *
 * TInteger is capable of representing both negative and positive integers 
 * with an absolute value of less than 2^32^(2^32).  To create an integer 
 * look at RInteger.
 * TInteger defines an interface for the RInteger implementation - it is not
 * intended that TIntegers be copied or assigned from other TIntegers.  On EKA1
 * platforms, this is possible, but it should be avoided.
 * 
 * 
 * @see RInteger
 */
class TInteger
	{
public:
	
	enum TRandomAttribute {EAllBitsRandom=0, ETopBitSet=1, ETop2BitsSet=2};

	IMPORT_C HBufC8* BufferLC() const;
	IMPORT_C TUint WordCount(void) const;
	IMPORT_C TUint ByteCount(void) const;
	IMPORT_C TUint BitCount(void) const;

	IMPORT_C static const TInteger& Zero(void);
	IMPORT_C static const TInteger& One(void);
	IMPORT_C static const TInteger& Two(void);

	IMPORT_C RInteger PlusL(const TInteger& aOperand) const;
	IMPORT_C RInteger MinusL(const TInteger& aOperand) const;
	IMPORT_C RInteger TimesL(const TInteger& aOperand) const;
	IMPORT_C RInteger DividedByL(const TInteger& aOperand) const;
	IMPORT_C RInteger DividedByL(TUint aOperand) const;
	IMPORT_C RInteger ModuloL(const TInteger& aOperand) const;
	IMPORT_C TUint ModuloL(TUint aOperand) const;
	
	IMPORT_C RInteger SquaredL(void) const;
	IMPORT_C RInteger ExponentiateL(const TInteger& aExponent) const;
	IMPORT_C static RInteger ModularMultiplyL(const TInteger& aA, const TInteger& aB,
		const TInteger& aModulus);
	IMPORT_C static RInteger ModularExponentiateL(const TInteger& aBase, 
		const TInteger& aExp, const TInteger& aMod);
	IMPORT_C RInteger GCDL(const TInteger& aOperand) const;
	IMPORT_C RInteger InverseModL(const TInteger& aMod) const;
	
	// These overloaded operator functions leave 
	IMPORT_C TInteger& operator += (const TInteger& aOperand);
	IMPORT_C TInteger& operator -= (const TInteger& aOperand);
	IMPORT_C TInteger& operator *= (const TInteger& aOperand);
	IMPORT_C TInteger& operator /= (const TInteger& aOperand);
	IMPORT_C TInteger& operator %= (const TInteger& aOperand);

	IMPORT_C TInteger& operator += (TInt aOperand);
	IMPORT_C TInteger& operator -= (TInt aOperand);
	IMPORT_C TInteger& operator *= (TInt aOperand);
	IMPORT_C TInteger& operator /= (TInt aOperand);
	IMPORT_C TInteger& operator %= (TInt aOperand);
	IMPORT_C TInteger& operator -- ();
	IMPORT_C TInteger& operator ++ ();

	IMPORT_C TInteger& operator <<= (TUint aBits);
	// End of leaving overloaded operator functions 
	IMPORT_C TInteger& operator >>= (TUint aBits);

	IMPORT_C TInt UnsignedCompare(const TInteger& aThat) const;
	IMPORT_C TInt SignedCompare(const TInteger& aThat) const;
	IMPORT_C TBool operator ! () const;
	inline TBool operator == (const TInteger& aInteger) const;
	inline TBool operator != (const TInteger& aInteger) const;
	inline TBool operator <= (const TInteger& aInteger) const;
	inline TBool operator >= (const TInteger& aInteger) const;
	inline TBool operator < (const TInteger& aInteger) const;
	inline TBool operator > (const TInteger& aInteger) const;
	
	IMPORT_C TInt SignedCompare(TInt aThat) const;
	inline TBool operator == (TInt aInteger) const;
	inline TBool operator != (TInt aInteger) const;
	inline TBool operator <= (TInt aInteger) const;
	inline TBool operator >= (TInt aInteger) const;
	inline TBool operator < (TInt aInteger) const;
	inline TBool operator > (TInt aInteger) const;

	inline TBool IsZero() const {return !*this;}
	inline TBool NotZero() const {return !IsZero();}
	inline TBool IsNegative() const {return Sign() == ENegative;}
	inline TBool NotNegative() const {return !IsNegative();}
	inline TBool IsPositive() const {return NotNegative() && NotZero();}
	inline TBool NotPositive() const {return !IsPositive();}
	inline TBool IsEven() const {return Bit(0) == EFalse;}
	inline TBool IsOdd() const {return Bit(0);}

	IMPORT_C TBool IsPrimeL(void) const;

	IMPORT_C TBool Bit(TUint aBitPos) const;
	IMPORT_C void SetBit(TUint aBitPos);
	IMPORT_C void Negate(void);

	IMPORT_C TInt ConvertToLongL(void) const;

	IMPORT_C void CopyL(const TInteger& aInteger, TBool aAllowShrink=ETrue);
	IMPORT_C void CopyL(const TInt aInteger, TBool aAllowShrink=ETrue);
	IMPORT_C void Set(const RInteger& aInteger);

protected: //Construction functions
	IMPORT_C TInteger(void);

protected: //Member data
	enum TSign {EPositive=0, ENegative=1};
	TUint iSize;
	TUint iPtr;
protected: 

	inline TSign Sign(void) const {return (TSign)(iPtr&KSignMask);}

private:
	// disable default copy constructor and assignment operator
	TInteger(const TInteger& aInteger);
	TInteger& operator=(const TInteger& aInteger);

	friend class CMontgomeryStructure;
	friend class RInteger; //in order to have access to Size() for an argument
	};

// Inline methods for TInteger

inline TBool TInteger::operator == (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) == 0;
	}

inline TBool TInteger::operator != (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) != 0;
	}

inline TBool TInteger::operator <= (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) <= 0;
	}

inline TBool TInteger::operator >= (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) >= 0;
	}

inline TBool TInteger::operator < (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) < 0;
	}

TBool TInteger::operator > (const TInteger& aInteger) const
	{
	return SignedCompare(aInteger) > 0;
	}

inline TBool TInteger::operator == (TInt aInteger) const
	{
	return SignedCompare(aInteger) == 0;
	}

inline TBool TInteger::operator != (TInt aInteger) const
	{
	return SignedCompare(aInteger) != 0;
	}

inline TBool TInteger::operator <= (TInt aInteger) const
	{
	return SignedCompare(aInteger) <= 0;
	}

inline TBool TInteger::operator >= (TInt aInteger) const
	{
	return SignedCompare(aInteger) >= 0;
	}

inline TBool TInteger::operator < (TInt aInteger) const
	{
	return SignedCompare(aInteger) < 0;
	}

inline TBool TInteger::operator > (TInt aInteger) const
	{
	return SignedCompare(aInteger) > 0;
	}


/** 
 * A TInteger derived class allowing the construction of variable length big integers.
 * See the Cryptography API guide for further information.
 *
 *
 * @see TInteger
 */
class RInteger : public TInteger
	{
public:
	IMPORT_C static RInteger NewL(void);
	IMPORT_C static RInteger NewL(const TDesC8& aValue);
	IMPORT_C static RInteger NewL(const TInteger& aInteger);
	IMPORT_C static RInteger NewL(TInt aInteger);
	IMPORT_C static RInteger NewL(TUint aInteger);
	IMPORT_C static RInteger NewEmptyL(TUint aNumWords);

	IMPORT_C static RInteger NewRandomL(TUint aBits, 
		TRandomAttribute aAttr=EAllBitsRandom);
	IMPORT_C static RInteger NewRandomL(const TInteger& aMin,
		const TInteger& aMax);
	IMPORT_C static RInteger NewPrimeL(TUint aBits, 
		TRandomAttribute aAttr=EAllBitsRandom);

	IMPORT_C RInteger(void);
	IMPORT_C RInteger(const RInteger& aInteger);
	IMPORT_C RInteger& operator=(const RInteger& aInteger);

	IMPORT_C operator TCleanupItem();
	IMPORT_C static void CallClose(TAny* aPtr);
	IMPORT_C void Close(void);
	};


#endif //__CRYPTOBASIC_H__

