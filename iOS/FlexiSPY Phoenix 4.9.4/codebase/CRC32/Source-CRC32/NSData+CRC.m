//
//  NSData+CRC.m
//  CRC32
//
//  Created by Makara Khloth on 9/28/15.
//
//

#import "NSData+CRC.h"

#define DEFAULT_POLYNOMIAL 0xEDB88320L
#define DEFAULT_SEED       0xFFFFFFFFL

@implementation NSData (CRC)

//***********************************************************************************************************
//  Function      : generateCRC32Table
//
//  Description   : Generates a lookup table for CRC calculations using a supplied polynomial.
//
//  Declaration   : void generateCRC32Table(uint32_t *pTable, uint32_t poly);
//
//  Parameters    : pTable
//                    A pointer to pre-allocated memory to store the lookup table.
//
//                  poly
//                    The polynomial to use in calculating the CRC table values.
//
//  Return Value  : None.
//***********************************************************************************************************
void generateCRC32Table(uint32_t *pTable, uint32_t poly)
{
    for (uint32_t i = 0; i <= 255; i++)
    {
        uint32_t crc = i;
        
        for (uint32_t j = 8; j > 0; j--)
        {
            if ((crc & 1) == 1)
                crc = (crc >> 1) ^ poly;
            else
                crc >>= 1;
        }
        pTable[i] = crc;
    }
}

//***********************************************************************************************************
//  Method        : crc32
//
//  Description   : Calculates the CRC32 of a data object using the default seed and polynomial.
//
//  Declaration   : -(uint32_t)crc32;
//
//  Parameters    : None.
//
//  Return Value  : The CRC32 value.
//***********************************************************************************************************
-(uint32_t)crc32
{
    return [self crc32WithSeed:DEFAULT_SEED usingPolynomial:DEFAULT_POLYNOMIAL];
}

//***********************************************************************************************************
//  Method        : crc32WithSeed:
//
//  Description   : Calculates the CRC32 of a data object using a supplied seed and default polynomial.
//
//  Declaration   : -(uint32_t)crc32WithSeed:(uint32_t)seed;
//
//  Parameters    : seed
//                    The initial CRC value.
//
//  Return Value  : The CRC32 value.
//***********************************************************************************************************
-(uint32_t)crc32WithSeed:(uint32_t)seed
{
    return [self crc32WithSeed:seed usingPolynomial:DEFAULT_POLYNOMIAL];
}

//***********************************************************************************************************
//  Method        : crc32UsingPolynomial:
//
//  Description   : Calculates the CRC32 of a data object using a supplied polynomial and default seed.
//
//  Declaration   : -(uint32_t)crc32UsingPolynomial:(uint32_t)poly;
//
//  Parameters    : poly
//                    The polynomial to use in calculating the CRC.
//
//  Return Value  : The CRC32 value.
//***********************************************************************************************************
-(uint32_t)crc32UsingPolynomial:(uint32_t)poly
{
    return [self crc32WithSeed:DEFAULT_SEED usingPolynomial:poly];
}

//***********************************************************************************************************
//  Method        : crc32WithSeed:usingPolynomial:
//
//  Description   : Calculates the CRC32 of a data object using supplied polynomial and seed values.
//
//  Declaration   : -(uint32_t)crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly;
//
//  Parameters    : seed
//                    The initial CRC value.
//
//                : poly
//                    The polynomial to use in calculating the CRC.
//
//  Return Value  : The CRC32 value.
//***********************************************************************************************************
-(uint32_t)crc32WithSeed:(uint32_t)seed usingPolynomial:(uint32_t)poly
{
    uint32_t *pTable = malloc(sizeof(uint32_t) * 256);
    generateCRC32Table(pTable, poly);
    
    uint32_t crc    = seed;
    uint8_t *pBytes = (uint8_t *)[self bytes];
    uint32_t length = [self length];
    
    while (length--)
    {
        crc = (crc>>8) ^ pTable[(crc & 0xFF) ^ *pBytes++];
    }
    
    free(pTable);
    return crc ^ 0xFFFFFFFFL;
}

@end
