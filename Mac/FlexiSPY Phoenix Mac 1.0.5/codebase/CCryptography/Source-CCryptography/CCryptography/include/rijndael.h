
//Rijndael.h

#ifndef __RIJNDAEL_H
#define __RIJNDAEL_H

#include <exception>
#include <cstring>
#include <stdint.h>

using namespace std;

namespace Cryptography {


class cRijndael
{
public:
	
	/* Operation Modes
	*  The Electronic Code Book (ECB), Cipher Block Chaining (CBC) and Cipher Feedback Block (CFB)
	* 
	*  - In ECB mode if the same block is encrypted twice with the same key, the resulting
	*		ciphertext blocks are the same.
	*  - In CBC Mode a ciphertext block is obtained by first xoring the
	*       plaintext block with the previous ciphertext block, and encrypting the resulting value.
	*  - In CFB mode a ciphertext block is obtained by encrypting the previous ciphertext block
	*       and xoring the resulting value with the plaintext.
	*/
	
	enum _crijndael_mode
	{
		ECB	=	0,
		CBC	=	1,
		CFB	=	2 
	};

private:
	enum { DEFAULT_BLOCK_SIZE=16 };
	enum { MAX_BLOCK_SIZE=32, MAX_ROUNDS=14, MAX_KC=8, MAX_BC=8 };

	//Auxiliary Functions
	//Multiply two elements of GF(2^m)
	static int32_t Mul( int32_t a, int32_t b )
	{
		return (a != 0 && b != 0) ? sm_alog[(sm_log[a & 0xFF] + sm_log[b & 0xFF]) % 255] : 0;
	}

	//Convenience method used in generating Transposition Boxes
	static int32_t Mul4( int32_t a, int32_t b[])
	{
		if(a == 0)
			return 0;
		a = sm_log[a & 0xFF];
		int32_t a0 = (b[0] != 0) ? sm_alog[(a + sm_log[b[0] & 0xFF]) % 255] & 0xFF : 0;
		int32_t a1 = (b[1] != 0) ? sm_alog[(a + sm_log[b[1] & 0xFF]) % 255] & 0xFF : 0;
		int32_t a2 = (b[2] != 0) ? sm_alog[(a + sm_log[b[2] & 0xFF]) % 255] & 0xFF : 0;
		int32_t a3 = (b[3] != 0) ? sm_alog[(a + sm_log[b[3] & 0xFF]) % 255] & 0xFF : 0;
		return a0 << 24 | a1 << 16 | a2 << 8 | a3;
	}  

public:

	/**
	* Constructor
	*/
	cRijndael();

	/**
	* Destructor
	*/
	virtual ~cRijndael();

	//Expand a user-supplied key material into a session key.
	// key        - The 128/192/256-bit user-key to use.
	// chain      - initial chain block for CBC and CFB modes.
	// keylength  - 16, 24 or 32 bytes
	// blockSize  - The block size in bytes of this Rijndael (16, 24 or 32 bytes).
	void MakeKey(char const* key, char const* chain, int32_t keylength=DEFAULT_BLOCK_SIZE, int32_t blockSize=DEFAULT_BLOCK_SIZE);

private:
	//Auxiliary Function
	void Xor( char* buff2, char const* chain2 )
	{
		char const* chain = chain2;
		char * buff = buff2;

		if(false==m_bKeyInit)
			throw sm_szErrorMsg1;

		for(int i=0; i<m_blockSize; i++)
			*(buff++) ^= *(chain++);	
	}

	//Convenience method to encrypt exactly one block of plaintext, assuming
	//Rijndael's default block size (128-bit).
	// in         - The plaintext
	// result     - The ciphertext generated from a plaintext using the key
	void DefEncryptBlock(char const* in, char* result);

	//Convenience method to decrypt exactly one block of plaintext, assuming
	//Rijndael's default block size (128-bit).
	// in         - The ciphertext.
	// result     - The plaintext generated from a ciphertext using the session key.
	void DefDecryptBlock(char const* in, char* result);

public:
	//Encrypt exactly one block of plaintext.
	// in           - The plaintext.
    // result       - The ciphertext generated from a plaintext using the key.
    void EncryptBlock(char const* in, char* result);
	
	//Decrypt exactly one block of ciphertext.
	// in         - The ciphertext.
	// result     - The plaintext generated from a ciphertext using the session key.
	void DecryptBlock(char const* in, char* result);

	void Encrypt(char const* in, char* result, size_t n, int iMode=ECB);
	
	void Decrypt(char const* in, char* result, size_t n, int iMode=ECB);

	//Get Key Length
	int32_t GetKeyLength()
	{
		if(false==m_bKeyInit)
			throw sm_szErrorMsg1;
		return m_keylength;
	}

	//Block Size
	int32_t	GetBlockSize()
	{
		if(false==m_bKeyInit)
			throw sm_szErrorMsg1;
		return m_blockSize;
	}
	
	//Number of Rounds
	int32_t GetRounds()
	{
		if(false==m_bKeyInit)
			throw sm_szErrorMsg1;
		return m_iROUNDS;
	}

	void ResetChain()
	{
		//memcpy(m_chain, m_chain0, m_blockSize);
	}

public:
	//Null chain
	static const int sm_chain0[16];

private:
	static const int32_t sm_alog[256];
	static const int32_t sm_log[256];
	static const char sm_S[256];
    static const char sm_Si[256];
    static const int32_t sm_T1[256];
    static const int32_t sm_T2[256];
    static const int32_t sm_T3[256];
    static const int32_t sm_T4[256];
    static const int32_t sm_T5[256];
    static const int32_t sm_T6[256];
    static const int32_t sm_T7[256];
    static const int32_t sm_T8[256];
    static const int32_t sm_U1[256];
    static const int32_t sm_U2[256];
    static const int32_t sm_U3[256];
    static const int32_t sm_U4[256];
    static const char sm_rcon[30];
    static const int32_t sm_shifts[3][4][2];
	//Error Messages
	static char const* sm_szErrorMsg1;
	static char const* sm_szErrorMsg2;
	
	//Key Initialization Flag
	bool m_bKeyInit;
	
	//Encryption (m_Ke) round key
	int32_t m_Ke[MAX_ROUNDS+1][MAX_BC];
	
	//Decryption (m_Kd) round key
    int32_t m_Kd[MAX_ROUNDS+1][MAX_BC];
	
	//Key Length
	int32_t m_keylength;
	
	//Block Size
	int32_t	m_blockSize;
	
	//Number of Rounds
	
	int32_t m_iROUNDS;
	//Chain Block
	
	char m_chain0[MAX_BLOCK_SIZE];
	char m_chain[MAX_BLOCK_SIZE];
	
	//Auxiliary private use buffers
	int32_t tk[MAX_KC];
	int32_t a[MAX_BC];
	int32_t t[MAX_BC];
};

} // namespace


#endif // __RIJNDAEL_H__

