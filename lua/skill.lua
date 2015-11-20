
SkillThing = 
{
	"animate",
	"damage",
	"move",

	"stopMove",
	"pushBullet",
	"effect",
	"shake",
	"over",
	"playSound",
	
	"moveToNearstEnemy",
	"forwardToNearstEnemy",

	"touchDamage",
	"bullet",
	
	"canCastAnother",
	
	"cameraMove",
	
	"cameraFollow",	
	"canControlMove",
}

SkillEffectType = 
{
	sceneBack = 1,
	sceneFront = 2,
	sprite = 3,
}

SkillPart = {}
SkillPart.__index = SkillPart


SkillPart.handler = 
{
	animate = function(self, info)
		local isLoop = false
		if info.isLoop then
			isLoop = true
		end
		
		self.unitRenderer:Play(info.animateName, isLoop, false, true)
		self.isPlayOverOver = info.isPlayOverOver
	end,

	damage = function(self, info)
		
		local hitCount = self:Damage(info)
		
		if hitCount ~= 0 and info.hitStopTime and math.random(1, 100) > 70 then
			_time:Scale(0, info.hitStopTime)
		end
		
		if hitCount ~= 0 and info.hitShakeLvl then
			_runtime.Shaker:Shake(info.hitShakeLvl)
		end
		
		if hitCount ~= 0 and info.hitEffect then
			
			local effect = _resourceManager:CreateEffect(info.hitEffect)
			--AddToChild(effect, self.unitRenderer.body, true)
			
			self.unitRenderer.body:AddChild(effect, nil, false, info.useTime or 2000)
			
			--if info.offsetDis then
			--	local dir = self.body:GetDir()
			--	local pos1 = self.body:GetPos()
			--	local dir1 = cc.pNormalize(dir)
			--	local pos2 = cc.pAdd(pos1, cc.pMul(dir1, info.offsetDis))
			--	effect.transform.position = cc.pToVec3(pos2)
			--	effect.transform.eulerAngles = self.body:GetEulerAngles()
			--else
				effect.transform.position = self.body:GetVec3()
				effect.transform.eulerAngles = self.body:GetEulerAngles()
			--end
			
			if not info.life then
				self.effects[effect] = effect
			elseif info.life == "skill" then
				self.skill.effects[effect] = effect
			end			
		end
	end,

	move = function(self, info)
		self.isMoveOverOver = info.isMoveOverOver
		
		local moveType = info.moveType or "common"
		if moveType == "common" then
			local moveBy = cc.pMul(self.unit:GetDir(), info.dis)
			self.moveAction = MoveByAction:new(moveBy, IntervalTime:new(info.dis / info.speed))
			self.body:RunAction(self.moveAction)
			
			-- for drag
			self.moveTo = cc.pAdd(self.unit:GetPos(), moveBy)
			self.moveSpeed = info.speed
		elseif moveType == "missile" then
		
			local pos = self.unit:GetPos()
			local dir = self.unit:GetDir()
			local dis = self.castData.dis or info.dis

			local moveBy = cc.pMul(self.unit:GetDir(), dis)			

			local target = cc.pAdd(pos, moveBy)
			local pos1 = cc.pRotateByAngle(target, pos, math.rad(self.castData.offsetAngle))
			local dir1 = cc.GetDir(pos, pos1)
			
			local moveby1 = cc.pMul(dir1, 2)
			local moveby11 = cc.pMul(moveby1, -1)
			
			local target1 = cc.pAdd(target, moveby11)
			local moveby2 = cc.pSub(target1, pos)
			
			local action1 = MoveByAction:new(moveby1, RateOutIntervalTime:new(0.5, 1))
			local action2 = MoveByAction:new(moveby2, RateInIntervalTime:new(0.5, 5))
			local action3 = SpawnAction:new(action2, action1)
			
			self.moveAction = action3
			self.body:RunAction(self.moveAction)
		elseif moveType == "arrow" then
			
			--todo
			local moveBy = cc.pMul(self.unit:GetDir(), info.dis)
			self.moveAction = MoveByAction:new(moveBy, IntervalTime:new(info.dis / info.speed))
			self.body:RunAction(self.moveAction)
			
			-- for drag
			self.moveTo = cc.pAdd(self.unit:GetPos(), moveBy)
			self.moveSpeed = info.speed
		end
		
		if info.moveLayer then
			self.body:SetMoveLayer(info.moveLayer)
		end
	end,
	
	moveToNearstEnemy = function(self, info)
		
		local nearstEnemy, nearstDis = _fightRuntime:NearstEnemy(self.unit.camp, self.unit:GetPos(), info.radius)
		self.isMoveOverOver = info.isMoveOverOver		
			
		if nearstEnemy then
			
			local selfPos = self.unit:GetPos()
			local enemyPos = nearstEnemy:GetPos()
			local moveDis, moveBy, moveDir = cc.GetDeltaOnSegment(selfPos, enemyPos, 3, info.minDis or 1)
			assert(moveDir)
		
			self.unit:SetDir(moveDir)
			if moveDis ~= 0 then
				
				self.moveAction = MoveByAction:new(moveBy, IntervalTime:new(moveDis / info.speed))
				self.body:RunAction(self.moveAction)
				
				if info.moveLayer then
					self.body:SetMoveLayer(info.moveLayer)
				end
				
				if info.isNearUnitOver then
					self.isNearUnitOver = true
					self.targetUnit = nearstEnemy
					self.minDis = info.minDis
				end
			end
		end
	end,

	forwardToNearstEnemy = function(self, info)
		
		local nearstEnemy, nearstDis = _fightRuntime:NearstEnemy(self.unit.camp, self.unit:GetPos(), info.radius)
		
		if nearstEnemy then
			local selfPos = self.unit:GetPos()
			local enemyPos = nearstEnemy:GetPos()
			local dir = cc.GetDir(selfPos, enemyPos)
			self.unit:SetDir(dir)
		end
	end,

	pushBullet = function(self, info)
	end,
	
	effect = function(self, info)
		
		local effect = _resourceManager:CreateEffect(info.id)
		--AddToChild(effect, self.unitRenderer.body, true)
		
		self.unitRenderer.body:AddChild(effect, nil, true, info.useTime or 5000)
		
		local pos = self.body:GetPos()			
		if info.offsetDis then
			local dir = self.body:GetDir()
			pos = cc.pAdd(pos, cc.pMul(dir, info.offsetDis))
		end
		effect.transform.position = Vector3(pos.x, self.body:GetY(), pos.y)
		effect.transform.eulerAngles = self.body:GetEulerAngles()
					
		if not info.life then
			self.effects[effect] = effect
		elseif info.life == "skill" then
			self.skill.effects[effect] = effect
		end
	end,
	
	over = function(self, info)
		self:OnOver()
	end,
	
	shake = function(self, info)
		_runtime.Shaker:Shake(info.lvl)
	end,
	
	stopMove = function(self, info)
		if self.moveAction then
			self.body:StopAction(self.moveAction)
			self.moveAction = nil
		end
	end,
	
	touchDamage = function(self, info)

		self.touchDamage = true
		self.touchDamageInfo = info
		self.touchDamageOver = info.touchDamageOver
	end,
	
	touchDamageOver = function(self, info)

		self.touchDamage = false
		self.touchDamageInfo = nil
		self.touchDamageOver = false
	end,
	
	bullet = function(self, info)
		
		local dir = self.body:GetDir()		
		local pos = self.body:GetPos()			
		if info.offsetDis then
			pos = cc.pAdd(pos, cc.pMul(dir, info.offsetDis))
		end
				
		local t = 
		{
			dir = dir,
			pos = pos,
			y = info.y,	
			bulletId = info.bulletId,
			unitType = BulletUnit,
			camp = self.unit.camp,
			actionNode = BulletRootNode,
			layerMask = 0,
		}
							
		local unit = _runtime.unitManager:CreateBullet(t)
		unit.bulletData = info.bulletData

		unit:Enter()
	end,
	
	canCastAnother = function(self, info)
		self.skill.canCastAnother = true
	end,
	
	cameraMove = function(self, info)
		_runtime.camera:Move(info.dis, info.useTime)
	end,
	
	cameraFollow = function(self, info)
		
		self.isChangeCameraFollow = true
		if info.bone then
			local gameObject = self.body:GetBone(info.bone)
			_runtime.camera:FollowGameObject(gameObject)
		else
			_runtime.camera:FollowObject(self.body)
		end
	end,
	
	canControlMove = function(self, info)
		self.canControlMove = true
		self.unit:SetSpeed(info.speed)
	end,
	
	visible = function(self, info)
		self.unitRenderer:Visible(info.visible)
	end,

	turnAround = function(self, info)
		local dir = self.body:GetDir()
		self.body:Forward(cc.pMul(dir, -1))
	end,
	
	clearDamageTable = function(self, info)
		self.excludeTable = {}
	end,
}

