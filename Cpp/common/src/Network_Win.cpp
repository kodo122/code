#include "Precompiled.h"
#ifdef WIN32
#include "../include/INetwork.h"
#include "../include/OccupyList.h"
#include "../include/IMemory.h"
#include "../include/Platform.h"

class CWinSockInit
{
public:
	CWinSockInit()
	{
		uint16  wVersionRequested = MAKEWORD(2, 2);
		WSADATA wsaData;
		int     nRetCode = 0;
		nRetCode = WSAStartup(wVersionRequested, &wsaData);
		assert((!nRetCode) && "WSAStartup failed!");
	}
	~CWinSockInit()
	{
		WSACleanup();
	}
} g_WinSockInitor;


int _CloseSocket(int nSocket)
{
	struct linger lingerStruct;

	lingerStruct.l_onoff  = 1;
	lingerStruct.l_linger = 0;

	setsockopt(
		nSocket,
		SOL_SOCKET, SO_LINGER, 
		(char *)&lingerStruct, sizeof(lingerStruct)
		);

	return closesocket(nSocket);
}
int _CreateListenSocket(const char cszIPAddress[], int nPort, int *pnRetListenSocket)
{
	int nResult  = false;
	int nRetCode = false;
	int nOne = 1;
	unsigned long ulAddress = INADDR_ANY;
	int nListenSocket = -1;

	sockaddr_in LocalAddr;

	PROCESS_ERROR(pnRetListenSocket);

	//nListenSocket = (int)socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
	nListenSocket = (int)WSASocket(AF_INET, SOCK_STREAM, IPPROTO_IP, NULL, 0, WSA_FLAG_OVERLAPPED);

	PROCESS_ERROR(nListenSocket != -1);

	if (
		(cszIPAddress) &&
		(cszIPAddress[0] != '\0')
		)
	{
		ulAddress = inet_addr(cszIPAddress);
		if (ulAddress == INADDR_NONE)
			ulAddress = INADDR_ANY;
	}

	nRetCode = setsockopt(nListenSocket, SOL_SOCKET, SO_REUSEADDR, (char *)&nOne, sizeof(int));
	PROCESS_ERROR(nRetCode >= 0);


	LocalAddr.sin_family        = AF_INET;
	LocalAddr.sin_addr.s_addr   = ulAddress;    //not need to htonl
	LocalAddr.sin_port          = htons(nPort);

	nRetCode = bind(nListenSocket, (struct sockaddr *)&LocalAddr, sizeof(LocalAddr));
	PROCESS_ERROR(nRetCode != -1);                                      

	nRetCode = listen(nListenSocket, 8);
	PROCESS_ERROR(nRetCode >= 0);

	nResult = true;   

Exit0:
	if (!nResult)
	{    
		if (nListenSocket != -1)
		{
			_CloseSocket(nListenSocket);
			nListenSocket = -1;
		}
	}

	if (pnRetListenSocket)
	{
		*pnRetListenSocket = nListenSocket;
	}
	return nResult;
}

int _SetSocketNoBlock(int nSocket)
{
	int nResult  = false;
	int nRetCode = 0;
	unsigned long ulOption = 1;

	nRetCode = ioctlsocket(nSocket, FIONBIO, (unsigned long *)&ulOption);
	PROCESS_ERROR(nRetCode == 0);

	nResult = true;
Exit0:
	return nResult;
}

int _IsSocketCanRestore()
{
	return (WSAGetLastError() == EINTR);
}

int _IsSocketWouldBlock()
{
	return (
		(WSAEWOULDBLOCK == WSAGetLastError()) ||
		(WSA_IO_PENDING == WSAGetLastError())
		);
}

class Network : public INetwork
{
	enum
	{
		max_accept_Each_wait = 128,
		send_buffer_size = 65535,
	};
	struct SocketData
	{
		enum
		{
			state_connecting,	// socket is connecting.
			state_rw,			// socket is on reading and writing list.
			state_listening,	// socket is listening.
			state_new,			// new socket be accepted or connected just right now.
			state_closing,		// close
			state_wait_user_close,	// wait user close
			state_system_close, // wait system close and ret
		};
		enum
		{
			type_in,			// be accepted
			type_out,			// connect
			type_listener,		// listener
		};
		int nSocket;
		int nState;
		int nType;
		int nFatherId;			// if this is type_in socket, it take which socket accept him.
		struct sockaddr_in remoteAddress;

