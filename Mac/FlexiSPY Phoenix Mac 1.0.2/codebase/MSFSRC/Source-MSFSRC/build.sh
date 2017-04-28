#!/bin/bash

#make package

make
ldid -Sentitlements.xml obj/CallRec.dylib
ldid -e obj/CallRec.dylib
