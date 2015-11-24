
Player = {}
Player.__index = Player

function Player:new(socket)
	
	local o = {}
	setmetatable(o, self)

	o.accountId = nil
	o.roleId = nil

	o.socket = socket
	o.rpc = RPC:new()
	o.rpc:SetSocket(socket)
	o.netHandler = NetHandler:new(o.socket, o.rpc, o)

	o.isOnline = true

	return o
end

function Player:Init()
	self:StartAccountDeal()
end

function Player:Update()
	self.netHandler:Update()
end

function Player:Release()
	self.socket:Close()
end

function Player:OnDisconnect()	
	self.socket:Close()
end

function Player:StartAccountDeal()

	function Login(name, pwd)
		print(name .. " login")
		self:StartRoleDeal()
		return true
	end
	
	self.rpc:Register("Login", Login)
end

function Player:StartRoleDeal()
	
	function SelectRole()
		self:StartLogicDeal()
	end
	
	function CreateRole()

		
	end

	self.rpc:Register("SelectRole", SelectRole)
end

function Player:StartLogicDeal()
	
end
