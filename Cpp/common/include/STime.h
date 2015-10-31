#pragma once

class CTimer
{
public:
	static uint32 GetTick();
	static void SetTime();
	static uint32 GetTime();
	static bool IsSameDay(uint32 uTime);
	static bool IsSameDay(uint32 uTime1, uint32 uTime2);
	static uint32 ConvertTimeStrToUint(const char* uDay);
	static void ConvertTimeToStr(time_t uTime, char* pcszBuffer, size_t uSize);
	static int CalculateDayInterval(uint32 uTime);
	static int GetYear();
	static int GetMon();
	static int GetMDay();
	static int GetWeek(); //0-6 since Sunday
	static int GetHour(); //0-23 since midnight
	static int GetMinute(); //0-59
	static int GetSecond(); //0-59
	static bool IsClockSharp(); //ÊÇ·ñÕûµã
	static bool IsSecTimeOut(int startSec, int timeOutNeedSec);
public:
	CTimer();
	CTimer(int timeoutNeed);
	~CTimer() {};
	void Reset();
	bool IsTimeOut();
	void SetTimeOutTick(int timeoutNeed);
private:
	bool m_isFirstTime;
	unsigned int m_timeoutNeed;
	unsigned int m_tick;
};

