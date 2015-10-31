#include "Precompiled.h"
#ifdef __linux__
#include "../include/Platform.h"
#include <sys/time.h>
#include <dlfcn.h>
#include <sys/resource.h>
#include <execinfo.h>

namespace platform
{
	uint64 g_startTick = 0;
	char g_szBacktraceFileName[512] = "";

	bool PlatFormInit()
	{
		g_startTick = get_tick64();

		//设置本进程core file
		struct rlimit limi;
		limi.rlim_cur = RLIM_INFINITY;
		limi.rlim_max = RLIM_INFINITY;
		if (setrlimit(RLIMIT_CORE, &limi) == -1)
			return false;
		return true;
	}

	uint32 get_tick()
	{
		struct timeval current;
		gettimeofday(&current, NULL);
		return (uint64)current.tv_sec * 1000 + (uint64)current.tv_usec / 1000 - g_startTick;
	}
	uint64 get_tick64()
	{
		struct timeval current;
		gettimeofday(&current, NULL);
		return (uint64)current.tv_sec * 1000 + (uint64)current.tv_usec / 1000 - g_startTick;
	}
	void* load_module(const char* szModule)
	{
		return dlopen(szModule, RTLD_NOW);
	}
	void free_module(void* mod)
	{
		dlclose(mod);
	}
	void* find_proc(void* mod, const char* szProc)
	{
		return dlsym(mod, szProc);
	}
	void sleep(uint32 ms)
	{
		usleep( ms * 1000);
	}
	void SetBacktraceFile(const char* pFileName)
	{
		strcpy(g_szBacktraceFileName, pFileName);
	}
	void Backtrace()
	{
		int j, nptrs;
		void *buffer[100];
		char **strings;

		if (!g_szBacktraceFileName[0])
			return;
		nptrs = backtrace(buffer, 100);
		strings = backtrace_symbols(buffer, nptrs);
		if (!strings)
			return;
		FILE* pFile = fopen(g_szBacktraceFileName, "a");
		if (!pFile)
		{
			free(strings);
			return;
		}
		fprintf(pFile, "=================================================================\n");

		for (j = 0; j < nptrs; ++j)
			fprintf(pFile, "%s\n", strings[j]);

		fprintf(pFile, "=================================================================\n");

		fclose(pFile);
		free(strings);
	}
	void LocalTime(time_t& tNow, struct tm& tmNow)
	{
		localtime_r(&tNow, &tmNow);
	}
}

#endif
