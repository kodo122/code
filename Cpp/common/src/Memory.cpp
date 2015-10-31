#include "Precompiled.h"
#include "../include/IMemory.h"

class MemManager
{
	struct _LIST_ENTRY 
	{
		struct _LIST_ENTRY *Next;
	};
	struct _MemSection 
	{
		_LIST_ENTRY	*pNext;
		unsigned	nSize;
		void*		pData[];
	};
	struct _MemList
	{
		unsigned	uSectionMaxSize;
		unsigned	uCount;
		_LIST_ENTRY list;
	};
public:
	MemManager();
	void* Alloc(unsigned uSize, unsigned uId = 0);
	void Free(void* pSection, unsigned uId = 0);
	bool Initialize(unsigned sizeArrayCount, unsigned *pSizeArray, bool useHashLocateSize = false);
	void Release();

	long GetAllocatedCount();

private:
	static bool	_MemListCompare(const _MemList& ml1, const _MemList& ml2);

	_MemList *m_MemListArray;

	unsigned m_uSizeArrayCount;
	unsigned *m_uSizeArray;

	bool m_useHashLocateSize;
	unsigned m_theMaxSize;
	char *m_SizeLocationHash;
};

MemManager::MemManager()
{
	m_MemListArray = NULL;
	m_uSizeArrayCount = 0;
	m_uSizeArray = NULL;
	m_useHashLocateSize = false;
	m_theMaxSize = 0;
	m_SizeLocationHash = NULL;
}

bool MemManager::Initialize( unsigned sizeArrayCount, unsigned *pSizeArray, bool useHashLocateSize )
{
	m_useHashLocateSize = useHashLocateSize;
	m_uSizeArrayCount = sizeArrayCount;

	m_uSizeArray = new unsigned[sizeArrayCount];
	if (!m_uSizeArray)
		return false;

	m_MemListArray = new _MemList[sizeArrayCount];
	if (!m_MemListArray)
		return false;

	for (unsigned i = 0; i < m_uSizeArrayCount; ++i)
	{
		m_uSizeArray[i] = pSizeArray[i];
		m_MemListArray[i].uSectionMaxSize = pSizeArray[i];
		m_MemListArray[i].list.Next = NULL;
		m_MemListArray[i].uCount = 0;
	}
	std::sort(m_MemListArray, m_MemListArray + m_uSizeArrayCount, _MemListCompare);

	if (useHashLocateSize)
	{
		m_theMaxSize = m_MemListArray[m_uSizeArrayCount - 1].uSectionMaxSize;
		m_SizeLocationHash = new char[m_theMaxSize + 1];
		if (!m_SizeLocationHash)
			return false;
		for (int i = 0, location = 0; i <= m_theMaxSize; ++i)
		{
			if (i > m_MemListArray[location].uSectionMaxSize)
				++location;
			m_SizeLocationHash[i] = location;
		}
	}
	return true;
}

void MemManager::Release()
{
	if (!m_uSizeArray || !m_MemListArray)
		return;

	for (unsigned i = 0; i < m_uSizeArrayCount; ++i)
	{
		_MemSection *pDelete = NULL;
		_MemSection *pMemSection = CONTAINING_RECORD(m_MemListArray[i].list.Next, _MemSection, pNext);	

		while (pMemSection)
		{
			pDelete = pMemSection;
			pMemSection = CONTAINING_RECORD(pMemSection->pNext, _MemSection, pNext);
			delete[] pDelete;
		}
	}

	if (m_SizeLocationHash)
		delete[] m_SizeLocationHash;
	m_SizeLocationHash = NULL;
	delete[] m_uSizeArray;
	m_uSizeArray = NULL; 
	delete[] m_MemListArray;
	m_MemListArray = NULL;
}

bool MemManager::_MemListCompare( const _MemList& ml1, const _MemList& ml2 )
{
	return ml1.uSectionMaxSize < ml2.uSectionMaxSize;
}

void* MemManager::Alloc( unsigned uSize, unsigned uId )
{
	_MemSection *pMemSection = NULL;
	_MemList *pMemList = NULL;
	_MemList memListKey;
	unsigned uAllocSize = sizeof(_MemSection) + uSize;
	memListKey.uSectionMaxSize = uAllocSize;

	if (m_useHashLocateSize)
	{
		if (uAllocSize > m_theMaxSize)
			pMemList = m_MemListArray + m_uSizeArrayCount;
		else
			pMemList = m_MemListArray + m_SizeLocationHash[uAllocSize];
	}
	else
		pMemList = std::lower_bound(m_MemListArray, m_MemListArray + m_uSizeArrayCount, memListKey, _MemListCompare);

	if (pMemList == m_MemListArray + m_uSizeArrayCount)
	{
		pMemSection = (_MemSection*)malloc(uAllocSize);
	}
	else
	{
		if (pMemList->list.Next)
		{
			pMemSection = CONTAINING_RECORD(pMemList->list.Next, _MemSection, pNext);				
			pMemList->list.Next = pMemList->list.Next->Next;
			--pMemList->uCount;
		}
		else
		{
			pMemSection = (_MemSection*)malloc(pMemList->uSectionMaxSize);
		}
	}

	if (pMemSection)
	{
		pMemSection->nSize = uSize;
		return pMemSection->pData;
	}
	return NULL;
}

