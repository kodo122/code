#pragma once

enum LOG_PRIORITY
{
	LOG_RESERVE0  =   0,  // LOG_EMERG  =   0,  // system is unusable
	LOG_RESERVE1  =   1,  // LOG_ALERT  =   1,  // action must be taken immediately
	LOG_RESERVE2  =   2,  // LOG_CRIT   =   2,  // critical conditions
	LOG_ERR		=   3,  // error conditions
	LOG_WARNING	=   4,  // warning conditions
	LOG_RESERVE3  =   5,  // LOG_NOTICE =   5,  // normal but significant condition
	LOG_INFO	    =   6,  // informational 
	LOG_DEBUG	    =   7,  // debug-level messages
	LOG_PRIORITY_MAX
};

enum LOG_OPTIONS
{
	LOG_OPTION_FILE      =   0x01,   // log on to file, default
	LOG_OPTION_CONSOLE   =   0x02,   // log on the console if errors in sending
	LOG_OPTION_STDERR    =   0x04,   // log on the stderr stream
};

#define LOG_PRIMASK    0x07

#define	LOG_PRI(pri)	((pri) & LOG_PRIMASK)

// arguments to setlogmask.
#define	LOG_MASK(pri) (1 << (pri))		    // mask for one priority
#define	LOG_UPTO(pri) ((1 << ((pri)+1)) - 1)	// all priorities through pri


typedef struct _LOG_PARAM
{
	char szPath[PATH_MAX];      // if LOG_FILE
	char szIdent[PATH_MAX];     // if LOG_FILE
	LOG_OPTIONS Options;          // 0 is default
	int  nMaxLineEachFile;

} LOG_PARAM;

// cszIdent is file name prefix
int LogInit(const LOG_PARAM& cLogParam);
int LogUnInit();

//  Set the log mask level if nPriorityMask != 0
int LogSetPriorityMask(int nPriorityMask);

int LogPrintf(LOG_PRIORITY Priority, const char cszFormat[], ...);


#define LOG_PROCESS_ERROR(Condition) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_PROCESS_ERROR(%s) at line %d in %s\n", #Condition, __LINE__, __FUNCTION__  \
	);                  \
	goto Exit0;         \
}                       \
} while (false)


#define LOG_OUTPUT_ERROR(Condition) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_PROCESS_ERROR(%s) at line %d in %s\n", #Condition, __LINE__, __FUNCTION__  \
	);                  \
}                       \
} while (false)

#define LOG_PROCESS_SUCCESS(Condition) \
	do  \
{   \
	if (Condition)          \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_PROCESS_SUCCESS(%s) at line %d in %s\n", #Condition, __LINE__, __FUNCTION__  \
	);                  \
	goto Exit1;         \
}                       \
} while (false)

#define LOG_PROCESS_ERROR_RET_CODE(Condition, Code) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_PROCESS_ERROR_RET_CODE(%s, %d) at line %d in %s\n", \
#Condition, (Code), __LINE__, __FUNCTION__                  \
	);                  \
	nResult = (Code);   \
	goto Exit0;         \
}                       \
} while (false)

#define LOG_PROCESS_ERROR_RET_COM_CODE(Condition, Code) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_PROCESS_ERROR_RET_CODE(%s, %d) at line %d in %s\n", \
#Condition, (Code), __LINE__, __FUNCTION__                  \
	);                  \
	hrResult = (Code);  \
	goto Exit0;         \
}                       \
} while (false)


#define LOG_COM_PROCESS_ERROR(Condition) \
	do  \
{   \
	if (FAILED(Condition))  \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_COM_PROCESS_ERROR(0x%X) at line %d in %s\n", (Condition), __LINE__, __FUNCTION__  \
	);                  \
	goto Exit0;         \
}                       \
} while (false)


#define LOG_COM_PROCESS_SUCCESS(Condition)   \
	do  \
{   \
	if (SUCCEEDED(Condition))   \
{                           \
	LogPrintf(            \
	LOG_DEBUG,        \
	"LOG_COM_PROCESS_SUCCESS(0x%X) at line %d in %s\n", (Condition), __LINE__, __FUNCTION__  \
	);                      \
	goto Exit1;             \
}                           \
} while (false)


// KG_COM_PROCESS_ERROR_RETURN_ERROR
#define LOG_COM_PROC_ERR_RET_ERR(Condition)  \
	do  \
{   \
	if (FAILED(Condition))      \
{                           \
	LogPrintf(            \
	LOG_DEBUG,        \
	"LOG_COM_PROC_ERR_RET_ERR(0x%X) at line %d in %s\n", (Condition), __LINE__, __FUNCTION__  \
	);                      \
	hrResult = (Condition); \
	goto Exit0;             \
}                           \
} while (false)


#define LOG_COM_PROC_ERROR_RET_CODE(Condition, Code)     \
	do  \
{   \
	if (FAILED(Condition))      \
{                           \
	LogPrintf(            \
	LOG_DEBUG,        \
	"LOG_COM_PROC_ERROR_RET_CODE(0x%X, 0x%X) at line %d in %s\n", (Condition), (Code), __LINE__, __FUNCTION__  \
	);                      \
	hrResult = (Code);      \
	goto Exit0;             \
}                           \
} while (false)

#define LOG_CHECK_ERROR(Condition) \
	do  \
{   \
	if (!(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_CHECK_ERROR(%s) at line %d in %s\n", #Condition, __LINE__, __FUNCTION__  \
	);                  \
}                       \
} while (false)

#define LOG_COM_CHECK_ERROR(Condition) \
	do  \
{   \
	if (FAILED(Condition))       \
{                       \
	LogPrintf(        \
	LOG_DEBUG,    \
	"LOG_COM_CHECK_ERROR(0x%X) at line %d in %s\n", (Condition), __LINE__, __FUNCTION__  \
	);                  \
}                       \
} while (false)
