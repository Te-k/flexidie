#ifndef _CBASENOTIFIER_H
#define _CBASENOTIFIER_H

#include <vector>

/** 
* cBaseNotifier.h
* 
* This is a Observer pattern implementation
*/

class cBaseNotifier;

/**
* Class cBaseDescriptor
*
* It's a content that will be notified
*/
class cBaseDescriptor 
{
public: 
	/** 
	* return type of descriptor
	*
	* @return descriptor type as per implemented.
	*/
	virtual long getType() { return -1; }

	virtual ~cBaseDescriptor() {};
};

/**
* Class cBaseListener
*
* It's a content that will be notified
*/
class cBaseListener
{
private:
	/** 
	* Call back that the Listeners need to implement
	*
	* @param oDesc	Descriptors, context of the notification
	*/
	virtual void onNotify ( cBaseDescriptor* oDesc ) = 0;

public: 

	/** 
	* dtor
	*/
	virtual ~cBaseListener() {};

	// Set friend classes so that it can access to OnNotified ();
	friend class cBaseNotifier;
};

/**
* Class cBaseNotifier
*
* It's a content that will be notified
*/
class cBaseNotifier
{
private:
	std::vector<cBaseListener*> m_vecView;

public:
	
	/** 
	* dtor
	*/
	virtual ~cBaseNotifier() {};

	/** 
	* set listener
	*
	* set the listener ( only 1 listener at a time )
	*
	* @param oNewListener Listener class
	*/
	void setListener ( cBaseListener* oNewListener );
	
	/** 
	* add listener
	*
	* Child class doesn't need to override this
	*
	* @param oNewListener Listener class
	*/
	void addListener ( cBaseListener* oNewListener );
	
	/** 
	* notify the listeners
	*
	* Child class doesn't need to override this
	*
	* @param oDescriptor Listener class
	*/
	void notifyListeners ( cBaseDescriptor* oDescriptor );
};


#endif