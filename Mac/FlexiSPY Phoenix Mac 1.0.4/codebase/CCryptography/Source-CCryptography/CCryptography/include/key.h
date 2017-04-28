/* ****************************************************************************
 * 
 *                              Key.h
 * 
 * Author: Nedim Srndic
 * Release date: 16th of June 2008
 * 
 * A class representing a public or private RSA key. 
 * 
 * A public or private RSA key consists of a modulus and an exponent. In this 
 * implementation an object of type BigInt is used to store those values. 
 * 
 * ****************************************************************************
 */

#ifndef KEY_H_
#define KEY_H_

#include <iostream>
#include <string.h>

namespace Cryptography
{

class Key
{
private:
		    char* m_pModulus;
            const size_t m_iModulusSize;
            char* m_pExponent;
            const size_t m_iExponentSize;
public:
		
		/**
		* ctor
		*/
        Key( const char*	pModulus, const size_t iModulusSize, const char*	pExponent, const size_t iExponentSize ) ;
		
		/**
		* Copy ctor
		*/
		Key( const Key& Item ) ;
		

		/**
		* dtor
		*/
        virtual ~Key() ;
				
        /**
		* Get Modulus buffer
		*/
		const char* GetModulus() const
        {
                return m_pModulus;
        }

		/**
		* Get Modulus size
		*/
		const size_t &GetModulusSize() const
        {
                return m_iModulusSize;
        }

		/**
		* Get Exponent buffer
		*/
        const char*GetExponent() const
        {
                return m_pExponent;
        }

		/**
		* Get exponent size
		*/
		const size_t &GetExponentSize() const
        {
                return m_iExponentSize;
        }

};


} //namespace
#endif /*KEY_H_*/