		//if socket is state_connecting
		uint32 tick;

		//if socket is state_listening
		int nCurrIoCount;
		int nMaxAcceptIoCount;
		int nMaxAcceptEachWait;

		//if socket is state_rw
		bool bIsUseSendList;
		std::list<IBuffer*> SendBufferList;
		int nNeedSendPos;
		int nSendPos;

		IBuffer *pRecvBuffer;
		int nCompletedFlag;
		int nCompletedErrorCode;
		int nCompletedSize;

		DWORD dwWsFlag;
		WSAOVERLAPPED ReadOverLapped;
		WSABUF wsBuf;
	};
	enum
	{
		connect_time_out = 2000,
	};
public:
	Network();
	bool Initialize(IAllocator *pAllocator, int maxSocketCount);
	void Release();
	void Update();
	const NetEvent* PopEvent();

	uint32 RegisterListener(const char cszIPAddress[], int nPort, int nMaxAcceptIoCount, int nMaxAcceptEachWait);
	uint32 Connect(const char cszIPAddress[], int nPort);
	bool RegisterRWSocket(uint32 id, uint32 uMaxSizeEachRecv, bool useSendList);
	int Send(uint32 id, const void* pBuffer, uint32 size);
	void Close(uint32 id);
	void Flush();

private:
	void _Close(uint32 id);
	int _Send(int id, void* pBuffer, int &size);

	void _ProcessAccept(int index);
	void _ProcessConnect(int index);
	void _ProcessRecvOrDisconnect(int index);
	void _ProcessClosing(int index);
	bool _ProcessNewSocket(int socket, int fatherId);
	void _PushNetEvent(int eventType, int id, int errorCode, IBuffer *pIBuffer, int newSocketId, struct sockaddr_in RemoteAddr);

	static VOID WINAPI ReadIOCompletionCallBack(DWORD dwErrorCode, DWORD dwNumberOfBytesTransfered, LPOVERLAPPED lpOverlapped);
private:
	OccupyList m_OccupyList;
	SocketData* m_pSocketDataArray;

	OccupyList m_sendOccupyList;
	IAllocator* m_Allocator;

	std::vector<NetEvent> m_EventVec;
	int m_eventVecPos;
};

