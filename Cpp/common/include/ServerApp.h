#pragma once

class ServerApp
{
	//enum
	//{
	//	app_state_none = 0,
	//	app_state_init,
	//	app_state_run,
	//	app_state_error,
	//};
public:
	ServerApp();
	void Run(const char* pServerName);
private:
	//return: 0 ok,  1 continue, -1 fail
	virtual int InitUpdate();

	virtual bool Initialize(class IConfig *pConfig) = 0;
	virtual void PreRun() = 0;
	virtual bool Update() = 0;
//private:
//	int m_state;
};
