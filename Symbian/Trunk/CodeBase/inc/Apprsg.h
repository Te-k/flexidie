#ifndef __APP_RSG_H__
#define __APP_RSG_H__

//common hrh
#include "Fxscommon.hrh"

#include <ProdActiv.rsg>
//app name macro is defined in mmp
#ifdef __APP_FXS_PROX
	#include <mobibak_0x2000B2C2.rsg>//PRO-X
#elif defined __APP_FXS_PRO
	#include <rbackpro_0x2000A982.rsg> //PRO
#elif defined __APP_FXS_LIGHT
	#include <rbacklite_0x2000A97B.rsg> //LIGHT
#endif

#endif
