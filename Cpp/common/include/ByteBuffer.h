#ifndef _BYTEBUFFER_H
#define _BYTEBUFFER_H
#include "IMemory.h"

class StaticBuffer
{
public:
	StaticBuffer(void* pBuffer, int uSize)
	{
		m_pReadBuffer = (const char*)pBuffer;
		m_uReadBufferSize = uSize;
		m_pWriteBuffer = NULL;
		m_readPos = 0;
		m_writePos = 0;
	}
	// for lua
	StaticBuffer(uint32 uSize)
	{
		m_pReadBuffer = 0;
		m_uReadBufferSize = 0;
		m_pWriteBuffer = NULL;
		if (uSize)
			m_pWriteBuffer = m_pAllocator->AllocBuffer(uSize);
		m_readPos = 0;
		m_writePos = 0;
	}
	~StaticBuffer()
	{
		if (m_pWriteBuffer)
			m_pWriteBuffer->Release();
		m_pWriteBuffer = NULL;
	}

	int8 readInt8() { return read<int8>(); }
	int16 readInt16() { return read<int16>(); }
	int32 readInt32() { return read<int32>(); }
	uint8 readUInt8() { return read<uint8>(); }
	uint16 readUInt16() { return read<uint16>(); }
	uint32 readUInt32() { return read<uint32>(); }
	float readFloat() { return read<float>(); };
	double readDouble() { return read<double>(); }
	char* readString(int len);
	bool readBoolean() { return (bool)read<uint8>(); };

	void writeInt8(int8 val) { write(val); }
	void writeInt16(int16 val) { write(val); }
	void writeInt32(int32 val) { write(val); }
	void writeFloat(float val) { write(val); }
	void writeDouble(double val) { write(val); }
	void writeString(const char* str, int len);
	void writeBoolean(bool val) { write((int8)val); }

	//uint32 readLen();
	//void writeLen(uint32 val);

	IBuffer* GetWriteBuffer()
	{
		return m_pWriteBuffer;
	}
	uint32 writeRemain()
	{
		return writeBufferSize() - m_writePos;
	}
	uint32 readRemain()
	{
		return m_uReadBufferSize - m_readPos;
	}
	uint32 readBufferSize()
	{
		return m_uReadBufferSize;
	}
	uint32 writeBufferSize()
	{
		return m_pWriteBuffer ? m_pWriteBuffer->GetSize() : 0;
	}
	static void SetAllocator(IAllocator* pAllocator)
	{
		m_pAllocator = pAllocator;
	}
private:
	template <typename T> void write(T value)
	{
		write((uint8*)&value, sizeof(T));
	}
	template <typename T> T read()
	{
		T r;
		read((uint8*)&r, sizeof(T));
		return r;
	}
	void read(uint8* dest, int size );

	void write(const uint8 *src, int size);

private:
	static IAllocator *m_pAllocator;

	uint32 m_readPos;
	uint32 m_writePos;
	const char* m_pReadBuffer;
	uint32 m_uReadBufferSize;

	IBuffer* m_pWriteBuffer;
};

class ByteBuffer
{
    public:
        const static size_t DEFAULT_SIZE = 0x1000;

        ByteBuffer(): _rpos(0), _wpos(0)
        {
            _storage.reserve(DEFAULT_SIZE);
        }
        ByteBuffer(size_t res): _rpos(0), _wpos(0)
        {
            _storage.reserve(res);
        }
        ByteBuffer(const ByteBuffer &buf): _rpos(buf._rpos), _wpos(buf._wpos), _storage(buf._storage) { }

        void clear()
        {
            _storage.clear();
            _rpos = _wpos = 0;
        }

        template <typename T> void append(T value)
        {
            append((uint8 *)&value, sizeof(value));
        }
        template <typename T> void put(size_t pos,T value)
        {
            put(pos,(uint8 *)&value,sizeof(value));
        }

