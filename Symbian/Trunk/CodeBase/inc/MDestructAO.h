#ifndef _MDESTRUCTAO_H__
#define _MDESTRUCTAO_H__

/**
This is special interface of AO that */
class MDestructAO
	{
public:	
	virtual ~MDestructAO(){}
	virtual void Destruct() = 0;
	};

#endif
