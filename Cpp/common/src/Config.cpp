#include "Precompiled.h"
#include "../include/IConfig.h"

class TabConfig : public IConfig
{
public:
	bool Initialize(const char* pConfigFile)
	{
		int nResult = 0;
		int nRetCode = 0;
		
		char content1[512];
		char content2[512];
		std::string str;
		std::vector<std::string> lineString;

		if (!pConfigFile)
			return false;
		FILE *pFile = fopen(pConfigFile, "r");
		PROCESS_ERROR(pFile);

		while (true)
		{
			nResult = fgetc(pFile);

			if (nResult == '\n' || nResult == '\r' || nResult == -1)
			{
				if (!str.empty() && str.size() < 512)
				{
					if (2 == sscanf(str.c_str(), "%s	%s", content1, content2))
						m_pConfigTable[content1] = content2;
				}
				str.clear();
			}
			else
				str.push_back((char)nResult);

			if (nResult == -1)
				break;
		}

		nResult = 1;
Exit0:
		if (pFile)
		{
			fclose(pFile);
			pFile = NULL;
		}
		return nResult;
	}
	int GetInt(const char* pName)
	{
		std::map<std::string, std::string>::iterator it = m_pConfigTable.find(pName);
		if (it == m_pConfigTable.end())
			return 0;
		return atoi(it->second.c_str());
	}
	const char* GetString(const char* pName)
	{
		std::map<std::string, std::string>::iterator it = m_pConfigTable.find(pName);
		if (it == m_pConfigTable.end())
			return NULL;
		return it->second.c_str();
	}
private:
	std::map<std::string, std::string> m_pConfigTable;
};

IConfig* CreateTabConfig(const char* pConfigFile)
{
	TabConfig* pTabConfig = new TabConfig;
	if (pTabConfig->Initialize(pConfigFile))
		return pTabConfig;
	PROCESS_DELETE(pTabConfig);
	return NULL;
}
