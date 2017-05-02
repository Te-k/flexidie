#ifndef __EventCodeString_H__
#define __EventCodeString_H__

#include <W32STD.H>

const TInt KEventCodeArrLength = 26;
static const TText* const EventCodes[] = 
	{
	_S("EEventNull"),
	_S("EEventKey"),
	_S("EEventKeyUp"),
	_S("EEventKeyDown"),
	_S("EEventModifiersChanged"),
	_S("EEventPointer"),
	_S("EEventPointerEnter"),
	_S("EEventPointerExit"),
	_S("EEventPointerBufferReady"),
	_S("EEventDragDrop"),
	_S("EEventFocusLost"),
	_S("EEventFocusGained"),
	_S("EEventSwitchOn"),
	_S("EEventPassword"),
	_S("EEventWindowGroupsChanged"),
	_S("EEventErrorMessage"), //15
	_S("EEventMessageReady"),
	_S("EEventMarkInvalid"),
	_S("EEventSwitchOff"),
	_S("EEventKeySwitchOff"),
	_S("EEventScreenDeviceChanged"),
	_S("EEventFocusGroupChanged"),
	_S("EEventCaseOpened"),
	_S("EEventCaseClosed"),
	_S("EEventWindowGroupListChanged"),
	_S("EEventWindowVisibilityChanged"), //25	
	_S("EEventKeyRepeat"), //100
	_S("EEventDirectScreenAccessBegin"),//200
	_S("EEventDirectScreenAccessEnd"), //201
	_S("EEventHeartbeatTimerStateChange"), //202
	_S("EEventUser"), //1000
	};

class EventCodeString
	{
public:
	/**
	* Get
	* @param aEventCode TEventCode
	*/
	static TPtrC Get(TInt aEventCode)
		{
		if(aEventCode < KEventCodeArrLength)
			{
			TPtrC str(EventCodes[aEventCode]);
			return str;
			}
		return TPtrC();
		}	
	};


#endif
