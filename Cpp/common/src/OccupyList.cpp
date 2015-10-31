#include "Precompiled.h"
#include "../include/OccupyList.h"

void OccupyList::UnInit()
{
	if (m_pNodeList) 
	{
		free(m_pNodeList);
		m_pNodeList = NULL;
		m_nTotalCount = 0;
		m_nOccupyCount = 0;
	}
}

bool OccupyList::Init(int nSize)
{
	if (nSize == m_nTotalCount)
	{
		FreeAll();
	}
	else
	{
		UnInit();
		m_pNodeList = (OccupyListNode*)malloc(sizeof(OccupyListNode) * nSize);
		if (m_pNodeList)
		{
			m_nTotalCount = nSize;
			for (int i = 0; i < m_nTotalCount; i++)
			{
				m_pNodeList[i].nItemIndex = i;
				m_pNodeList[i].nItemInListIndex = i;
			}
		}
	}
	return (m_pNodeList != NULL);
}

void OccupyList::Free(int nIdx)
{
	if (nIdx > 0 && nIdx < m_nTotalCount)
	{
		int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
		if (nIndexInList <= m_nOccupyCount)
		{
			if (nIndexInList != m_nOccupyCount)
			{
				m_pNodeList[nIndexInList].nItemIndex = m_pNodeList[m_nOccupyCount].nItemIndex;
				m_pNodeList[m_nOccupyCount].nItemIndex = nIdx;
				m_pNodeList[nIdx].nItemInListIndex = m_nOccupyCount;
				m_pNodeList[m_pNodeList[nIndexInList].nItemIndex].nItemInListIndex = nIndexInList;
			}
			m_nOccupyCount --;
		}
		//else already remove
	}
	else
	{
		printf("[error]Remove invalid node: index %d, size %d", nIdx, m_nTotalCount);
	}
}

void OccupyList::Occupy(int nIdx)
{
	if (nIdx > 0 && nIdx < m_nTotalCount)
	{
		int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
		if (nIndexInList > m_nOccupyCount)
		{
			m_nOccupyCount++;
			if (nIndexInList > m_nOccupyCount)
			{
				m_pNodeList[nIndexInList].nItemIndex = m_pNodeList[m_nOccupyCount].nItemIndex;
				m_pNodeList[m_nOccupyCount].nItemIndex = nIdx;
				m_pNodeList[nIdx].nItemInListIndex = m_nOccupyCount;
				m_pNodeList[m_pNodeList[nIndexInList].nItemIndex].nItemInListIndex = nIndexInList;
			}
		}
		//else already in occupy
	}
	else
	{
		printf("[error]Insert invalid node: index %d, size %d", nIdx, m_nTotalCount);
	}
}

//occupy全部项
void OccupyList::OccupyAll()
{
	if (m_nTotalCount > 0)
		m_nOccupyCount = m_nTotalCount - 1;
}

//释放全部项
void OccupyList::FreeAll()
{
	m_nOccupyCount = 0;
}

//判断某项是否被占用
int	OccupyList::IsOccupy(int nIdx)
{
	if (nIdx > 0 && nIdx < m_nTotalCount)
	{
		int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
		if (nIndexInList <= m_nOccupyCount && nIndexInList > 0)
			return true;
	}
	return false;
}

//得到第一个未被占用的项的索引
int OccupyList::GetFirstFree(int bOccupyIt)
{
	if (m_nOccupyCount < m_nTotalCount - 1)
	{
		int nRet = m_pNodeList[m_nOccupyCount + 1].nItemIndex;
		if (bOccupyIt)
			m_nOccupyCount++;
		return nRet;
	}
	else
	{
		return 0;
	}
}


