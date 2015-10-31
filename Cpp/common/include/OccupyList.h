#pragma once

class OccupyList
{
public:
	bool			Init(int nSize);
	void			UnInit();

	void			Occupy(int nIdx);	//ռ��ĳ��
	void			Free(int nIdx);		//�ͷ�ĳ��
	void			OccupyAll();		//ȫ����ռ��
	void			FreeAll();			//�ͷ�ȫ����

	int				IsOccupy(int nIdx);				//�ж�ĳ���Ƿ�ռ��
	int				GetFirstFree(int bOccupyIt);	//�õ���һ��δ��ռ�õ��������,���������ʾ�Ƿ�Ҫͬʱռ����
	int				GetOccupyCount() const { return m_nOccupyCount; }	//���ر�ռ�õ������Ŀ

	inline int		GetNext(int nIdx) const			//��ȡ��һ��ռ���������
	{ 
		if (nIdx >= 0 && nIdx < m_nTotalCount)
		{
			int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
			if (nIndexInList < m_nOccupyCount)
				return m_pNodeList[nIndexInList + 1].nItemIndex;
		}
		return 0;
	}

	inline int		GetPrev(int nIdx) const			//��ȡǰһ��ռ���������
	{
		if (nIdx >= 0 && nIdx < m_nTotalCount)
		{
			int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
			if (nIndexInList >= 1 && nIndexInList <= m_nOccupyCount)
				return m_pNodeList[nIndexInList - 1].nItemIndex;
		}
		return 0;
	}

	OccupyList()		{ m_pNodeList = NULL; m_nTotalCount = 0; m_nOccupyCount = 0;}
	~OccupyList()		{ UnInit(); }

private:
	struct		OccupyListNode
	{
		int		nItemIndex;				//�ýڵ��Ӧ���������
		int		nItemInListIndex;		//��ýڵ���ͬ���������ڽڵ���е�λ��
	};
	OccupyListNode*	m_pNodeList;	//�ڵ�����
	int					m_nTotalCount;	//�ڵ�����Ŀ
	int					m_nOccupyCount;	//ռ����Ŀ
};
