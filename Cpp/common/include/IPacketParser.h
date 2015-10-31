#pragma once

class IBuffer;
class IPacketParser
{
public:
	virtual void PushBuffer(IBuffer *pBuffer) = 0;
	// nResult: 0 no data, 1 success, -1 data error
	virtual int PopPacket(IBuffer *&pBuffer) = 0;
	virtual void Release() = 0;
	virtual void SetEncryptKey(uint32 uKey) {}
	virtual ~IPacketParser() {}
};

IPacketParser* Create4BytesHeadPacketParser(class IAllocator* pAlloc, uint32 uMaxPacketSize);
IPacketParser* Create4BytesHeadWithEncodePacketParser(class IAllocator* pAlloc, uint32 uMaxPacketSize);
