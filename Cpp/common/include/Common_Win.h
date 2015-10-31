#pragma once

#include <winsock2.h>
#include <windows.h>
#include <WS2tcpip.h>
#include <Mswsock.h>
#include <WinNT.h>
#include <io.h>

#include <hash_map>
#include <hash_set>
#define _hash_map stdext::hash_map
#define _hash_set stdext::hash_set

typedef unsigned int uint;

typedef __int8  int8;
typedef __int16 int16;
typedef __int32 int32;
typedef __int64 int64;

typedef unsigned __int8  uint8;
typedef unsigned __int16 uint16;
typedef unsigned __int32 uint32;
typedef unsigned __int64 uint64;


#ifndef _WINDLL
#define _DLL_API extern"C" __declspec(dllimport)
#define _DLL_CLASS __declspec(dllimport)
#else
#define _DLL_API extern"C" __declspec(dllexport)
#define _DLL_CLASS __declspec(dllexport)
#endif
