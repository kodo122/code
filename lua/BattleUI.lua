
BattleUI = {}
BattleUI.__index = BattleUI

function BattleUI:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function BattleUI:Init()
	
	self.ui = UI:new()
	self.ui:Init("battle_ui")
	
	self.goTipsObj = _platform.FindChild(self.ui.object, "jiantou")
	self.isGoTips = false
	self.goTipsPos = nil
	
	--_fightRuntime.rollInfoUI = RollInfoUI:new()
	--_fightRuntime.rollInfoUI:Init(self.ui.object)
	
	self.skillBtns = {}
	for i = 1, 4 do
		self.skillBtns[i] = BattleSkillBtn:new()
		self.skillBtns[i]:Init(self.ui.object, "hit/Button_" .. i)
	end
	
	self.attackTimer = STimer:new()
	self.attackTimer:SetTimeOutTick(500)
	self.skillTimer = STimer:new()
	self.skillTimer:SetTimeOutTick(500)
	
	function OnClickShoot()
		
		_fightRuntime.isShoot = true
		--self.attackTimer:Reset()
	end
	
	function OnClickMoveLeft()
		_fightRuntime.moveLeft = true
	end
	
	function OnClickMoveRight()
		_fightRuntime.moveRight = true
	end
	
	function OnClickSkill(tag)
		
		if self.skillBtns[tag] and not self.skillBtns[tag]:IsCD() then
			--_fightRuntime.isCastSkill = true
			--_fightRuntime.castSkillIndex = tag
			self.skillTimer:Reset()
		end
	end
	
	self.ui:RegisterEvent("hit/Button_0", 1, OnClickShoot, 0)
	self.ui:RegisterEvent("hit/Button_1", 1, OnClickMoveLeft, 1)
	self.ui:RegisterEvent("hit/Button_2", 1, OnClickMoveRight, 2)
	--self.ui:RegisterEvent("hit/Button_3", 1, OnClickSkill, 3)
	--self.ui:RegisterEvent("hit/Button_4", 1, OnClickSkill, 4)	
end

function BattleUI:StartCD(index)
	self.skillBtns[index]:SetCD(2000)
end

function BattleUI:Update()
	
	if _platform == "windows" then
	
		function OnClickShoot()
			
			_fightRuntime.isShoot = true
			--self.attackTimer:Reset()
		end
		
		function OnClickMoveLeft()
			_fightRuntime.moveLeft = true
		end
		
		function OnClickMoveRight()
			_fightRuntime.moveRight = true
		end
		
		if Input.GetKeyDown("1") then
			OnClickShoot(0)
		end
		if Input.GetKeyDown("2") then
			OnClickMoveLeft(1)
		end
		if Input.GetKeyDown("3") then
			OnClickMoveRight(2)
		end

	end
	
	for _, val in pairs(self.skillBtns) do
		val:Update()
	end
	
	--[[
	if _fightRuntime.isAttack then
		if self.attackTimer:IsTimeOut() then
			_fightRuntime.isAttack = false
		end
	end
	if _fightRuntime.isCastSkill then
		if self.skillTimer:IsTimeOut() then
			_fightRuntime.isCastSkill = false
		end
	end
	]]

	if self.isGoTips then
		self:UpdateGoTips()
	end
	self.ui:Update()
	--_fightRuntime.rollInfoUI:Update()
end

function BattleUI:Release()
	self.ui:Release()
end

function BattleUI:GetObject()
	return self.ui.object
end

function BattleUI:StartGoTips(pos)
	self.isGoTips = true
	self.goTipsPos = pos
	self.goTipsObj:SetActive(true)
	self:UpdateGoTips()
end

function BattleUI:EndGoTips()
	self.isGoTips = false
	self.goTipsObj:SetActive(false)
end

function BattleUI:UpdateGoTips()

	local heroPos = _runtime.hero:GetPos()
	local dir = cc.GetDir(heroPos, self.goTipsPos)
	
	local newScreenPos = cc.pAdd(_screen.midPos, cc.pMul(dir, 200)) 
	local newPos = _uguiCamera:ScreenToWorldPoint(Vector3(newScreenPos.x, newScreenPos.y, 3))
	
	self.goTipsObj.transform.position = newPos

	local radian = cc.pToAngleSelf(dir)
	angle = cc.RadiansToDegrees(radian) - 90
	if angle < 0 then
		angle = angle + 360
	end

	self.goTipsObj.transform.eulerAngles = Vector3(0, 0, angle)
end
