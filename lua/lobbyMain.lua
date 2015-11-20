--[[
local lobbyInitService = 
{
	modules = 
	{
	
	},
}
PushServiceConfig("lobbyInitService", lobbyInitService)

local lobbyRunService = 
{
	modules = 
	{
	
	},
}
PushServiceConfig("lobbyRunService", lobbyRunService)
]]
print("xxx")

local mysqlHelper = MysqlHelper:new()
local s = mysqlHelper:GetBlob(1)

print(s)
print(string.len(s))


function MainInit()
	print("abc")
	local service = Service:new("lobbyInitService")
	_app:PushService(service)

	return true
end

function MainUpdate()
	return _app:Run()
end
