#ifndef _DER_ENCODING_H
#define _DER_ENCODING_H

#include "encoding.h"
#include "decoder.h"
#include <string>
#include <vector>

namespace Cryptography
{

class cDerNode;


class IDerNodeListener 
{
public:
	virtual void OnItemFound ( int16_t iType, char * arrData, size_t szSize ) = 0;
};


class cDerEncoding: public cEncoding, public IDerNodeListener
{
private:
	int32_t m_lCurIdx;
	std::vector<IEncodingListener*> m_vecListeners;
public:
	
	
	cDerEncoding();
	/** 
	* dtor
	*/
	virtual ~cDerEncoding ();

	/** 
	* Return the encoding name
	*/
	virtual std::string getEncoding() { return "DER"; };

	/**
	* Register result listener
	*
	* @param oListener the listener
	*/
	virtual void registerListener ( IEncodingListener * oListener );

	/**
	* Decode the Byte array
	*
	* @param arrData	Data
	* @param szSize		Size of Data
	*/
	virtual void decode ( const char* arrData, const size_t szSize );

	/**
	* Call back function for the node processing
	*
	* @param iType		type of node being process
	* @param arrData	Data
	* @param szSize		Size
	*/
	virtual void OnItemFound ( int16_t iType, char * arrData, size_t szSize );
};



class cNodeFactory 
{
public:
	static cDerNode* generateNode ( const char* pInput, 
									size_t szParentSize, 
									size_t &szNewSize, 
									IDerNodeListener* oListener );
};

class cDerNode
{
protected:
	size_t m_szSize;
	
public:
	virtual ~cDerNode () {};

};

class cSequenceNode:public cDerNode
{
private:
	std::vector<cDerNode*> m_arrItems;
public:
	cSequenceNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener );
	~cSequenceNode();
};

class cIntegerNode:public cDerNode
{
private:
	char* m_arrItems;
	size_t szSize;

public:
	cIntegerNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener ); 

	virtual ~cIntegerNode();

}; 

class cNullNode : public cDerNode 
{
public: 
	cNullNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener ); 


};

class cObjectIdNode : public cDerNode 
{
	char* m_arrItems;
	size_t szSize;
public: 

	cObjectIdNode ( const char* iInput, size_t szSize, IDerNodeListener* oListener ); 
	virtual ~cObjectIdNode();
};

}
#endif
