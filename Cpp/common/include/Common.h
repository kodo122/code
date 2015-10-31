#pragma once

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <cstddef>
#include <string.h>
#include <stdarg.h>
#include <time.h>
#include <math.h>
#include <string>
#include <vector>
#include <list>
#include <set>
#include <map>
#include <deque>
#include <queue>
#include <algorithm>

#include <errno.h>
#include <stdarg.h>
#include <fcntl.h>
#include <limits.h>

#include <sys/stat.h>
#ifdef __GNUC__
#include <unistd.h>
#else
#include <direct.h>
#endif

#ifdef __linux__
#include "Common_Linux.h"
#else
#include "Common_Win.h"
#endif

#if (defined(_MSC_VER) || defined(__ICL))
#define snprintf  _snprintf
#define vsnprintf _vsnprintf
#endif 

#if (defined(_MSC_VER) || defined(__ICL))
inline struct tm *localtime_r(const time_t *timep, struct tm *result)
{
	struct tm *ptm = localtime(timep);
	if (
		(result) &&
		(ptm)
		)
	{
		*result = *ptm;
	}

	return ptm;
};
#endif

#if (defined(_MSC_VER) || defined(__ICL))
#define Mkdir mkdir
#else   // if linux
inline int Mkdir(const char cszDir[])
{
	return mkdir(cszDir, 0777);
}
#endif

#ifndef PATH_MAX
#define PATH_MAX    1024
#endif

#define PROCESS_ERROR(Condition) \
	do  \
{   \
	if (!(Condition))   \
	goto Exit0;     \
} while (false)

#define PROCESS_SUCCESS(Condition) \
	do  \
{   \
	if (Condition)      \
	goto Exit1;     \
} while (false)


#define COM_RELEASE(pInterface) \
	do  \
{   \
	if (pInterface)                 \
{                               \
	(pInterface)->Release();    \
	(pInterface) = NULL;        \
}                               \
} while (false)

#define PROCESS_ERROR_RET_CODE(Condition, Code) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	nResult = Code;     \
	goto Exit0;         \
}                       \
} while (false)

#define PROCESS_DELETE(p)    \
	do  \
{   \
	if (p)              \
{                   \
	delete (p);     \
	(p) = NULL;     \
}                   \
} while (false)

#define PRINT_PROCESS_ERROR(Condition) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	printf(        \
	"Error(%s) at file %s at line %d\n", #Condition, __FILE__, __LINE__  \
	);                  \
	goto Exit0;         \
}                       \
} while (false)
