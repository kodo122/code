#pragma once
#include <stdint.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <ext/hash_map>
#include <ext/hash_set>
#define _hash_map __gnu_cxx::hash_map
#define _hash_set __gnu_cxx::hash_set

#define _DLL_API									extern"C"
#define _DLL_CLASS

typedef unsigned int uint;

typedef int8_t  int8;
typedef int16_t int16;
typedef int32_t int32;
typedef int64_t int64;

typedef uint8_t  uint8;
typedef uint16_t uint16;
typedef uint32_t uint32;
typedef uint64_t uint64;

#ifndef CONTAINING_RECORD	
#define CONTAINING_RECORD(address, type, field) ((type *)( \
	(char *)(address) - \
	(ptrdiff_t)(&((type *)0)->field)))
#endif