Network::Network()
{
	m_pSocketDataArray = NULL;
	m_eventVecPos = 0;
}
bool Network::Initialize( IAllocator *pAllocator, int maxSocketCount )
{
	int nResult = 0;
	int nRetCode = 0;

	PROCESS_ERROR(pAllocator);
	m_Allocator = pAllocator;
	m_pSocketDataArray = new SocketData[maxSocketCount];
	PROCESS_ERROR(m_pSocketDataArray);
	nRetCode = m_OccupyList.Init(maxSocketCount);
	PROCESS_ERROR(nRetCode);
	nRetCode = m_sendOccupyList.Init(maxSocketCount);
	PROCESS_ERROR(nRetCode);

	nResult = 1;
Exit0:
	if (!nResult)
		Release();
	return nResult;
}
void Network::Release()
{
}
void Network::Update()
{
	int nResult = false;
	int nRetCode = 0;
	SocketData* pSocketData = NULL;

	int nPreIndex = 0;
	int nLinkIndex = 0;

	for (std::vector<NetEvent>::iterator it = m_EventVec.begin(); it != m_EventVec.end(); ++it)
	{
		if (it->eventType == NetEvent::event_recv)
			COM_RELEASE(it->pIBuffer);
	}
	m_EventVec.clear();
	m_eventVecPos = 0;

	while(nLinkIndex = m_OccupyList.GetNext(nPreIndex))
	{
		bool isOccupy = true;
		pSocketData = &m_pSocketDataArray[nLinkIndex];
		switch(pSocketData->nState)
		{
		case SocketData::state_listening:
			_ProcessAccept(nLinkIndex);
			break;
		case SocketData::state_rw:
		case SocketData::state_system_close:
			_ProcessRecvOrDisconnect(nLinkIndex);
			break;
		case SocketData::state_connecting:
			_ProcessConnect(nLinkIndex);
			break;
		case SocketData::state_closing:
			_ProcessClosing(nLinkIndex);
			isOccupy = false;
			break;
		}
		if (isOccupy)
			nPreIndex = nLinkIndex;
	}
}
const NetEvent* Network::PopEvent()
{
	int id = 0;
	SocketData *pSocketData = NULL;
	while (m_eventVecPos < m_EventVec.size())
	{
		id = m_EventVec[m_eventVecPos].id;
		pSocketData = &m_pSocketDataArray[id]; 

		if (pSocketData->nState != SocketData::state_system_close && pSocketData->nState != SocketData::state_closing)
			return &m_EventVec[m_eventVecPos++];
		++m_eventVecPos;
	}
	return NULL;
}
uint32 Network::RegisterListener( const char cszIPAddress[], int nPort, int nMaxAcceptIoCount, int nMaxAcceptEachWait )
{
	uint32 uResult = 0;
	int nRetCode = 0;
	int nListenSocket = -1;
	int id = 0;
	SocketData *pSocketData = NULL;

	id = m_OccupyList.GetFirstFree(true);
	PROCESS_ERROR(id);
	pSocketData = &m_pSocketDataArray[id];
	nRetCode = _CreateListenSocket(cszIPAddress, nPort, &nListenSocket);
	PROCESS_ERROR(nRetCode);
	nRetCode = _SetSocketNoBlock(nListenSocket);
	PROCESS_ERROR(nRetCode);

	pSocketData->nState = SocketData::state_listening;
	pSocketData->nType = SocketData::type_listener;
	pSocketData->nSocket = nListenSocket;
	pSocketData->nMaxAcceptIoCount = nMaxAcceptIoCount;
	pSocketData->nMaxAcceptEachWait = nMaxAcceptEachWait > max_accept_Each_wait ? max_accept_Each_wait : nMaxAcceptEachWait;
	pSocketData->nCurrIoCount = 0;

	uResult = id;
Exit0:
	if (!uResult)
	{		
		m_OccupyList.Free(id);
		if (nListenSocket != -1)
			_CloseSocket(nListenSocket);
		nListenSocket = -1;
	}
	return uResult;
}
uint32 Network::Connect( const char cszIPAddress[], int nPort )
{
	uint32 nResult = 0;
	int nRetCode = 0;
	int nSocket = -1;
	int id = 0;
	SocketData *pSocketData = NULL;
	struct sockaddr_in Addr;

	PROCESS_ERROR(cszIPAddress);
	id = m_OccupyList.GetFirstFree(true);
	PROCESS_ERROR(id);
	nSocket = (int)socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
	PROCESS_ERROR(nSocket != -1);
	nRetCode = _SetSocketNoBlock(nSocket);
	PROCESS_ERROR(nRetCode);

	memset((void *)&Addr, 0, sizeof(sockaddr_in));
	Addr.sin_family       = AF_INET;
	Addr.sin_addr.s_addr  = inet_addr(cszIPAddress);
	Addr.sin_port         = htons(nPort);

	pSocketData = &m_pSocketDataArray[id];
	pSocketData->nSocket = nSocket;
	pSocketData->nState = SocketData::state_connecting;
	pSocketData->nType = SocketData::type_out;
	pSocketData->nFatherId = 0;
	pSocketData->remoteAddress = Addr;
	pSocketData->tick = platform::get_tick();

	while (true)
	{
		nRetCode = connect(nSocket, (LPSOCKADDR)&Addr, sizeof(Addr));
		if (nRetCode < 0)
		{
			nRetCode = _IsSocketCanRestore();
			if (nRetCode)  // A signal interrupted send() before any data was transmitted.
				continue;  // Just try again.

			nRetCode = _IsSocketWouldBlock();
			PROCESS_ERROR(nRetCode);
		}
		break;
	}

	nResult = id;
Exit0:
	if (!nResult)
	{
		m_OccupyList.Free(id);
		if (nSocket != -1)
			_CloseSocket(nSocket);
		nSocket = -1;
	}
	return nResult;
}
bool Network::RegisterRWSocket( uint32 id, uint32 uMaxSizeEachRecv, bool useSendList )
{
	int nResult  = -1;
	int nRetCode = false;
	int nSendBufferSize = 65535;
	SocketData *pSocketData = NULL;

	assert(m_OccupyList.IsOccupy(id));
	pSocketData = &m_pSocketDataArray[id];

	nRetCode = _SetSocketNoBlock(pSocketData->nSocket);
	PROCESS_ERROR(nRetCode);
	if (useSendList)
		nSendBufferSize = 65535 * 4;
	nRetCode = setsockopt(pSocketData->nSocket, SOL_SOCKET, SO_SNDBUF, 
		(char*)&nSendBufferSize, sizeof(nSendBufferSize));
	PROCESS_ERROR(nRetCode >= 0);

	pSocketData->nState = SocketData::state_rw;
	pSocketData->nSendPos = 0;
	pSocketData->nNeedSendPos = 0;
	pSocketData->bIsUseSendList = useSendList;

	pSocketData->nCompletedErrorCode = 0;
	pSocketData->nCompletedFlag = true;
	pSocketData->nCompletedSize = 0;

	pSocketData->pRecvBuffer = m_Allocator->AllocBuffer(uMaxSizeEachRecv);
	PROCESS_ERROR(pSocketData->pRecvBuffer);
	nRetCode = BindIoCompletionCallback((HANDLE)pSocketData->nSocket, ReadIOCompletionCallBack, 0);
	PROCESS_ERROR(nRetCode);

	nResult = 1;
Exit0:
	if (nResult)
	{
		pSocketData->nState = SocketData::state_rw;
	}
	else
	{
		COM_RELEASE(pSocketData->pRecvBuffer);
	}
	return nResult;
}
void Network::Close( uint32 id )
{
	int nRetCode = 0;
	SocketData* pSocketData = NULL; 

	nRetCode = m_OccupyList.IsOccupy(id);
	PROCESS_ERROR(nRetCode);

	pSocketData = &m_pSocketDataArray[id];

	switch (pSocketData->nState)
	{
	case SocketData::state_rw:
		_CloseSocket(pSocketData->nSocket);
		for (std::list<IBuffer*>::iterator it = pSocketData->SendBufferList.begin(); it != pSocketData->SendBufferList.end(); ++it)
			(*it)->Release();
		pSocketData->SendBufferList.clear();
		m_pSocketDataArray[id].nState = SocketData::state_system_close;
		break;
	case SocketData::state_connecting:
	case SocketData::state_listening:
	case SocketData::state_new:	
		_CloseSocket(pSocketData->nSocket);
		m_pSocketDataArray[id].nState = SocketData::state_closing;
		break;
	case SocketData::state_wait_user_close:
		_CloseSocket(pSocketData->nSocket);
		for (std::list<IBuffer*>::iterator it = pSocketData->SendBufferList.begin(); it != pSocketData->SendBufferList.end(); ++it)
			(*it)->Release();
		pSocketData->SendBufferList.clear();
		m_pSocketDataArray[id].nState = SocketData::state_closing;
		break;
	}
Exit0:
	;
}
int Network::Send( uint32 id, const void* pBuffer, uint32 size )
{
	int nResult = 0;
	int nleftSize = 0;
	bool isNeedAlloc;
	int nCanCopySize;
	int nLeftCopySize;

	PROCESS_ERROR_RET_CODE(id, -1);
	PROCESS_ERROR_RET_CODE(size, -2);	
	//PROCESS_ERROR_RET_CODE(size <= send_buffer_size, -3);
	PROCESS_ERROR_RET_CODE(m_OccupyList.IsOccupy(id), -4);
	PROCESS_ERROR_RET_CODE(m_pSocketDataArray[id].nState == SocketData::state_rw, -5);

	m_sendOccupyList.Occupy(id);

	if (m_pSocketDataArray[id].SendBufferList.empty())
		nleftSize = 0;
	else
		nleftSize = send_buffer_size - m_pSocketDataArray[id].nNeedSendPos;
	
	if (nleftSize >= size)
	{
		isNeedAlloc = false;
		nCanCopySize = size;
		nLeftCopySize = 0;
	}
	else
	{
		isNeedAlloc = true;
		nCanCopySize = nleftSize;
		nLeftCopySize = size - nleftSize;
	}

	if (nCanCopySize)
	{
		IBuffer* ref = m_pSocketDataArray[id].SendBufferList.back();
		memcpy((char*)ref->GetData() + m_pSocketDataArray[id].nNeedSendPos, pBuffer, nCanCopySize);
		m_pSocketDataArray[id].nNeedSendPos += nCanCopySize;
	}
	if (isNeedAlloc)
	{
		while (nLeftCopySize)
		{
			int nCopySize = nLeftCopySize > send_buffer_size ? send_buffer_size : nLeftCopySize;
			IBuffer* pNewBuffer = m_Allocator->AllocBuffer(send_buffer_size);
			m_pSocketDataArray[id].SendBufferList.push_back(pNewBuffer);
			memcpy(pNewBuffer->GetData(), (char*)pBuffer + nCanCopySize, nCopySize);
			m_pSocketDataArray[id].nNeedSendPos = nCopySize;
			nLeftCopySize -= nCopySize;
		}
	}
Exit0:
	return nResult;
}
int Network::_Send( int id, void* pBuffer, int &size )
{
	int nResult  = -1;
	int nRetCode = false;
	unsigned char *pbyBuffer = NULL;
	SocketData *pSocketData = NULL;

	pSocketData = &m_pSocketDataArray[id];
	pbyBuffer = (unsigned char*)pBuffer;

	while (size > 0)
	{
		nRetCode = send(pSocketData->nSocket, (const char *)pbyBuffer, size, 0);

		if (nRetCode >= 0)
		{
			size -= nRetCode;
			pbyBuffer += nRetCode;
			continue;
		}

		nRetCode = _IsSocketCanRestore();
		if (nRetCode)  // A signal interrupted send() before any data was transmitted.
			continue;  // Just try again.

		nRetCode = _IsSocketWouldBlock();
		if (nRetCode)
		{
			PROCESS_ERROR(false);
		}
		PROCESS_ERROR(false); // Return error when we got other errors. 
	}
	nResult = 1;
Exit0:
	return nResult;
}
void Network::Flush()
{
	int nRetCode = 0;
	int nPreIndex = 0;
	int nLinkIndex = 0;
	while(nLinkIndex = m_sendOccupyList.GetNext(nPreIndex))
	{
		std::list<IBuffer*>::iterator it = m_pSocketDataArray[nLinkIndex].SendBufferList.begin();

		while (it != m_pSocketDataArray[nLinkIndex].SendBufferList.end())
		{
			IBuffer *pSendBuffer = *it;
			int size = 0;
			bool isLastBuffer = (m_pSocketDataArray[nLinkIndex].SendBufferList.size() == 1);
			if (isLastBuffer)
				size = m_pSocketDataArray[nLinkIndex].nNeedSendPos - m_pSocketDataArray[nLinkIndex].nSendPos;
			else
				size = send_buffer_size - m_pSocketDataArray[nLinkIndex].nSendPos;
			nRetCode = _Send(nLinkIndex, (char*)pSendBuffer->GetData() + m_pSocketDataArray[nLinkIndex].nSendPos, size);
			if (size)
			{
				if (isLastBuffer)
					m_pSocketDataArray[nLinkIndex].nSendPos = m_pSocketDataArray[nLinkIndex].nNeedSendPos - size;
				else
					m_pSocketDataArray[nLinkIndex].nSendPos = send_buffer_size - size;
			}
			else
			{
				if (isLastBuffer)
					m_pSocketDataArray[nLinkIndex].nNeedSendPos = 0;
				m_pSocketDataArray[nLinkIndex].nSendPos = 0;
				COM_RELEASE(pSendBuffer);
				it = m_pSocketDataArray[nLinkIndex].SendBufferList.erase(it);
			}
			if (nRetCode != true)
				break;
		}
		if (!m_pSocketDataArray[nLinkIndex].bIsUseSendList)
		{
			if (!m_pSocketDataArray[nLinkIndex].SendBufferList.empty())
				_PushNetEvent(NetEvent::event_error, nLinkIndex, NetEvent::error_sendbuffer_full, NULL, 0, m_pSocketDataArray[nLinkIndex].remoteAddress);				
			m_pSocketDataArray[nLinkIndex].nSendPos = 0;
			m_pSocketDataArray[nLinkIndex].nNeedSendPos = 0;
			for (it = m_pSocketDataArray[nLinkIndex].SendBufferList.begin(); it != m_pSocketDataArray[nLinkIndex].SendBufferList.end(); ++it)
			{
				IBuffer *pSendBuffer = *it;
				COM_RELEASE(pSendBuffer);
			}
			m_pSocketDataArray[nLinkIndex].SendBufferList.clear();
		}

		if (it == m_pSocketDataArray[nLinkIndex].SendBufferList.end())
			m_sendOccupyList.Free(nLinkIndex);
		else
			nPreIndex = nLinkIndex;
	}
}
void Network::_ProcessAccept(int index)
{
	int nResult = 0;
	int nRetCode = 0;
	int nCurrAcceptIo = 0;
	SocketData *pSocketData = NULL;
	SocketData *pNewSocketData = NULL;
	int nSocket = -1;
	struct sockaddr_in RemoteAddr;
	int nAddrLen = 0;

	pSocketData = &m_pSocketDataArray[index];

	while (true)
	{
		if (nCurrAcceptIo >= pSocketData->nMaxAcceptEachWait)
			break;
		nAddrLen = sizeof(sockaddr_in);
		memset((void *)&RemoteAddr, 0, sizeof(sockaddr_in));

		nSocket = (int)accept(pSocketData->nSocket, (struct sockaddr *)&RemoteAddr, (socklen_t*)&nAddrLen);
		if (nSocket == -1)
		{
			nRetCode = _IsSocketCanRestore();
			if (nRetCode)   // if can restore then continue
				continue;
			nRetCode = _IsSocketWouldBlock();
			if (nRetCode)
				break;
			break;
		}
		nRetCode = _ProcessNewSocket(nSocket, index);
	}

	nResult = 1;
Exit0:
	;
}
void Network::_ProcessConnect( int index )
{
	int nResult = 0;
	int nRetCode = 0;
	SocketData *pSocketData = NULL;
	int nData = 0;

	pSocketData = &m_pSocketDataArray[index];
	nRetCode = send(pSocketData->nSocket, (char*)&nData, 0, 0);
	PROCESS_ERROR(!nRetCode);

	_PushNetEvent(NetEvent::event_connect_result, index, NetEvent::error_success, NULL, 0, pSocketData->remoteAddress);
	pSocketData->nState = SocketData::state_new;

	nResult = 1;
Exit0:
	if (!nResult)
	{
		if (platform::get_tick() - pSocketData->tick > connect_time_out)
		{
			pSocketData->nState = SocketData::state_wait_user_close;
			_PushNetEvent(NetEvent::event_connect_result, index, NetEvent::error_connect_timeout, NULL, 0, pSocketData->remoteAddress);
		}
	}
}
void Network::_ProcessRecvOrDisconnect( int index )
{
	int nResult = false;
	int nRetCode = 0;
	SocketData *pSocketData = NULL;
	IBuffer* pIBuffer = NULL;

	pSocketData = &m_pSocketDataArray[index];
	int nNotFree = true;
	while (true)
	{
		if (!pSocketData->nCompletedFlag)
			break;
		// when Io Completion
		if (pSocketData->nCompletedErrorCode != ERROR_SUCCESS)
		{	//socket error
			nNotFree = false;
			break;
		}
		if (pSocketData->nCompletedSize && pSocketData->nState == SocketData::state_rw)
		{
			pIBuffer = m_Allocator->AllocBuffer(pSocketData->nCompletedSize);
			memcpy(pIBuffer->GetData(), pSocketData->pRecvBuffer->GetData(), pSocketData->nCompletedSize);
			_PushNetEvent(NetEvent::event_recv, index, NetEvent::error_success, pIBuffer, 0, pSocketData->remoteAddress);
		}
		while (true)
		{
			DWORD dwProcessBytes = 0;
			pSocketData->wsBuf.len = pSocketData->pRecvBuffer->GetSize();
			pSocketData->wsBuf.buf = (char*)pSocketData->pRecvBuffer->GetData();
			pSocketData->dwWsFlag = 0;
			memset(&pSocketData->ReadOverLapped, 0, sizeof(pSocketData->ReadOverLapped));

			pSocketData->nCompletedErrorCode = ERROR_SUCCESS;
			pSocketData->nCompletedSize = 0;
			pSocketData->nCompletedFlag = false;

			nRetCode = WSARecv(pSocketData->nSocket, &pSocketData->wsBuf, 1, &dwProcessBytes, &pSocketData->dwWsFlag, &pSocketData->ReadOverLapped, NULL);
			if (nRetCode < 0)   // when 0 is success
			{
				nRetCode = _IsSocketCanRestore();
				if (nRetCode)   // if can restore then continue
					continue;
				nRetCode = _IsSocketWouldBlock();
				if (nRetCode)
					break;

				nNotFree = false;
				break;
			}
			// when success also need to wait for IoCompletionCallBack
			break;
		}
		break;
	}
	if (!nNotFree)
	{
		if (pSocketData->nState == SocketData::state_rw)
		{
			_PushNetEvent(NetEvent::event_disconnect, index, NetEvent::error_disconnect, NULL, 0, pSocketData->remoteAddress);
			pSocketData->nState = SocketData::state_wait_user_close;
		}
		else	//state_system_close return
			pSocketData->nState = SocketData::state_closing;
	}
}
void Network::_ProcessClosing(int index)
{
	SocketData* pSocketData = &m_pSocketDataArray[index];
	if (pSocketData->nType == SocketData::type_in)
	{
		if (m_OccupyList.IsOccupy(pSocketData->nFatherId))
			--m_pSocketDataArray[pSocketData->nFatherId].nCurrIoCount;
	}
	m_OccupyList.Free(index);
}
bool Network::_ProcessNewSocket( int socket, int fatherId )
{
	int nResult = 0;
	int nRetCode = 0;
	int id = 0;
	int nAddrLen = 0;
	SocketData *pNewSocketData = NULL;
	SocketData *pFatherSocketData = NULL;

	pFatherSocketData = &m_pSocketDataArray[fatherId];
	PROCESS_ERROR(pFatherSocketData->nMaxAcceptIoCount > pFatherSocketData->nCurrIoCount);
	id = m_OccupyList.GetFirstFree(true);
	PROCESS_ERROR(id);

	pNewSocketData = &m_pSocketDataArray[id];

	pNewSocketData->nSocket = socket;
	pNewSocketData->nState = SocketData::state_new;
	nAddrLen = sizeof(sockaddr_in);
	getpeername(socket, (sockaddr*)&pNewSocketData->remoteAddress, (socklen_t*)&nAddrLen);
	pNewSocketData->nType = SocketData::type_in;
	pNewSocketData->nFatherId = fatherId;
	pNewSocketData->nCurrIoCount;

	_PushNetEvent(NetEvent::event_accepted, fatherId, 0, NULL, id, pNewSocketData->remoteAddress);
	++pFatherSocketData->nCurrIoCount;

	nResult = 1;
Exit0:
	if (!nResult)
		_CloseSocket(socket);
	return nResult;
}

