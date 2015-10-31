#include "Precompiled.h"
#include "../include/URandom.h"

#define IM 139968
#define IA 3877
#define IC 29573

//---------------------------------------------------------------------------
static unsigned int s_unRandomSeed = 42;
//---------------------------------------------------------------------------
// ����:	RandomnSeed
// ����:	�������������
// ����:	s_nRandomSeed	:	���������
// ����:	void
//---------------------------------------------------------------------------
void URandomSeed(unsigned int nSeed)
{
	s_unRandomSeed = nSeed;
}
//---------------------------------------------------------------------------
// ����:	Random
// ����:	����һ��С��nMax���������
// ����:	nMax	:	���ֵ
// ����:	һ��С��nMax�������
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
// ����:	GetRandomSeed
// ����:	ȡ�õ�ʱ��α�������
// ����:	���ص�ǰ��α�������
//---------------------------------------------------------------------------
unsigned int UGetRandomSeed()
{
	return s_unRandomSeed;
}
