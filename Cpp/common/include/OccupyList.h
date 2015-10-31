#pragma once

class OccupyList
{
public:
	bool			Init(int nSize);
	void			UnInit();

	void			Occupy(int nIdx);	//占用某项
	void			Free(int nIdx);		//释放某项
	void			OccupyAll();		//全部项占用
	void			FreeAll();			//释放全部项

	int				IsOccupy(int nIdx);				//判断某项是否被占用
	int				GetFirstFree(int bOccupyIt);	//得到第一个未被占用的项的索引,传入参数表示是否要同时占用它
	int				GetOccupyCount() const { return m_nOccupyCount; }	//返回被占用的项的数目

	inline int		GetNext(int nIdx) const			//获取下一个占用项的索引
	{ 
		if (nIdx >= 0 && nIdx < m_nTotalCount)
		{
			int nIndexInList = m_pNodeList[nIdx].nItemInListIndex;
			if (nIndexInList < m_nOccupyCount)
				return m_pNodeList[nIndexInList + 1].nItemIndex;
		}
		return 0;
	}

	inline int		GetPrev(int nIdx) const			//获取前一个占用项的索引
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
		int		nItemIndex;				//该节点对应的项的索引
		int		nItemInListIndex;		//与该节点相同索引的项在节点表中的位置
	};
	OccupyListNode*	m_pNodeList;	//节点数组
	int					m_nTotalCount;	//节点总数目
	int					m_nOccupyCount;	//占用数目
};
