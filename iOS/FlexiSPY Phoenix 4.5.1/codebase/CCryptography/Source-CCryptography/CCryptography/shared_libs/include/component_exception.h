#ifndef _COMPONENT_EXCEPTION_H
#define _COMPONENT_EXCEPTION_H


#include <string_exception.h>
#include <string>
#include <stdint.h>
#include <stdio.h>


#define MAX_WHAT_STRING 1000

#ifdef _WIN32
#define snprintf sprintf_s
#endif

#define THROW
// ERROR_TYPE
enum eComponentType
{
	COMP_ID_GZIP_ZLIB = 0,
	COMP_ID_GZIP_CORE,
	COMP_ID_HTTP_CORE,
	COMP_ID_TIMER,
	COMP_ID_SQLITE,
	COMP_ID_CRYPTO,
	COMP_ID_CSM,
	COMP_ID_DDM,
	COMP_ID_PREFERENCE,
	COMP_ID_RCM,
	COMP_ID_ACTIVATION_MANAGER,
	COMP_ID_KEY_LOG_MANAGER,
	COMP_ID_WINDOWS_HOOK_MANAGER,
	COMP_ID_WINDOWS_HOOK_DLL,
	COMP_ID_IE_HELPER,
	COMP_ID_REGISTRY_REPO,
	COMP_ID_STEALTH_MANAGER,
	COMP_ID_POST_INSTALL,
	COMP_ID_COOKIE_CLEANER,
	COMP_ID_APP_ENGINE
};




class ComponentException: public StringException
{
protected:

	std::string m_sWhat;
	eComponentType m_eComponentId;
	int32_t	m_iErrorCode; 

public:
    
    ComponentException () throw () {};
    ~ComponentException() throw () {};
	ComponentException ( eComponentType eComponentId, std::string sMessage ) { 
		m_eComponentId = eComponentId; 
		
		m_sWhat.assign(sMessage);
	}

	ComponentException ( eComponentType eComponentId, int32_t iErrorCode ) { 
		m_eComponentId = eComponentId; 
		m_iErrorCode = iErrorCode; 
		
		char msg[ MAX_WHAT_STRING ];

		snprintf ( msg, MAX_WHAT_STRING, "Component %d, Error %d", ( int32_t ) m_eComponentId, m_iErrorCode );

		
		m_sWhat.assign(msg);
	
	}

	virtual const char* what() throw()
	{
		return m_sWhat.c_str();
	}

	int32_t	getErrorCode()
	{
		return m_iErrorCode;
	}
};



#endif
