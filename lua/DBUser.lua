
User = {}
User.__index = User

function User:new(socket)
	
	local o = {}
	setmetatable(o, self)

	o.socket = socket
	o.rpc = RPC:new()
	o.rpc:SetSocket(socket)
	o.netHandler = NetHandler:new(o.socket, o.rpc, o)

	return o
end

function User:Init()

	function Insert(tableName, tableContent)
		return _dbExecutor:InsertSql(tableName, tableContent)
	end
	
	function Update(tableName, tableContent, where)
		return _dbExecutor:UpdateSql(tableName, tableContent, where)
	end
	
	self.rpc:Register("Insert", Insert)
	self.rpc:Register("Update", Update)
end

function User:Update()
	self.netHandler:Update()
end
