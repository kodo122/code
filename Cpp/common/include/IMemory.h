#pragma once

class IBuffer
{
public:
	virtual void* GetData() = 0;
	virtual unsigned GetSize() = 0;
	virtual unsigned GetReserveSize() = 0;
	virtual int SetSize(unsigned uNewSize) = 0;
	virtual int ResetSize() = 0;
	virtual int AddRef() = 0;
	virtual void Release() = 0;
};

class IAllocator
{
public:
	virtual void* Alloc(unsigned uSize) = 0;
	virtual void Free(void *pBuf) = 0;

	virtual IBuffer* AllocBuffer(unsigned uSize) = 0;

	template<class T>
	T* AllocObj()
	{
		void* m = Alloc(sizeof(T));
		if (m)
			return new(m) T;
		return NULL;
	}
	template<class T>
	void FreeObj(T *t)
	{
		t->~T();
		Free(t);
	}
};

IAllocator* CreateAllocator();
void DestroyAllocator(IAllocator* pAllocator);
