#pragma once

namespace platform
{
	bool PlatFormInit();
	uint32 get_tick();
	uint64 get_tick64();
	void* load_module(const char* szModule);
	void free_module(void* mod);
	void* find_proc(void* mod, const char* szProc);
	void sleep(uint32 ms);

	void SetBacktraceFile(const char* pFileName);
	void Backtrace();

	void LocalTime(time_t& tNow, struct tm& tmNow);
}
