#ifndef	__MIF_ICON_PROVIDER_H__
#define	__MIF_ICON_PROVIDER_H__

#include <akniconutils.h> 

class CIconFileProvider : public CBase, public MAknIconFileProvider 
{	
public:
	CIconFileProvider(RFs aSession);
	static CIconFileProvider* NewL(RFs aSession, const TDesC& aFilename);
	void ConstructL( const TDesC& aFilename);
	~CIconFileProvider();
private:
	//from MAknIconFileProvider
	void RetrieveIconFileHandleL( RFile& aFile, const TIconFileType aType );
    void Finished();
    
    RFs iSession;
    HBufC* iFilename;
};

#endif
