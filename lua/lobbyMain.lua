
local _btConfig = 
{
	serverMain = 
	{
		type = "sequence",
		children = 
		{
			{type = "createModule", class = "PlayerServer", name = "_playerServer", },
			{type = "createModule", class = "PlayerManager", name = "_playerManager", },
			{type = "createModule", class = "PlayerDataManager", name = "_playerDataManager", },					
		}
	},
}
function GetBtConfig(name)
	return _btConfig[name]
end

function include(path)
	require("lua/" .. path)
end

include("LRequire")

isError = false
function MainInit()
	
	xpcall(
		function()
			_runtime = {}
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
