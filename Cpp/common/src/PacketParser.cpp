#include "Precompiled.h"
#include "../include/IPacketParser.h"
#include "../include/IMemory.h"
#include "../include/CRC32.h"

void ReleasePacketParser(IPacketParser* pPacketParser);

template <uint32 uLenHeadSize>
class LenHeadPacketParser : public IPacketParser
{
public:
	LenHeadPacketParser(IAllocator *pAllocator, uint32 uMaxPacketSize)
	{
		m_pAllocator = pAllocator;
		m_uMaxPacketSize = uMaxPacketSize;
		m_uTotalSize = 0;
		m_uCurrPos = 0;
		m_uDataSize = 0;
	}
	void PushBuffer(IBuffer *pBuffer)
	{
		m_pBufferVec.push_back(pBuffer);
		m_uTotalSize += pBuffer->GetSize();
		pBuffer->AddRef();
	}
	int PopPacket(IBuffer *&pBuffer)
	{
		if (!m_uDataSize)
		{
			IBuffer* pLenHeadBuffer = PopSize(uLenHeadSize);
			if (!pLenHeadBuffer)
				return 0;
			memcpy(&m_uDataSize, pLenHeadBuffer->GetData(), uLenHeadSize);
			COM_RELEASE(pLenHeadBuffer);
			if (m_uDataSize < uLenHeadSize || m_uDataSize > m_uMaxPacketSize)
				return -1;
			m_uDataSize -= uLenHeadSize;
		}
		if (!m_uDataSize || m_uDataSize > m_uTotalSize)
			return 0;
		pBuffer = PopSize(m_uDataSize);
		m_uDataSize = 0;
		return 1;
	}
	IBuffer* PopSize(uint32 uSize)
	{
		if (uSize > m_uTotalSize)
			return NULL;
		IBuffer *pRetBuffer = m_pAllocator->AllocBuffer(uSize);
		m_uTotalSize -= uSize;

		int nTotolCopySize = 0;
		for (std::list<IBuffer*>::iterator it = m_pBufferVec.begin(); it != m_pBufferVec.end() && uSize;)
		{
			IBuffer *pBuffer = *it;
			uint32 uCurrBufferSize = pBuffer->GetSize() - m_uCurrPos;		
			uint32 uCopySize = uCurrBufferSize > uSize ? uSize : uCurrBufferSize;
			memcpy((char*)pRetBuffer->GetData() + nTotolCopySize, (char*)pBuffer->GetData() + m_uCurrPos, uCopySize);
			m_uCurrPos += uCopySize;
			nTotolCopySize += uCopySize;
			uSize -= uCopySize;
			uCurrBufferSize -= uCopySize;

			if (uCurrBufferSize)
				continue;
			COM_RELEASE(pBuffer);
			it = m_pBufferVec.erase(it);
			m_uCurrPos = 0;
		}
		assert(!uSize);
		assert(nTotolCopySize == pRetBuffer->GetSize());
		return pRetBuffer;
	}

	void Release()
	{
		for (std::list<IBuffer*>::iterator it = m_pBufferVec.begin(); it != m_pBufferVec.end(); ++it)
			COM_RELEASE(*it);
		m_pBufferVec.clear();

		ReleasePacketParser(this);
	}
private:
	uint32 m_uMaxPacketSize;
	IAllocator* m_pAllocator;
	uint32 m_uDataSize;
	uint32 m_uCurrPos;
	uint32 m_uTotalSize;
	std::list<IBuffer*> m_pBufferVec;
};