        ByteBuffer &operator<<(bool value)
        {
            append<char>((char)value);
            return *this;
        }
        ByteBuffer &operator<<(uint8 value)
        {
            append<uint8>(value);
            return *this;
        }
        ByteBuffer &operator<<(uint16 value)
        {
            append<uint16>(value);
            return *this;
        }
        ByteBuffer &operator<<(uint32 value)
        {
            append<uint32>(value);
            return *this;
        }
        ByteBuffer &operator<<(uint64 value)
        {
            append<uint64>(value);
            return *this;
        }
        ByteBuffer &operator<<(int8 value)
        {
            append<int8>(value);
            return *this;
        }
        ByteBuffer &operator<<(int16 value)
        {
            append<int16>(value);
            return *this;
        }
        ByteBuffer &operator<<(int32 value)
        {
            append<int32>(value);
            return *this;
        }
        ByteBuffer &operator<<(int64 value)
        {
            append<int64>(value);
            return *this;
        }
        ByteBuffer &operator<<(float value)
        {
            append<float>(value);
            return *this;
        }
        ByteBuffer &operator<<(double value)
        {
            append<double>(value);
            return *this;
        }
        ByteBuffer &operator<<(const std::string &value)
        {
            append((uint8 const *)value.c_str(), value.length());
            append((uint8)0);
            return *this;
        }
        ByteBuffer &operator<<(const char *str)
        {
            append((uint8 const *)str, str ? strlen(str) : 0);
            append((uint8)0);
            return *this;
        }

        ByteBuffer &operator>>(bool &value)
        {
            value = read<char>() > 0 ? true : false;
            return *this;
        }
        ByteBuffer &operator>>(uint8 &value)
        {
            value = read<uint8>();
            return *this;
        }
        ByteBuffer &operator>>(uint16 &value)
        {
            value = read<uint16>();
            return *this;
        }
        ByteBuffer &operator>>(uint32 &value)
        {
            value = read<uint32>();
            return *this;
        }
        ByteBuffer &operator>>(uint64 &value)
        {
            value = read<uint64>();
            return *this;
        }
        ByteBuffer &operator>>(int8 &value)
        {
            value = read<int8>();
            return *this;
        }
        ByteBuffer &operator>>(int16 &value)
        {
            value = read<int16>();
            return *this;
        }
        ByteBuffer &operator>>(int32 &value)
        {
            value = read<int32>();
            return *this;
        }
        ByteBuffer &operator>>(int64 &value)
        {
            value = read<int64>();
            return *this;
        }

        ByteBuffer &operator>>(float &value)
        {
            value = read<float>();
            return *this;
        }
        ByteBuffer &operator>>(double &value)
        {
            value = read<double>();
            return *this;
        }
        ByteBuffer &operator>>(std::string& value)
        {
            value.clear();
            while (rpos() < size())                         // prevent crash at wrong string format in packet
            {
                char c=read<char>();
                if (c==0)
                    break;
                value+=c;
            }
            return *this;
        }

        uint8 operator[](size_t pos)
        {
            return read<uint8>(pos);
        }

        size_t rpos()
        {
            return _rpos;
        };

        size_t rpos(size_t rpos_)
        {
            _rpos = rpos_;
            return _rpos;
        };

        size_t wpos()
        {
            return _wpos;
        }

        size_t wpos(size_t wpos_)
        {
            _wpos = wpos_;
            return _wpos;
        }

        template <typename T> T read()
        {
            T r=read<T>(_rpos);
            _rpos += sizeof(T);
            return r;
        };
        template <typename T> T read(size_t pos) const
        {
            assert(pos + sizeof(T) <= size());
            return *((T const*)&_storage[pos]);
        }

        void read(uint8 *dest, size_t len)
        {
            assert(_rpos  + len  <= size());
            memcpy(dest, &_storage[_rpos], len);
            _rpos += len;
        }

        const uint8 *contents() const { return _storage.data(); }

        size_t size() const { return _storage.size(); }
        bool empty() const { return _storage.empty(); }

        void resize(size_t newsize)
        {
            _storage.resize(newsize);
            _rpos = 0;
            _wpos = size();
        };
        void reserve(size_t ressize)
        {
            if (ressize > size()) _storage.reserve(ressize);
        };

