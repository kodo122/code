#pragma once
#include <vector>

class IBuffer;

struct NetEvent
{
	enum
	{
		//event_create_listener_result = 1,
		event_connect_result = 2,
		event_accepted = 3,
		event_recv = 4,
		event_disconnect = 5,
		event_error = 6,
	};
	enum
	{
		error_success = 0,
		error_data_error = 1,
		error_connect_timeout = 2,
		error_be_reset = 3,
		error_disconnect = 4,
		error_connect_failed = 5,
		error_sendbuffer_full = 6,
		error_time_out = 7,
	};
	int eventType;
	int id;
	int errorCode;

	IBuffer *pIBuffer;
	int newSocketId;
	struct sockaddr_in RemoteAddr;
};

class INetwork
{
public:
	virtual bool Initialize(class IAllocator *pAllocator, int maxSocketCount) = 0;
	virtual void Release() = 0;
	virtual void Update() = 0;
	virtual const NetEvent* PopEvent() = 0;
	virtual uint32 RegisterListener(const char cszIPAddress[], int nPort, int nMaxAcceptIoCount, int nMaxAcceptEachWait) = 0;
	virtual uint32 Connect(const char cszIPAddress[], int nPort) = 0;
	virtual bool RegisterRWSocket(uint32 id, uint32 uMaxSizeEachRecv, bool useSendList) = 0;
	virtual int Send(uint32 id, const void* pBuffer, uint32 size) = 0;
	virtual void Close(uint32 id) = 0;
	virtual void Flush() = 0;
};

INetwork* CreateNetwork();
void DestroyNetwork(INetwork* pINetwork);