function SkillPart:new(config)
	
	local o = {}
	setmetatable(o, self)
	
	o.config = config
	o.startTime = 0	
	o.timeHandlesIndex = 0
	o.isStop = true
		
	return o
end

function SkillPart:Init(skill)
	
	self.skill = skill
	self.unit = skill.unit
	self.unitRenderer = self.unit.unitRenderer
	self.body = self.unitRenderer.body
end

function SkillPart:Start()
	
	self.isStop = false	
	self.castData = self.skill.castData	
	self.timeHandlesIndex = 1
	self.startTime = _time.tick

	self.isPlayOverOver = false

	self.isMoveOverOver	= nil
	self.isNearUnitOver = nil
	self.moveTo = nil
	self.moveSpeed = nil
	self.oldPos	= nil
	
	self.canControlMove = false
	
	self.touchDamage = nil
	self.excludeTable = {}
	
	self.effects = {}
end

function SkillPart:IsOver()
	return self.isStop
end

function SkillPart:OnOver()

	if self.isStop then
		return
	end

	if self.moveAction then
		self.body:StopAction(self.moveAction)
		self.moveAction = nil
	end
	self.unit:ResumeSpeed()
	self.body:ResumeMoveLayer()
	for key, _ in pairs(self.effects) do
		self.body:RemoveChild(key)
	end
	self.effects = {}
	self.isStop = true

	--todo
	--_runtime.camera:Resume()
	--todo try
	if self.isChangeCameraFollow then
		_runtime.camera:FollowObject(self.body)
	end
