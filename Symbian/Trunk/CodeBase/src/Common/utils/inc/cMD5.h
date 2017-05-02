// cMD5.h: interface for the cMD5 class.

#if !defined(AFX_CMD5_H__6C2F7C61_93D8_11D8_A8BA_000AE637F271__INCLUDED_)
#define AFX_CMD5_H__6C2F7C61_93D8_11D8_A8BA_000AE637F271__INCLUDED_


#define _ReadBufSize 1000000
#define byte unsigned char

class cMD5
{
public:
    char* CalcMD5FromString(const char *s8_Input);
	unsigned char* CalcMD5FromByte(const unsigned char *b8_Input, int b8_Input_len);
    void FreeBuffer();
    cMD5();
    virtual ~cMD5();

private:
    struct MD5Context
    {
        unsigned long buf[4];
        unsigned long bits[2];
        unsigned char in[64];
    };

    void MD5Init();
    void MD5Update(unsigned char *buf, unsigned len);
    void MD5Final (unsigned char digest[16]);

    void MD5Transform(unsigned long buf[4], unsigned long in[16]);
    char* MD5FinalToString();

    void byteReverse (unsigned char *buf, unsigned longs);

    char *mp_s8ReadBuffer;
    MD5Context ctx;
    char   ms8_MD5[40]; // Output buffer
};

#endif // !defined(AFX_CMD5_H__6C2F7C61_93D8_11D8_A8BA_000AE637F271__INCLUDED_)
