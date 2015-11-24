
local luas = 
{
	"StringBuffer",
	"SMsg",
	"RPC",
	"Net",
	"Socket",
	"NetHandler",
	
	"DBSqlCreater",
	
	--------------------------
	"BehaviorTree",
	"ModuleManager",

	--------------------------

	"PlatformCpp",

	--------------------------
	"RoleData",
	"PlayerData",
	
	--------------------------

	"LPlayerServer",
	"LPlayer",
	"LPlayerManager",
	"LPlayerDataManager",
}

for i = 1, #luas do
	include(luas[i])
end