uint32 GetCipherCode(uint32 &uKey)
{
	static uint32 sCipherTable[] = 
	{
		0x52815248, 0xc6db9c7e, 0xf694ec31, 0xb9a2539c, 0xc27c35ad, 0xb9e48478, 0x242c817d, 
		0x9e4f9641, 0x17414ba9, 0x46a7f155, 0xc7e9e7aa, 0x42b46c92, 0xa5b23619, 0x8447df7b, 0xe435b58e, 
		0xba4b9eaa, 0x151be182, 0xceba5998, 0x83789224, 0x57873fda, 0x35db1fe9, 0x29ecc532, 0xf4f8bb45, 
		0xdab4de18, 0xe456f514, 0x8599c3d9, 0xb1662f2b, 0x37da98ab, 0x245741f9, 0x21189fab, 0xf3365221, 
		0xec41e922, 0x28569997, 0xc27da5bf, 0x1e333b37, 0xeb7854b3, 0x2faf6b23, 0xf5374d76, 0xad194479, 
		0xce1d3178, 0x5b5a523c, 0x298ab18e, 0x873cda6a, 0x9aab5dae, 0xd4a2b639, 0x7b1ea4e8, 0xc7e2dbd6, 
		0x6e21a7a9, 0x5721b149, 0xce995b2b, 0xedb4ffdd, 0xada862de, 0xd6b1fd2d, 0x59e3b2c9, 0x89c1f11d, 
		0x7237b63e, 0xe7a6f1fb, 0xdca786e3, 0x95268713, 0x23435bd4, 0x785b76a3, 0x74af3871, 0x9d2fd697, 
		0xff6872cf, 0xed6ab4ad, 0x459accfb, 0x5be4db12, 0xf4acfaf9, 0x3969cbcb, 0x4722288c, 0x3571cf54, 
		0x5cdf217c, 0x8c7a88dc, 0xed8a4aee, 0x9f22f26d, 0xb7bcbe59, 0xbc53545a, 0x4a875c6b, 0xa1a91ac9, 
		0x57acd9d3, 0x9e6de385, 0xb53743ec, 0x92e245b5, 0xd78bc74c, 0x5ef13b3f, 0x97db44b4, 0x93ce1c58, 
		0xd5f97b7e, 0x662fab5a, 0x3a331927, 0xca723285, 0x698616dc, 0x8beab7af, 0xd5ca32fe, 0xb556e47c, 
		0xed71f9f3, 0xb66ab983, 0x3d517f2d, 0x66491254, 0x6eee6ae4, 0x7a5f8a4c, 0x77b9be48, 0xc8453df3, 
		0xa5436ddb, 0x41f76947, 0x454c924a, 0x67edeab6, 0x376b9d15, 0x7359e527, 0x256de461, 0x1578698d, 
		0xb2e223d5, 0xf9481de8, 0x3f36dc6d, 0x8b9917d1, 0x7b4c759f, 0xfdb7aedc, 0x5843893e, 0x369c895f, 
		0xb2af82d3, 0xeee919ae, 0x1b447fe1, 0x44df9419, 0x29c155a9, 0xe588f13c, 0xb17d3bd9, 0xe56ebee6, 
		0xb415c738
	};
	static int sCipherTableSize = sizeof(sCipherTable) / sizeof(sCipherTable[0]);
	uint32 cipher = sCipherTable[uKey % sCipherTableSize];
	uKey = (uKey * 31) + 134775813;

	return cipher;
}

