#pragma once
#include "IMemory.h"
#include "INetwork.h"
#include "IPacketParser.h"
#include "OccupyList.h"

enum
{
	len_head_size = 4,
	proto_head_size = 4,
};

class ProtoCBBase
{
public:
	virtual void Invoke(int proto, uint32 id, const void* pBuffer, int size) = 0;
};

template <class T>
class ProtoCB1 : public ProtoCBBase
{
public:
	ProtoCB1(T* pT, void (T::*pF)(int, uint32)) : m_pT(pT), m_pF(pF) {}
	void Invoke(int proto, uint32 id, const void* pBuffer, int size)
	{
		(m_pT->*m_pF)(proto, id);
	}
private:
	T* m_pT;
	void (T::*m_pF)(int, uint32);
};
template <class M, class T>
class ProtoCB2 : public ProtoCBBase
{
public:
	ProtoCB2(T* pT, void (T::*pF)(int, uint32, M&)) : m_pT(pT), m_pF(pF) {}
	void Invoke(int proto, uint32 id, const void* pBuffer, int size)
	{
		M m;
		if (m.Unserialize((const char*)pBuffer, size) && !size)
			(m_pT->*m_pF)(proto, id, m);
	}
private:
	T* m_pT;
	void (T::*m_pF)(int, uint32, M&);
};
template <class T>
class ProtoCB3 : public ProtoCBBase
{
public:
	ProtoCB3(T* pT, void (T::*pF)(int, uint32, const void* pBuffer, int size)) : m_pT(pT), m_pF(pF) {}
	void Invoke(int proto, uint32 id, const void* pBuffer, int size)
	{
		(m_pT->*m_pF)(proto, id, pBuffer, size);
	}
private:
	T* m_pT;
	void (T::*m_pF)(int, uint32, const void* pBuffer, int size);
};
template <class M, class T, class H>
class ProtoCB5 : public ProtoCBBase
{
public:
	ProtoCB5(T* pT, void (T::*pF)(int, uint32, H&, M&)) : m_pT(pT), m_pF(pF) {}
	void Invoke(int proto, uint32 id, const void* pBuffer, int size)
	{
		H headT;
		M m;
		int tempSize = size;
		if (headT.Unserialize((const char*)pBuffer, size)
			&& m.Unserialize((const char*)pBuffer + tempSize - size, size) && !size)
			(m_pT->*m_pF)(proto, id, headT, m);
	}
private:
	T* m_pT;
	void (T::*m_pF)(int, uint32, H&, M&);
};
template <class T, class H>
class ProtoCB6 : public ProtoCBBase
{
public:
	ProtoCB6(T* pT, void (T::*pF)(int, uint32, H&, const void* pBuffer, int size)) : m_pT(pT), m_pF(pF) {}
	void Invoke(int proto, uint32 id, const void* pBuffer, int size)
	{
		H headT;
		int tempSize = size;
		if (headT.Unserialize((const char*)pBuffer, size))
			(m_pT->*m_pF)(proto, id, headT, (const char*)pBuffer + tempSize - size, size);
	}
private:
	T* m_pT;
	void (T::*m_pF)(int, uint32, H&, const void* pBuffer, int size);
};

class ProtoCBManager
{
public:
	virtual ~ProtoCBManager() {};
	virtual bool Initialize(int nMaxProtoSize, bool isLogInvokeError = false, const char* pName = NULL);
	template <class T>
	bool RegProtoCB(int proto, T* pT, void (T::*pF)(int, uint32))
	{
		ProtoCBBase* cb = new ProtoCB1<T>(pT, pF);
		if (RegProtoCB(proto, cb))
			return true;
		delete cb;
		return false;
	}
	template <class M, class T>
	bool RegProtoCB(int proto, T* pT, void (T::*pF)(int, uint32, M&))
	{
		ProtoCBBase* cb = new ProtoCB2<M, T>(pT, pF);
		if (RegProtoCB(proto, cb))
			return true;
		delete cb;
		return false;
	}
	template <class T>
	bool RegProtoCB(int proto, T* pT, void (T::*pF)(int, uint32, const void*, int))
	{
		ProtoCBBase* cb = new ProtoCB3<T>(pT, pF);
		if (RegProtoCB(proto, cb))
			return true;
		delete cb;
		return false;
	}
	template <class M, class T, class H>
	bool RegProtoCB(int proto, T* pT, void (T::*pF)(int, uint32, H&, M&))
	{
		ProtoCBBase* cb = new ProtoCB5<M, T, H>(pT, pF);
		if (RegProtoCB(proto, cb))
			return true;
		delete cb;
		return false;
	}
	template <class T, class H>
	bool RegProtoCB(int proto, T* pT, void (T::*pF)(int, uint32, H&, const void*, int))
	{
		ProtoCBBase* cb = new ProtoCB6<T, H>(pT, pF);
		if (RegProtoCB(proto, cb))
			return true;
		delete cb;
		return false;
	}

	bool RegProtoCB(int proto, ProtoCBBase* cb);
	bool Invoke(uint32 id, const char* pBuffer, uint32 size);
	void Invoke(int proto, uint32 id, const char* pBuffer, uint32 size);
private:
	bool m_bIsLogInvokeError;
	const char* m_pName;
	int m_nMaxProtoSize;
	ProtoCBBase** m_protoCB;
};

