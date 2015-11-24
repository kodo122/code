
PlayerDataManager = {}
PlayerDataManager.__index = PlayerDataManager

function PlayerDataManager:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.playerDatas = {}
	o.accountRoles = {}
	o.maxRoleId = 1

	return o
end

function PlayerDataManager:Init()
	
	local retCode
	self.mysqlHelper = MysqlHelper:new()
	self.mysqlHelper:Init()
	self.sqlCreater = SqlCreater:new(self.mysqlHelper)
	
	retCode = self.mysqlHelper:Connect(DBIp, DBPort, DBUserName, DBPasswd, DataBase)
	if not retCode then
		return false
	end
		
	--test
	--self:CreateNewRole(77777, "zk")
	
	local sql = "select * from roletable"
	retCode = self.mysqlHelper:Query(sql, string.len(sql))
	if not retCode then
		return false
	end
	retCode = self.mysqlHelper:UseResult()
	if not retCode then
		return false
	end	
	
	return true
end

function PlayerDataManager:Update()
	if not _runtime.isPlayerDataReady then
		self:UpdateLoadPlayerData()
	end
end

function PlayerDataManager:UpdateLoadPlayerData()
	
	local mysqlHelper = self.mysqlHelper
	
	local count = 0
	while count < 1000 do

		if not mysqlHelper:NextRow() then
			mysqlHelper:FreeResult()
			_runtime.isPlayerDataReady = true
			--PlayerDataManager.Update = nil
			break
		end
		
		local playerData = PlayerData:new()

		playerData.roleId = mysqlHelper:GetUInt32(0)
		playerData.accountId = mysqlHelper:GetUInt32(1)
		playerData.roleName = mysqlHelper:GetString(2)

		-------------------------------------------------------------------------------------------
		self.maxRoleId = self.maxRoleId < playerData.roleId and playerData.roleId + 1 or self.maxRoleId
		-------------------------------------------------------------------------------------------
		
		local roleDataStr = mysqlHelper:GetString(3)
		local buffer = StringBuffer:new(roleDataStr)
		playerData.roleData = RoleData:new()
		
		playerData.roleData:Unserialize(buffer)
		self.playerDatas[playerData.roleId] = playerData
		self.accountRoles[playerData.accountId] = self.accountRoles[playerData.accountId] or {}
		table.insert(self.accountRoles[playerData.accountId], playerData.roleId)

		count = count + 1
	end
end

function PlayerDataManager:GetPlayerDataByRoleId(roleId)
	return self.playerDatas[roleId]
end

function PlayerDataManager:CreateNewRole(accountId, roleName)
	
	local newRoleId = self.maxRoleId
	local roleData = self:CreateNewRoleData()
	
	local buffer = StringBuffer:new()
	roleData:Serialize(buffer)
	local roleDataStr = buffer:ToString()
	
	local tableContent = 
	{
		{ name = "roleId", type = "uint", content = newRoleId, },
		{ name = "accountId", type = "uint", content = accountId, },
		{ name = "roleName", type = "string", content = roleName, },
		{ name = "roleData", type = "string", content = roleDataStr, },
	}
	
	local sql = self.sqlCreater:GenInsertSql("roleTable", tableContent)
	
	if not self.mysqlHelper:Query(sql, string.len(sql)) then
		return false
	end
	
	local playerData = PlayerData:new()
	playerData.roleId = newRoleId
	playerData.accountId = accountId
	playerData.roleName = roleName
	playerData.roleData = roledata
	
	self.playerDatas[newRoleId] = playerData
	self.accountRoles[accountId] = self.accountRoles[accountId] or {}
	table.insert(self.accountRoles[accountId], newRoleId)
	
	self.maxRoleId = self.maxRoleId + 1
	return true
end

function PlayerDataManager:CreateNewRoleData()

	local roleData = RoleData:new()
	
	--todo fill data
	
	return roleData
end

