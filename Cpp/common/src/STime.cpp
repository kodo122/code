#include "Precompiled.h"
#include "../include/STime.h"
#include "../include/Platform.h"

uint32 CTimer::GetTick()
{
	return platform::get_tick();
}

time_t g_now = 0;
int g_year = -1;
int g_mon = -1;
int g_mday = -1;
int g_week = -1;
int g_hour = -1;
int g_minute = -1;
int g_second = -1;
enum
{
	second_per_day = 24 * 3600,
};

void CTimer::SetTime()
{
	g_now = time(NULL);
	time_t tNow = g_now;
	struct tm *p_tNow = localtime(&tNow);
	if (!p_tNow)
		return;
	g_year = p_tNow->tm_year;
	g_mon = p_tNow->tm_mon;
	g_mday = p_tNow->tm_mday;
	g_week = p_tNow->tm_wday;
	g_hour = p_tNow->tm_hour;
	g_minute = p_tNow->tm_min;
	g_second = p_tNow->tm_sec;
}

uint32 CTimer::GetTime()
{
	return g_now ? g_now : time(NULL);
}

bool CTimer::IsSameDay( uint32 uTime )
{
	return IsSameDay(GetTime(), uTime);
}

bool CTimer::IsSameDay( uint32 uTime1, uint32 uTime2 )
{
	if (!uTime1 || !uTime2)
		return false;
	time_t t1 = uTime1;
	time_t t2 = uTime2;
	struct tm tm1, tm2;

	platform::LocalTime(t1, tm1);
	platform::LocalTime(t2, tm2);

	if (tm1.tm_year == tm2.tm_year
		&& tm1.tm_mon == tm2.tm_mon
		&& tm1.tm_mday == tm2.tm_mday)
		return true;
	return false;
}

uint32 CTimer::ConvertTimeStrToUint(const char* uDay)
{
	struct tm p_tNow;
	memset(&p_tNow, 0, sizeof(p_tNow));
	if (!uDay)
		return 0;
	int tYear = 0;
	int tMon = 0;
	int tDay = 0;
	int tHour = 0;
	int tMinute = 0;
	int tSecond = 0;

	if (6 != sscanf(uDay, "%d%*c%d%*c%d%*c%d%*c%d%*c%d", &tYear, &tMon, &tDay, &tHour, &tMinute, &tSecond) &&
		5 != sscanf(uDay, "%d%*c%d%*c%d%*c%d%*c%d", &tYear, &tMon, &tDay, &tHour, &tMinute) &&
		3 != sscanf(uDay, "%d%*c%d%*c%d", &tYear, &tMon, &tDay))
		return 0;
	p_tNow.tm_hour = tHour;
	p_tNow.tm_min = tMinute;
	p_tNow.tm_sec = tSecond;
	p_tNow.tm_mon = tMon - 1;
	p_tNow.tm_mday = tDay;
	p_tNow.tm_year = tYear - 1900;

	return mktime(&p_tNow);
}

void CTimer::ConvertTimeToStr(time_t uTime, char* pcszBuffer, size_t uSize)
{
	struct tm tmTime = { 0 };

	localtime_r(&uTime, &tmTime);

	snprintf(pcszBuffer,uSize,"%.4d-%.2d-%.2d %.2d:%.2d:%.2d",
		tmTime.tm_year + 1900, tmTime.tm_mon + 1, tmTime.tm_mday, 
		tmTime.tm_hour, tmTime.tm_min, tmTime.tm_sec);

	pcszBuffer[uSize - 1] = '\0';
}

int CTimer::CalculateDayInterval(uint32 uTime)
{
	if (!uTime)
		return -1;
	uint32 tNow = GetTime();
	if (IsSameDay(uTime, tNow))
		return 0;
	int32 tInterval = tNow - uTime;
	if (tInterval < 0)
		tInterval = -tInterval;
	int wholeDay = tInterval / second_per_day;
	uint32 tempTime = 0;
	if (tNow > uTime)
	{
		tempTime = uTime + wholeDay * second_per_day;
		if (!IsSameDay(tempTime, tNow))
			wholeDay++;
	}
	else
	{
		tempTime = tNow + wholeDay * second_per_day;
		if (!IsSameDay(tempTime, uTime))
			wholeDay++;
	}
	return wholeDay;
}

int CTimer::GetYear()
{
	return g_year;
}

int CTimer::GetMon()
{
	return g_mon;
}

int CTimer::GetMDay()
{
	return g_mday;
}

int CTimer::GetWeek()
{
	return g_week;
}

int CTimer::GetHour()
{
	return g_hour;
}

int CTimer::GetMinute()
{
	return g_minute;
}

int CTimer::GetSecond()
{
	return g_second;
}

bool CTimer::IsClockSharp()
{
	time_t tNow = time(NULL);
	struct tm tmNow;

	platform::LocalTime(tNow, tmNow);

	if (tmNow.tm_min == 0 && tmNow.tm_sec == 0)
		return true;
	return false;
}

bool CTimer::IsSecTimeOut( int startSec, int timeOutNeedSec )
{
	return GetTime() - (uint32)startSec >= timeOutNeedSec;
}

CTimer::CTimer()
{
}

CTimer::CTimer( int timeoutNeed )
{
	SetTimeOutTick(timeoutNeed);
}

void CTimer::Reset()
{
	m_tick = GetTick();
	m_isFirstTime = false;
}

bool CTimer::IsTimeOut()
{
	return m_isFirstTime ? true : (GetTick() - m_tick >= m_timeoutNeed); 
}

void CTimer::SetTimeOutTick( int timeoutNeed )
{
	m_timeoutNeed = timeoutNeed;
	m_tick = 0;
	m_isFirstTime = true;
}
