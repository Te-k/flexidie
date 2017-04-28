/*
 *  GPSMethodEnum.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 8/31/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

typedef enum {
	UNKNOWN_GPS_METHOD,
	METHOD_CELL_INFO,
	INTEGRATED_GPS,
	AGPS,
	BLUETOOTH,
	NETWORK,
	METHOD_WIFI,
	CELLULAR
} GPSMethod;