#ifndef _OBJECT_GUARD_H_
#define _OBJECT_GUARD_H_

template <class C>
class CObjectGuard
{
	C* m_pItem;
public:
	CObjectGuard ( C* aItem )
	{
		m_pItem = aItem;
	}

	void release()
	{
		m_pItem = 0;
	}

	virtual ~CObjectGuard()
	{
		if ( m_pItem )
			delete m_pItem;
	}
};

#endif