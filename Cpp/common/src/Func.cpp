#include "Precompiled.h"
#include "../include/Func.h"

int StrToInt( const void* ptr, uint32 uSize )
{
	if (!ptr || !uSize || uSize > 10)
		return 0;

	int val = 0;
	const char* pStr = (const char*)ptr + uSize - 1;

	for (int i = 1; uSize-- && '0' <= *pStr && *pStr <= '9'; i *= 10, --pStr)
		val += (*pStr - '0') * i;

	if (uSize != -1)
		return 0;
	return val;
}

