#include "Precompiled.h"
#include "../include/ByteBuffer.h"

IAllocator * StaticBuffer::m_pAllocator = NULL;
char g_str[65535] = "";

void StaticBuffer::writeString( const char* str, int len )
{
	assert(str);
	if (!str)
		return;

	if (len <= 0)
		len = strlen(str);

	write((const uint8*)str, len);
}

char* StaticBuffer::readString( int len )
{
	g_str[0] = 0;
#ifdef __GNUC__
	len = std::min(len,(int)(sizeof(g_str) - 1));
#else
	len = min(len,(int)(sizeof(g_str) - 1));
#endif
	read((uint8*)g_str, len);
	g_str[len] = 0;
	return g_str;
}

void StaticBuffer::read( uint8* dest, int size )
{
	if (m_readPos + size > m_uReadBufferSize)
		return;
	memcpy(dest, m_pReadBuffer + m_readPos, size);
	m_readPos += size;
}

void StaticBuffer::write( const uint8 *src, int size )
{
	if (m_writePos + size > writeBufferSize())
		return;
	memcpy((char*)m_pWriteBuffer->GetData() + m_writePos, src, size);

	m_writePos += size;
}
