
local _btConfig = 
{
	serverMain = 
	{
		type = "sequence",
		children = 
		{
			{type = "createModule", class = "DBServer", name = "_dbServer", },
			{type = "createModule", class = "DBExecutor", name = "_dbExecutor", },			
		}
	},
}
function GetBtConfig(name)
	return _btConfig[name]
end

function include(path)
	require("lua/" .. path)
end

local files = 
{
	"BehaviorTree",
	"ModuleManager",
	
	--------------------------

	"StringBuffer",
	"SMsg",
	"RPC",
	"PlatformCpp",
	"Net",
	"Socket",
	"NetHandler",

	--------------------------

	"DBExecutor",
	"DBServer",
	"DBSqlCreater",
	"DBUser",
}
for _, v in ipairs(files) do
	include(v)
end

isError = false
function MainInit()
	
	xpcall(
		function()
			_mysqlHelper = MysqlHelper:new()
			local m = BehaviorTree:new("serverMain")
			_moduleManager:Push(m)
		end,
		function()
			local msg = debug.traceback()
			MainError(msg)
		end
	)

	return true
end

function MainUpdate()
	
	if isError then
		return true
	end
	
	xpcall(
		function()
			_moduleManager:Update()
		end,
		function(errorMsg)
			local errorStack = debug.traceback()
			MainError(errorMsg, errorStack)
		end
	)
	
	return true
end

function MainLateUpdate()
	
	if isError then
		return
	end
	
	xpcall(
		function()
			_moduleManager:LateUpdate()
		end,
		function(errorMsg)
			local errorStack = debug.traceback()
			MainError(errorMsg, errorStack)
		end
	)
end

function MainError(errorMsg, errorStack)
	print(errorMsg)
	print(errorStack)
	isError = true
end
