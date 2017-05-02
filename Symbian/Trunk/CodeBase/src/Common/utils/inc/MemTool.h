#ifndef __MemTool_H__
#define __MemTool_H__

#include <e32base.h>
#include <hal.h>
#include <hal_data.h>
#include "Logger.h"

class MemTool
	{
public:
	static void CompressHeap()
		{
		TInt BeforeFree = 0;
		TInt AfterFree = 0;
		TInt FreeHeapSize = 0;
		
		HAL::Get(HALData::EMemoryRAMFree,BeforeFree);
		LOG1(_L("Total heap BeforeFree [ %d kb ]"),BeforeFree)
		User::CompressAllHeaps();
		HAL::Get(HALData::EMemoryRAMFree,AfterFree);
		LOG1(_L("Total heap AfterFree [ %d kb ]"),AfterFree)
		FreeHeapSize = (AfterFree - BeforeFree) / 1024;
		LOG1(_L("Total heap FreeHeapSize [ %d kb ]"),FreeHeapSize)
		}
	
	static void PrintInfo()
		{
		TInt totalHeapBytes, totalHeapCells, usedHeapCells, freeHeapCells, freeBytes, biggestBlock;		
		totalHeapCells = User::AllocSize(totalHeapBytes);
		usedHeapCells = User::CountAllocCells(freeHeapCells);
		freeBytes = User::Available(biggestBlock);
		
		LOG2(_L("Heap Status: Total Heap Cells:%d Heap Size:%d"), totalHeapCells, totalHeapBytes);
		LOG4(_L("Heap Cells Used:%d Free:%d Free Bytes:%d Biggest BlockSize:%d"), usedHeapCells, freeHeapCells, freeBytes, biggestBlock);
		}
	
	};
	
#endif