end

function SkillPart:DoEvent(e)
	
	if self.isStop then
		return
	end
end

function SkillPart:Damage(info, isDamageOnce)
	
	local damageInfo = {}
	local pos = self.unit:GetPos()
	local dir = self.unit:GetDir()
	
	if info.offsetDis then
		pos = cc.pAdd(pos, cc.pMul(dir, info.offsetDis))
	elseif info.offset then
		--todo
		--rotation
	end	
	
	damageInfo.attacker			= self.unit
	damageInfo.damageDir		= info.damageDir or 1
	damageInfo.dieStyle			= info.dieStyle or 1
	damageInfo.debuff			= info.debuff
	damageInfo.debuffTime		= info.debuffTime
	
	damageInfo.damageValMul		= info.damageValMul or 1
	damageInfo.skillVals		= self.skill.skillVals
	
	if info.isHitBack then
		damageInfo.isHitBack		= true
		damageInfo.hitBackType		= info.hitBackType
		damageInfo.hitDirType 		= info.hitDirType or HitDirType.pos
		damageInfo.hitBackLvl		= info.hitBackLvl
		damageInfo.attackPos		= pos
		
		if info.hitBackType == HitBackType.drag and info.hitDirType == HitDirType.dir then
			damageInfo.dis = cc.pGetDistance(self.moveTo, pos)
			damageInfo.moveSpeed = self.moveSpeed
		end
	end
		
	local t = {}
	t.damageInfo = damageInfo
	t.camp = self.unit.camp
	local excludeTable
	if isDamageOnce then
		excludeTable = self.excludeTable
	end
	
	local damageCount
	if info.rangeType == "circle" then
		damageCount = _fightRuntime:CircleDamage(t, pos, info.radius, excludeTable)
	elseif info.rangeType == "arc" then
		damageCount = _fightRuntime:ArcDamage(t, pos, dir, info.radius, excludeTable)
	elseif info.rangeType == "rect" then
		damageCount = _fightRuntime:RectDamage(t, pos, dir, info.damageWidth, info.damageHeight, excludeTable)
	elseif info.rangeType == "moveRect" then
		if not self.oldPos then
			self.oldPos = pos
		end
		local damageHeight = cc.pGetDistance(self.oldPos, pos) + info.damageHeight
		damageCount = _fightRuntime:RectDamage(t, pos, dir, info.damageWidth, damageHeight, excludeTable)		
		self.oldPos = pos
	end
	
	if damageCount ~= 0 and self.unit.OnCreateDamage then
		self.unit:OnCreateDamage(damageCount)
	end
	
	return damageCount