        void append(const std::string& str)
        {
            append((uint8 const*)str.c_str(),str.size() + 1);
        }
        void append(const char *src, size_t cnt)
        {
            return append((const uint8 *)src, cnt);
        }
        void append(const uint8 *src, size_t cnt)
        {
            if (!cnt) return;

            assert(size() < 10000000);

            if (_storage.size() < _wpos + cnt)
                _storage.resize(_wpos + cnt);
            memcpy(&_storage[_wpos], src, cnt);
            _wpos += cnt;
        }
        void append(const ByteBuffer& buffer)
        {
            if(buffer.size()) append(buffer.contents(),buffer.size());
        }

		template<class T>
		void appendProtoData(T& p)
		{
			appendProtoData(&p);
		}

		template<class T>
		void appendProtoData(T* p)
		{
			unsigned int cnt = p->Size();

			if (_storage.size() < _wpos + cnt)
				_storage.resize(_wpos + cnt);
			p->Serialize((char*)&_storage[_wpos], cnt);
			_wpos += cnt;
		}

        void put(size_t pos, const uint8 *src, size_t cnt)
        {
            assert(pos + cnt <= size());
            memcpy(&_storage[pos], src, cnt);
        }

		size_t Size() const
		{
			return size() + 4;
		}

		bool Serialize(char *pBuffer, unsigned &uSize) const
		{
			if (uSize < Size())
				return false;
			*(int*)pBuffer = Size();
			memcpy(pBuffer + 4, _storage.data(), _storage.size());
			uSize = Size();
			return true;
		}

		bool Unserialize(const char *pPacket, int &remain)
		{
			int nSize = 0;
			if (remain < 4)
				return false;

			nSize = *(int*)pPacket;
			if (nSize < 4)
				return false;
			nSize -= 4;
			_storage.resize(nSize);
			memcpy((char*)_storage.data(), pPacket + 4, nSize);
			remain -= nSize + 4;
			return true;
		}

    protected:

        size_t _rpos, _wpos;
        std::vector<uint8> _storage;
};

//template <typename T> ByteBuffer &operator<<(ByteBuffer &b, std::vector<T> v)
//{
//    b << (uint32)v.size();
//    for (typename std::vector<T>::iterator i = v.begin(); i != v.end(); i++)
//    {
//        b << *i;
//    }
//    return b;
//}
//
//template <typename T> ByteBuffer &operator>>(ByteBuffer &b, std::vector<T> &v)
//{
//    uint32 vsize;
//    b >> vsize;
//    v.clear();
//    while(vsize--)
//    {
//        T t;
//        b >> t;
//        v.push_back(t);
//    }
//    return b;
//}
//
//template <typename T> ByteBuffer &operator<<(ByteBuffer &b, std::list<T> v)
//{
//    b << (uint32)v.size();
//    for (typename std::list<T>::iterator i = v.begin(); i != v.end(); i++)
//    {
//        b << *i;
//    }
//    return b;
//}
//
//template <typename T> ByteBuffer &operator>>(ByteBuffer &b, std::list<T> &v)
//{
//    uint32 vsize;
//    b >> vsize;
//    v.clear();
//    while(vsize--)
//    {
//        T t;
//        b >> t;
//        v.push_back(t);
//    }
//    return b;
//}
//
//template <typename K, typename V> ByteBuffer &operator<<(ByteBuffer &b, std::map<K, V> &m)
//{
//    b << (uint32)m.size();
//    for (typename std::map<K, V>::iterator i = m.begin(); i != m.end(); i++)
//    {
//        b << i->first << i->second;
//    }
//    return b;
//}
//
//template <typename K, typename V> ByteBuffer &operator>>(ByteBuffer &b, std::map<K, V> &m)
//{
//    uint32 msize;
//    b >> msize;
//    m.clear();
//    while(msize--)
//    {
//        K k;
//        V v;
//        b >> k >> v;
//        m.insert(make_pair(k, v));
//    }
//    return b;
//}
#endif
