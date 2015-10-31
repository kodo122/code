#include "Precompiled.h"
#include "../include/NetCenter.h"
#include "../include/Log.h"
#include "../include/STime.h"

bool ProtoCBManager::Initialize( int nMaxProtoSize, bool isLogInvokeError /*= false*/, const char* pName /*= NULL*/ )
{
	m_nMaxProtoSize = nMaxProtoSize;
	m_bIsLogInvokeError = isLogInvokeError;
	m_pName = pName;
	if (!m_pName)
		m_pName = "";
	m_protoCB = new ProtoCBBase*[nMaxProtoSize];
	if (!m_protoCB)
		return false;
	memset(m_protoCB, 0, sizeof(ProtoCBBase*) * nMaxProtoSize);
	return true;
}

bool ProtoCBManager::RegProtoCB( int proto, ProtoCBBase* cb )
{
	if (!cb)
		return false;
	if (proto <= 0 || proto >= m_nMaxProtoSize)
		return false;
	if (m_protoCB[proto])
		return false;
	m_protoCB[proto] = cb;
	return true;
}

bool ProtoCBManager::Invoke( uint32 id, const char* pBuffer, uint32 size )
{
	if (size < proto_head_size)
		return false;
	int proto = *(int*)pBuffer;

	if (!proto)
		return true;
	
	if (proto > 0 && proto < m_nMaxProtoSize && m_protoCB[proto])
		m_protoCB[proto]->Invoke(proto, id, pBuffer + proto_head_size, size - proto_head_size);
	else if (m_bIsLogInvokeError)
		LogPrintf(LOG_WARNING, "%s recv error proto : %d, netid : %d", m_pName, proto, id);
	return true;
}

void ProtoCBManager::Invoke( int proto, uint32 id, const char* pBuffer, uint32 size )
{
	if (proto >= 0 && proto < m_nMaxProtoSize && m_protoCB[proto])
		m_protoCB[proto]->Invoke(proto, id, pBuffer, size);
	else if (m_bIsLogInvokeError)
		LogPrintf(LOG_WARNING, "%s recv error proto : %d, netid : %d", m_pName, proto, id);
}

bool NetCenter::Initialize( uint32 uMaxIoSize )
{
	m_uMaxIoSize = uMaxIoSize;
	m_IoData = new _IoData[uMaxIoSize];
	if (!m_IoData)
		return false;
	m_pAllocator = CreateAllocator();
	m_pNet = CreateNetwork();
	if (!m_pAllocator || !m_pNet)
		return false;
	if (!m_pNet->Initialize(m_pAllocator, m_uMaxIoSize))
		return false;
	if (!m_CloseOccupyList.Init(m_uMaxIoSize))
		return false;
	return true;
}

void NetCenter::Update()
{
	int nRetCode = 0;

	m_pNet->Update();
	m_CloseOccupyList.FreeAll();

	const NetEvent* pNetEvent;
	while (pNetEvent = m_pNet->PopEvent())
	{
		if (m_CloseOccupyList.IsOccupy(pNetEvent->id))
			continue;

		if (pNetEvent->eventType == NetEvent::event_recv)
		{
			if (m_IoData[pNetEvent->id].bNotHandleData)
			{
				m_IoData[pNetEvent->id].pEventCB->Handle(pNetEvent);
				_RefreshRecvSec(pNetEvent->id);
				continue;
			}

			m_IoData[pNetEvent->id].pPacketParser->PushBuffer(pNetEvent->pIBuffer);
			do
			{
				IBuffer* pBuffer = NULL;
				bool bIsDataError = false;
				int proto = 0;
				nRetCode = m_IoData[pNetEvent->id].pPacketParser->PopPacket(pBuffer);
				if (nRetCode == 1)
				{
					bIsDataError = !m_IoData[pNetEvent->id].pProtoCB->Invoke(pNetEvent->id, (char*)pBuffer->GetData(), pBuffer->GetSize());
					COM_RELEASE(pBuffer);
					_RefreshRecvSec(pNetEvent->id);
				}
				else if (nRetCode == 0)
					break;
				else
					bIsDataError = true;

				if (bIsDataError)
				{
					NetEvent errorEvent;
					errorEvent.eventType = NetEvent::event_error;
					errorEvent.id = pNetEvent->id;
					errorEvent.errorCode = NetEvent::error_data_error;
					m_IoData[pNetEvent->id].pEventCB->Handle(&errorEvent);
					break;
				}
			} while (!m_CloseOccupyList.IsOccupy(pNetEvent->id));
		}
		else
			m_IoData[pNetEvent->id].pEventCB->Handle(pNetEvent);
	}

	for (std::list<uint32>::iterator it = m_RecvSecList.begin(); it != m_RecvSecList.end(); ++it)
	{
		uint32 id = *it;
		if (CTimer::GetTime() - m_IoData[id].uLastRecvSec < recv_time_out_sec)
			break;
		NetEvent errorEvent;
		errorEvent.eventType = NetEvent::event_error;
		errorEvent.id = id;
		errorEvent.errorCode = NetEvent::error_time_out;
		m_TimeOutEventVec.push_back(errorEvent);
	}

	for (std::vector<NetEvent>::iterator it = m_TimeOutEventVec.begin(); it != m_TimeOutEventVec.end(); ++it)
	{
		const NetEvent* pEvnet = &(*it);
		if (m_CloseOccupyList.IsOccupy(pEvnet->id))
			continue;
		m_IoData[pEvnet->id].pEventCB->Handle(pEvnet);
	}

	m_TimeOutEventVec.clear();

	for (std::list<uint32>::iterator it = m_SendSecList.begin(); it != m_SendSecList.end();)
	{
		uint32 id = *it;
		if (CTimer::GetTime() - m_IoData[id].uLastSendSec < ping_sec)
			break;
		SendProto(id, 0);
		it = m_SendSecList.erase(it);
		m_SendSecList.push_back(id);
		m_IoData[id].lastPingIt = --m_SendSecList.end();
		m_IoData[id].uLastSendSec = CTimer::GetTime();
	}

	m_pNet->Flush();
}