end	

function SkillPart:Update()
	
	if self.isStop then
		return
	end
	
	if self.isMoveOverOver and (not self.moveAction or self.moveAction:IsOver()) then		
		self:OnOver()
		return
	end
	
	if self.isNearUnitOver then
		local pos = self.targetUnit:GetPos()
		local dis = cc.pGetDistance(self.body:GetPos(), pos)
		if dis <= self.minDis then
			self:OnOver()
			return			
		end
	end
	
	if self.isPlayOverOver and not self.body:IsPlaying() then
		self:OnOver()
		return		
	end
	
	if self.touchDamage then
		local damageCount = self:Damage(self.touchDamageInfo, true)

		if self.touchDamageOver and damageCount ~= 0 then
			self:OnOver()
			return
		end
	end
	
	if self.canControlMove then
		local isMove, moveDir, moveBy = _runtime.stick:GetMoveByOp()
		if isMove then
			self.body:Forward(moveDir)
			local newPos = cc.pAdd(self.body:GetPos(), cc.pMul(moveDir, _time.deltaTime * self.unit:GetSpeed()))
			self.body:SetPos(newPos)
		end
	end
	
	local timeInterval = _time.tick - self.startTime
	while self.timeHandlesIndex <= #self.config and not self.isStop do

		local info = self.config[self.timeHandlesIndex]
		if timeInterval >= info.time then
			self.handler[info.thing](self, info)
			self.timeHandlesIndex = self.timeHandlesIndex + 1
		else
			break
		end
	end
end

Skill = {}
Skill.__index = Skill

function Skill:new(skillName, skillVals)
	
	local o = {}
	setmetatable(o, self)
	
	local config = GetSkillConfig(skillName)
	assert(config)
	o.config = config
	o.partIndex = 1
	o.parts = {}
	
	o.skillVals = skillVals
	
	return o
end

function Skill:Init(unit)

	self.unit = unit
	self.body = unit.body

	for i = 1, #self.config do
		local skillPart = SkillPart:new(self.config[i])
		skillPart:Init(self)
		table.insert(self.parts, skillPart)
	end
end

function Skill:Start(castData)

	self.isStop = false
	self.partIndex = 1
	self.castData = castData
	self.canCastAnother	= false
	self.effects = {}

	if #self.parts ~= 0 then	
		self.parts[1]:Start()
	else
		self.isStop = true
	end
end

function Skill:Stop()
	
	if self.isStop then
		return
	end
	
	if self.parts[self.partIndex] then
		self.parts[self.partIndex]:OnOver()
	end
	
	--todo
	--_runtime.camera:Resume()
	self:OnOver()
end

function Skill:OnOver()
	
	for key, _ in pairs(self.effects) do
		self.body:RemoveChild(key)
	end
	self.effects = {}
	self.isStop = true
end

function Skill:IsOver()
	return self.isStop
end

function Skill:Update()
	
	if self.isStop then
		return
	end

	if self.parts[self.partIndex]:IsOver() then
		
		self.partIndex = self.partIndex + 1
		
		if self.partIndex > #self.parts then
			self:OnOver()
			return
		else	
			self.parts[self.partIndex]:Start()
		end	
	end
	
	self.parts[self.partIndex]:Update()
end

function Skill:DoEvent(e)
	if self.parts[self.partIndex] then
		self.parts[self.partIndex]:DoEvent(e)
	end
end

function Skill:GetDis()
	return self.config.dis or 1.2
end

function Skill:CanCastAnother()
	return self.canCastAnother
end
