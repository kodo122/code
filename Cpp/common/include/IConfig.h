#pragma once

class IConfig
{
public:
	virtual int GetInt(const char* pName) = 0;
	virtual const char* GetString(const char* pName) = 0;
};

IConfig* CreateTabConfig(const char* pConfigFile);
