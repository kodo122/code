
luanet.load_assembly('UnityEngine')
luanet.load_assembly('Assembly-CSharp')

LuaHelper = luanet.import_type('LuaHelper')

function include(path)
	LuaHelper.RequireLua(path)
end

include("CRequire")


isError = false
function MainInit()
	
	xpcall(
		function()
			_runtime = {}
			_platform = Platform:new()
			_moduleManager:Push(_platform, "global")
			_time = STime:new()
			_moduleManager:Push(_time, "global")
			local m = BehaviorTree:new("clientStartup")
			_moduleManager:Push(m, "global")
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
		return
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
end

function MainError(errorMsg, errorStack)
	print(errorMsg)
	print(errorStack)
	isError = true
end
