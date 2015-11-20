
RoleDataLoader = {}
RoleDataLoader.__index = RoleDataLoader

function RoleDataLoader:new()
	
	local o = {}
	setmetatable(o, self)
	
	return o
end

function RoleDataLoader:Init()
end

function RoleDataLoader:Start()
end

function RoleDataLoader:Update()

	local service = 
	_app:ReplaceService()
end