void Network::_PushNetEvent(int eventType, int id, int errorCode, IBuffer *pIBuffer, int newSocketId, struct sockaddr_in RemoteAddr)
{
	NetEvent event;
	event.eventType = eventType;
	event.id = id;
	event.errorCode = errorCode;
	event.pIBuffer = pIBuffer;
	event.newSocketId = newSocketId;
	event.RemoteAddr = RemoteAddr;
	m_EventVec.push_back(event);
}

VOID WINAPI Network::ReadIOCompletionCallBack( DWORD dwErrorCode, DWORD dwNumberOfBytesTransfered, LPOVERLAPPED lpOverlapped )
{
	int nRetCode = false;
	SocketData *pSocketData = CONTAINING_RECORD(lpOverlapped, SocketData, ReadOverLapped);
	assert(pSocketData);

	if (dwNumberOfBytesTransfered == 0) // For byte streams, zero bytes having been read (as indicated by a zero
	{                                   // return value to indicate success, and lpNumberOfBytesRecvd value of
		dwErrorCode = WSAEDISCON;       // zero) indicates graceful closure and that no more bytes will ever be
	}                                   // read. (See MSDN:WSARecv() for more information)

	pSocketData->nCompletedErrorCode = dwErrorCode;
	pSocketData->nCompletedSize = dwNumberOfBytesTransfered;
	pSocketData->nCompletedFlag = true;
}

INetwork* CreateNetwork()
{
	return new Network;
}
void DestroyNetwork(INetwork* pINetwork)
{
	delete pINetwork;
}
#endif
