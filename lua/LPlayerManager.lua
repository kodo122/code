--[[
	
	玩家管理
	1、玩家帧运行
	2、帐号id查找玩家
	3、角色id查找玩家
	4、重复登录，踢旧玩家下线
	5、断线重连

]]

PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager:new()
	
	local o = {}
	setmetatable(o, self)

	o.players = {}
	
	o.accountPlayers = {}
	o.rolePlayers = {}

	return o
end

function PlayerManager:PushPlayer(player)
	self.players[player] = player
end

function PlayerManager:Update()
	
	for _, v in pairs(self.players) do
		v:Update()
	end
end

function PlayerManager:AddAccountPlayer(accountId, player)
	local oldAccountPlayer = self.accountPlayers[accountId]
	if oldAccountPlayer then
		self:KickOut(oldAccountPlayer)
	end
	self.accountPlayers[accountId] = player
end

function PlayerManager:AddRolePlayer(roleId, player)
	self.rolePlayers[roleId] = player
end

function PlayerManager:KickOut(player)
	
	if player.accountId and self.accountPlayers[player.accountId] == player then
		self.accountPlayers[player.accountId] = nil
	end
	if player.roleId and self.rolePlayers[player.roleId] == player then
		self.rolePlayers[player.roleId] = nil
	end
	
	player:Release()
	self.players[player] = nil
end
