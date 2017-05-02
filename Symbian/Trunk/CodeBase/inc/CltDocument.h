#ifndef CltDocument_H
#define CltDocument_H

#include <akndoc.h>	// CAknDocument

class CEikAppUi;
class CEikApplication;
class CCltSettingMan;
class CFxsDatabase;
class CApaWindowGroupName;

class CCltDocument : public CAknDocument
	{
public: // Constructor
	static CCltDocument* NewL(CEikApplication& aApp);
	~CCltDocument();
	
	inline void SetHideFromTaskList(TBool aHide)
		{iHideFromTaskList = aHide; }
	
	inline TBool CurrentlyHideFromTaskList() const
		{return iHideFromTaskList;}	
	
	//
	//hide its icon from phone task list
	void UpdateTaskNameL(CApaWindowGroupName* aWgName);	
private:
	CCltDocument(CEikApplication& aApp);
	void ConstructL();
	
private:
	CEikAppUi*        CreateAppUiL();	
	//CCltSettingMan*      iSetting;
	//CFxsDatabase*    iDatabase;		
	/**
	Flag indicates to hide from task list*/
	TBool iHideFromTaskList;	
};

#endif

