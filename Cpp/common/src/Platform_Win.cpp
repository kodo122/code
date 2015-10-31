#include "Precompiled.h"
#ifdef WIN32
#include "../include/Platform.h"

namespace platform
{
	bool PlatFormInit()
	{
		return true;
	}
	uint32 get_tick()
	{
		return GetTickCount();
	}
	uint64 get_tick64()
	{	//TODO
		return GetTickCount();
	}
	void* load_module(const char* szModule)
	{
		return LoadLibrary(szModule);
	}
	void free_module(void* mod)
	{
		FreeLibrary((HMODULE)mod);
	}
	void* find_proc(void* mod, const char* szProc)
	{
		return GetProcAddress((HMODULE)mod, szProc);
	}
	void sleep(uint32 ms)
	{
		Sleep(ms);
	}
	void SetBacktraceFile(const char* pFileName) {}
	void Backtrace() {}
	void LocalTime(time_t& tNow, struct tm& tmNow)
	{
		localtime_s(&tmNow, &tNow);
	}
}

#endif