uint32 NetCenter::RegListener( const char cszIPAddress[], int nPort, int nMaxAcceptIoCount, int nMaxAcceptEachWait, EventCBBase *pEventCB )
{
	uint32 id = m_pNet->RegisterListener(cszIPAddress, nPort, nMaxAcceptIoCount, nMaxAcceptEachWait);
	if (!id)
		return 0;
	m_IoData[id].pEventCB = pEventCB;
	return id;
}

bool NetCenter::RegRW( uint32 id, uint32 uMaxPacketSize, bool useSendList, ProtoCBManager* pProtoCB, EventCBBase *pEventCB, 
	bool bTimeOutJudge, bool isPing, bool isEncode )
{
	if (pEventCB)
		m_IoData[id].pEventCB = pEventCB;
	m_pNet->RegisterRWSocket(id, uMaxPacketSize, useSendList);
	
	m_IoData[id].bTimeOutJudge = bTimeOutJudge;
	if (bTimeOutJudge)
	{
		m_RecvSecList.push_back(id);
		m_IoData[id].lastRecvIt = --m_RecvSecList.end();
		m_IoData[id].uLastRecvSec = CTimer::GetTime();
	}

	m_IoData[id].isPing = isPing;
	if (isPing)
	{
		m_SendSecList.push_back(id);
		m_IoData[id].lastPingIt = --m_SendSecList.end();
		m_IoData[id].uLastSendSec = CTimer::GetTime();
	}

	if (isEncode)
		m_IoData[id].pPacketParser = Create4BytesHeadWithEncodePacketParser(m_pAllocator, uMaxPacketSize);
	else
		m_IoData[id].pPacketParser = Create4BytesHeadPacketParser(m_pAllocator, uMaxPacketSize);
	m_IoData[id].pProtoCB = pProtoCB;
	return true;
}

bool NetCenter::RegRawSockRW( uint32 id, uint32 uMaxSizeEachRecv, bool useSendList, EventCBBase *pEventCB /*= NULL*/ )
{
	if (pEventCB)
		m_IoData[id].pEventCB = pEventCB;
	m_pNet->RegisterRWSocket(id, uMaxSizeEachRecv, useSendList);
	m_IoData[id].bNotHandleData = true;
	return true;
}

bool NetCenter::SetEncryptKey( uint32 id, uint32 uKey )
{
	if (!id && id >= m_uMaxIoSize && !m_IoData[id].pPacketParser)
		return false;
	m_IoData[id].pPacketParser->SetEncryptKey(uKey);
	return true;
}

uint32 NetCenter::Connect( const char cszIPAddress[], int nPort, EventCBBase *pEventCB)
{
	uint32 id = m_pNet->Connect(cszIPAddress, nPort);
	if (!id)
		return 0;
	m_IoData[id].pEventCB = pEventCB;
	return id;
}

void NetCenter::SendBuffer( uint32 id, IBuffer *pBuffer )
{
	SendBuffer(id, pBuffer->GetData(), pBuffer->GetSize());
}

void NetCenter::SendBuffer( uint32 id, const void* pBuffer, uint32 size )
{
	uint32 totalSize = size + len_head_size;
	m_pNet->Send(id, &totalSize, sizeof(totalSize));
	m_pNet->Send(id, pBuffer, size);
}

void NetCenter::SendBuffer( uint32 id, int proto, IBuffer *pBuffer )
{
	SendBuffer(id, proto, pBuffer->GetData(), pBuffer->GetSize());
}

void NetCenter::SendBuffer( uint32 id, int proto, const void* pBuffer, uint32 size )
{
	uint32 totalSize = size + proto_head_size + len_head_size;
	m_pNet->Send(id, &totalSize, sizeof(totalSize));	
	m_pNet->Send(id, &proto, sizeof(proto));	
	m_pNet->Send(id, pBuffer, size);
}

void NetCenter::SendProto( uint32 id, int proto )
{
	SendBuffer(id, &proto, sizeof(proto));
}

void NetCenter::SendRawBuffer( uint32 id, void* pBuffer, uint32 size )
{
	m_pNet->Send(id, pBuffer, size);
}

void NetCenter::Close( uint32 id )
{
	m_pNet->Close(id);
	m_CloseOccupyList.Occupy(id);

	if (m_IoData[id].bTimeOutJudge)
	{
		m_RecvSecList.erase(m_IoData[id].lastRecvIt);
		m_IoData[id].bTimeOutJudge = false;
	}

	if (m_IoData[id].isPing)
	{
		m_SendSecList.erase(m_IoData[id].lastPingIt);
		m_IoData[id].isPing = false;
	}

	COM_RELEASE(m_IoData[id].pPacketParser);
	m_IoData[id].pEventCB = NULL;
	m_IoData[id].pProtoCB = NULL;
}

void NetCenter::_RefreshRecvSec( uint32 id )
{
	if (m_IoData[id].bTimeOutJudge)
	{
		if (CTimer::GetTime() - m_IoData[id].uLastRecvSec > re_record_recv_sec)
		{
			m_IoData[id].uLastRecvSec = CTimer::GetTime();
			m_RecvSecList.erase(m_IoData[id].lastRecvIt);
			m_RecvSecList.push_back(id);
			m_IoData[id].lastRecvIt = --m_RecvSecList.end();
		}
	}
}

