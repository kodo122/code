#include "Precompiled.h"
#include "../include/URandom.h"

#define IM 139968
#define IA 3877
#define IC 29573

//---------------------------------------------------------------------------
static unsigned int s_unRandomSeed = 42;
//---------------------------------------------------------------------------
// 函数:	RandomnSeed
// 功能:	设置随机数种子
// 参数:	s_nRandomSeed	:	随机数种子
// 返回:	void
//---------------------------------------------------------------------------
void URandomSeed(unsigned int nSeed)
{
	s_unRandomSeed = nSeed;
}
//---------------------------------------------------------------------------
// 函数:	Random
// 功能:	返回一个小于nMax的随机整数
// 参数:	nMax	:	最大值
// 返回:	一个小于nMax的随机数
//---------------------------------------------------------------------------
unsigned int URandom(unsigned int nMax)
{
	if (nMax)
	{
		s_unRandomSeed = s_unRandomSeed * IA + IC;
		return s_unRandomSeed % nMax;
	}
	else
	{
		return 0;
	}
}

//---------------------------------------------------------------------------
// 函数:	GetRandomSeed
// 功能:	取得当时的伪随机种子
// 返回:	返回当前的伪随机种子
//---------------------------------------------------------------------------
unsigned int UGetRandomSeed()
{
	return s_unRandomSeed;
}
