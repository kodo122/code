#include "Precompiled.h"
#include "../include/ServerApp.h"
#include "../include/IConfig.h"
#include "../include/Platform.h"
#include "../include/STime.h"
#include "../include/Random.h"
#include "../include/Log.h"
#include "../include/lua_tinker.h"

ServerApp::ServerApp()
{
	//m_state = app_state_none;
}

int ServerApp::InitUpdate()
{
	return 0;
}

void ServerApp::PreRun()
{
}

void ServerApp::Run(const char* pServerName)
{
	int nRetCode = 0;
	IConfig *pConfig = NULL;
	bool bIsContinue = true;

	char szConfigFile[PATH_MAX];
	sprintf(szConfigFile, "%s.config", pServerName);

	CTimer::SetTime();
	SRand(CTimer::GetTime());

	LOG_PARAM logParam;
	strcpy(logParam.szPath, "log");
	strcpy(logParam.szIdent, pServerName);
	logParam.Options = (LOG_OPTIONS)(LOG_OPTION_FILE + LOG_OPTION_CONSOLE);
	logParam.nMaxLineEachFile = 65535;
	LogInit(logParam);

	nRetCode = platform::PlatFormInit();
	PRINT_PROCESS_ERROR(nRetCode);

	pConfig = CreateTabConfig(szConfigFile);
	PRINT_PROCESS_ERROR(pConfig);
	nRetCode = Initialize(pConfig);
	PRINT_PROCESS_ERROR(nRetCode);
	
	while (bIsContinue)
	{
		CTimer::SetTime();
		nRetCode = InitUpdate();
		PRINT_PROCESS_ERROR(nRetCode != -1);
		
		bIsContinue = !!nRetCode;
	}
	bIsContinue = true;

	PreRun();

	printf("server init ok...\n");

	while (bIsContinue)
	{
		CTimer::SetTime();
		bIsContinue = Update();
		platform::sleep(4);
	}

Exit0:
	return;
}