template <uint32 uLenHeadSize>
class LenHeadWithEncodePacketParser : public IPacketParser
{
public:
	enum
	{
		encode_size = 4,
	};
	LenHeadWithEncodePacketParser(IAllocator *pAllocator, uint32 uMaxPacketSize)
	{
		m_pAllocator = pAllocator;
		m_uMaxPacketSize = uMaxPacketSize;
		m_uTotalSize = 0;
		m_uCurrPos = 0;
		m_uDataSize = 0;
		m_uEncryptKey = 0;
		m_uCRC32 = 0;
	}
	void PushBuffer(IBuffer *pBuffer)
	{
		m_pBufferVec.push_back(pBuffer);
		m_uTotalSize += pBuffer->GetSize();
		pBuffer->AddRef();
	}
	int PopPacket(IBuffer *&pBuffer)
	{
		if (!m_uDataSize)
		{
			IBuffer* pLenHeadBuffer = PopSize(uLenHeadSize);
			if (!pLenHeadBuffer)
				return 0;
			memcpy(&m_uDataSize, pLenHeadBuffer->GetData(), uLenHeadSize);
			COM_RELEASE(pLenHeadBuffer);
			if (m_uDataSize < uLenHeadSize + encode_size || m_uDataSize > m_uMaxPacketSize)
				return -1;
			m_uDataSize -= uLenHeadSize;
		}
		if (!m_uDataSize || m_uDataSize > m_uTotalSize)
			return 0;

		uint32 uEncode = 0;
		IBuffer *pEncodeBuffer = PopSize(encode_size);
		memcpy(&uEncode, pEncodeBuffer->GetData(), encode_size);
		COM_RELEASE(pEncodeBuffer);		

		m_uDataSize -= encode_size;
		pBuffer = PopSize(m_uDataSize);
		assert(pBuffer);

		m_uCRC32 = CRC32(m_uCRC32, pBuffer->GetData(), m_uDataSize);
		uint32 uCode = GetCipherCode(m_uEncryptKey);

		if (uEncode != (m_uCRC32 ^ uCode))
		{
			COM_RELEASE(pBuffer);
			m_uDataSize = 0;
			return -1;
		}

		m_uDataSize = 0;
		return 1;
	}
	IBuffer* PopSize(uint32 uSize)
	{
		if (uSize > m_uTotalSize)
			return NULL;
		IBuffer *pRetBuffer = m_pAllocator->AllocBuffer(uSize);
		m_uTotalSize -= uSize;

		int nTotolCopySize = 0;
		for (std::list<IBuffer*>::iterator it = m_pBufferVec.begin(); it != m_pBufferVec.end() && uSize;)
		{
			IBuffer *pBuffer = *it;
			uint32 uCurrBufferSize = pBuffer->GetSize() - m_uCurrPos;		
			uint32 uCopySize = uCurrBufferSize > uSize ? uSize : uCurrBufferSize;
			memcpy((char*)pRetBuffer->GetData() + nTotolCopySize, (char*)pBuffer->GetData() + m_uCurrPos, uCopySize);
			m_uCurrPos += uCopySize;
			nTotolCopySize += uCopySize;
			uSize -= uCopySize;
			uCurrBufferSize -= uCopySize;

			if (uCurrBufferSize)
				continue;
			COM_RELEASE(pBuffer);
			it = m_pBufferVec.erase(it);
			m_uCurrPos = 0;
		}
		assert(!uSize);
		assert(nTotolCopySize == pRetBuffer->GetSize());
		return pRetBuffer;
	}
	void SetEncryptKey(uint32 uKey)
	{
		m_uEncryptKey = uKey;
	}
	void Release()
	{
		for (std::list<IBuffer*>::iterator it = m_pBufferVec.begin(); it != m_pBufferVec.end(); ++it)
			COM_RELEASE(*it);
		m_pBufferVec.clear();

		ReleasePacketParser(this);
	}
private:
	uint32 m_uEncryptKey;
	uint32 m_uCRC32;
	uint32 m_uMaxPacketSize;
	IAllocator* m_pAllocator;
	uint32 m_uDataSize;
	uint32 m_uCurrPos;
	uint32 m_uTotalSize;
	std::list<IBuffer*> m_pBufferVec;
};


IPacketParser* Create4BytesHeadPacketParser( IAllocator* pAlloc, uint32 uMaxPacketSize )
{
	return new LenHeadPacketParser<4>(pAlloc, uMaxPacketSize);
}

IPacketParser* Create4BytesHeadWithEncodePacketParser( class IAllocator* pAlloc, uint32 uMaxPacketSize )
{
	return new LenHeadWithEncodePacketParser<4>(pAlloc, uMaxPacketSize);
}

void ReleasePacketParser(IPacketParser* pPacketParser)
{
	delete pPacketParser;
}