void MemManager::Free( void* pSection, unsigned uId )
{
	_MemSection *pMemSection = CONTAINING_RECORD(pSection, _MemSection, pData);
	_MemList *pMemList = NULL;
	_MemList memListKey;
	memListKey.uSectionMaxSize = sizeof(_MemSection) + pMemSection->nSize;

	if (m_useHashLocateSize)
	{
		if (memListKey.uSectionMaxSize > m_theMaxSize)
			pMemList = m_MemListArray + m_uSizeArrayCount;
		else
			pMemList = m_MemListArray + m_SizeLocationHash[memListKey.uSectionMaxSize];
	}
	else
		pMemList = std::lower_bound(m_MemListArray, m_MemListArray + m_uSizeArrayCount, memListKey, _MemListCompare);

	if (pMemList == m_MemListArray + m_uSizeArrayCount)
	{
		free((char*)pMemSection);
	}
	else
	{
		pMemSection->pNext = pMemList->list.Next;
		pMemList->list.Next = (_LIST_ENTRY*)pMemSection;

		++pMemList->uCount;
	}
}

#define MEMORY_BUFFER_RESERVE_SIZE   8

class CBuffer : public IBuffer
{
public:
	void* GetData() { return m_pvData; }
	unsigned GetSize() { return m_uSize; }
	unsigned GetReserveSize() { return MEMORY_BUFFER_RESERVE_SIZE; }
	int ResetSize() { m_uSize = m_uOrignSize; return true; }
	int SetSize(unsigned uNewSize)
	{
		if (uNewSize > m_uOrignSize)
			return false;
		m_uSize = uNewSize;
		return true;
	}
	void Release()
	{
		if (--m_nRefCount > 0)
			return;
		this->~CBuffer();
		m_pAllocator->Free((void*)this);
	}
	int AddRef() { return ++m_nRefCount; }
	CBuffer(unsigned uSize, void *pvData, IAllocator* pAllocator):
	m_uOrignSize(uSize), m_uSize(uSize), m_pvData(pvData), m_pAllocator(pAllocator), m_nRefCount(1)
	{}

private:  
	~CBuffer() { }    //make sure class CBuffer only use for new

	unsigned m_uOrignSize;
	unsigned m_uSize;
	void* m_pvData;
	IAllocator* m_pAllocator;
	int m_nRefCount;
};

class Allocator : public IAllocator
{
public:
	bool Initialize();
	void Release();
	void* Alloc(unsigned uSize);
	virtual void Free(void *pBuf);
	IBuffer* AllocBuffer(unsigned uSize);

private:
	MemManager m_MemManager;
};

bool Allocator::Initialize()
{
	int nResult = 0;
	int nRetCode = 0;
	unsigned init_list[] = 
	{
		8, 
		2 * 8,
		3 * 8,
		4 * 8,
		5 * 8,
		6 * 8,
		7 * 8,
		8 * 8,
		16 * 8,
		32 * 8,
		64 * 8,
		128 * 8,
		256 * 8,
		512 * 8,
		1024 * 8,
		2048 * 8,
		4096 * 8,
		8192 * 8 + 64,
	};
	int nListCount = sizeof(init_list) / sizeof(init_list[0]);

	nRetCode = m_MemManager.Initialize(nListCount, init_list, true);
	PROCESS_ERROR(nRetCode);

	nResult = 1;
Exit0:
	return nResult;
}

void Allocator::Release()
{
	m_MemManager.Release();
}

void* Allocator::Alloc( unsigned uSize )
{
	return m_MemManager.Alloc(uSize);
}

void Allocator::Free( void *pBuf )
{
	m_MemManager.Free(pBuf);
}

IBuffer* Allocator::AllocBuffer( unsigned uSize )
{
	int         nRetCode    = false;
	unsigned    uBuffSize   = 0;
	void       *pvBuffer    = NULL;
	void       *pvData      = NULL;
	CBuffer  *pBuffer     = NULL;

	assert(uSize);
	uBuffSize = uSize + sizeof(CBuffer) + MEMORY_BUFFER_RESERVE_SIZE;
	assert(uBuffSize > sizeof(CBuffer) + MEMORY_BUFFER_RESERVE_SIZE && "It seems that uSize is negative!");

	pvBuffer = m_MemManager.Alloc(uBuffSize);
	PROCESS_ERROR(pvBuffer);

	pvData = (void *)(((unsigned char *)pvBuffer) + sizeof(CBuffer) + MEMORY_BUFFER_RESERVE_SIZE);

	pBuffer = new(pvBuffer)CBuffer(uSize, pvData, this);  // placement operator new
Exit0:
	return pBuffer;
}

IAllocator* CreateAllocator()
{
	Allocator *pAllocator = new Allocator;
	if (pAllocator)
	{
		if (pAllocator->Initialize())
			return pAllocator;
	}
	if (pAllocator)
		delete pAllocator;
	return NULL;
}

void DestroyAllocator(IAllocator* pAllocator)
{
	((Allocator*)pAllocator)->Release();
	delete pAllocator;
}