class EventCBBase
{
public:
	virtual void Handle(const NetEvent* pNetEvent) = 0;
};

template <class T>
class EventCB : public EventCBBase
{
public:
	EventCB(T* pT, void (T::*pF)(const NetEvent*)) : m_pT(pT), m_pF(pF) {}
	void Handle(const NetEvent* pNetEvent)
	{
		(m_pT->*m_pF)(pNetEvent);
	}
private:
	T* m_pT;
	void (T::*m_pF)(const NetEvent*);
};

class NetCenter
{
	enum
	{
		re_record_recv_sec = 5,
		recv_time_out_sec = 60,
		ping_sec = 30,
	};
	struct _IoData
	{
		_IoData() : bNotHandleData(false), pEventCB(NULL), pPacketParser(NULL), pProtoCB(NULL), 
					bTimeOutJudge(false), uLastRecvSec(0), isPing(false), uLastSendSec(0) {}
		bool bNotHandleData;
		bool bTimeOutJudge;
		bool isPing;
		uint32 uLastSendSec;
		std::list<uint32>::iterator lastPingIt;
		uint32 uLastRecvSec;
		std::list<uint32>::iterator lastRecvIt;
		EventCBBase* pEventCB;
		IPacketParser* pPacketParser;
		ProtoCBManager* pProtoCB;
	};
public:
	NetCenter(){}
	bool Initialize(uint32 uMaxIoSize);
	void Update();
	uint32 RegListener(const char cszIPAddress[], int nPort, int nMaxAcceptIoCount, int nMaxAcceptEachWait, EventCBBase *pEventCB);
	uint32 Connect(const char cszIPAddress[], int nPort, EventCBBase *pEventCB);
	bool RegRW(uint32 id, uint32 uMaxPacketSize, bool useSendList, ProtoCBManager* pProtoCB, EventCBBase *pEventCB = NULL, 
		bool bTimeOutJudge = false, bool isPing = false, bool isEncode = false);
	bool RegRawSockRW(uint32 id, uint32 uMaxSizeEachRecv, bool useSendList, EventCBBase *pEventCB = NULL);
	bool SetEncryptKey(uint32 id, uint32 uKey);
	void SendBuffer(uint32 id, IBuffer *pBuffer);
	void SendBuffer(uint32 id, const void* pBuffer, uint32 size);
	void SendBuffer(uint32 id, int proto, IBuffer *pBuffer);
	void SendBuffer(uint32 id, int proto, const void* pBuffer, uint32 size);
	template<class H>
	void SendBuffer(uint32 id, int proto, H& head, IBuffer *pBuffer)
	{
		SendBuffer(id, proto, head, pBuffer->GetData(), pBuffer->GetSize());
	}
	template<class H>	
	void SendBuffer(uint32 id, int proto, H& head, const void* pBuffer, uint32 size)
	{
		int nRetCode = 0;
		uint32 totalSize = 0;
		uint32 headSize = head.Size();
		IBuffer *pHeadBuffer = m_pAllocator->AllocBuffer(headSize);
		head.Serialize((char*)pHeadBuffer->GetData(), headSize);
		totalSize = size + headSize + proto_head_size + len_head_size;
		m_pNet->Send(id, &totalSize, sizeof(totalSize));
		m_pNet->Send(id, &proto, sizeof(proto));
		m_pNet->Send(id, pHeadBuffer->GetData(), pHeadBuffer->GetSize());
		m_pNet->Send(id, pBuffer, size);
Exit0:
		if (pHeadBuffer)
			COM_RELEASE(pHeadBuffer);
	}
	void SendProto(uint32 id, int proto);
	template <class M>
	void SendProto(uint32 id, int proto, M &m)
	{
		int nRetCode = 0;
		uint32 size = m.Size();
		IBuffer *pBuffer = m_pAllocator->AllocBuffer(size + proto_head_size);
		*(int*)pBuffer->GetData() = proto;
		m.Serialize((char*)pBuffer->GetData() + proto_head_size, size);
		SendBuffer(id, pBuffer);
Exit0:		
		COM_RELEASE(pBuffer);
	}
	template <class M, class H>
	void SendProto(uint32 id, int proto, H& head, M &m)
	{
		int nRetCode = 0;
		uint32 size = m.Size();
		IBuffer *pBuffer = m_pAllocator->AllocBuffer(size);
		m.Serialize((char*)pBuffer->GetData(), size);
		SendBuffer(id, proto, head, pBuffer);
Exit0:
		COM_RELEASE(pBuffer);
	}
	void SendRawBuffer(uint32 id, void* pBuffer, uint32 size);
	void Close(uint32 id);
private:
	void _RefreshRecvSec(uint32 id);
private:
	std::vector<NetEvent> m_TimeOutEventVec; 
	std::list<uint32> m_RecvSecList;
	std::list<uint32> m_SendSecList;

	uint32 m_uMaxIoSize;
	_IoData* m_IoData;
	OccupyList m_CloseOccupyList;
	class IAllocator* m_pAllocator;
	class INetwork* m_pNet;
};
