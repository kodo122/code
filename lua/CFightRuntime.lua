
FightRuntime = {}
FightRuntime.__index = FightRuntime

function FightRuntime:new()
	
	local o = {}
	setmetatable(o, self)

	o.isShoot = false
	--o.isCastSkill = false
	--o.castSkillIndex = nil

	return o
end

function FightRuntime:Init()
	
	self.currMobCount = 0
	function OnMobDie()		
		self.currMobCount = self.currMobCount - 1
	end
	function OnMobCreate()
		self.currMobCount = self.currMobCount + 1
	end
	--RegisterGameEvent("mobDie", OnMobDie)	
	--RegisterGameEvent("mobCreate", OnMobCreate)	
end

function FightRuntime:GetCurrMobCount()
	return self.currMobCount
end

function FightRuntime:ArcJudge(selfPos, enemyPos, dir, radius)
	
	local dir1 = cc.GetDir(selfPos, enemyPos)
	local radian = cc.pGetAngle(dir, dir1)
	
	angle = cc.RadiansToDegrees(radian)
	return math.abs(angle) < 90
end

function FightRuntime:CircleDamage1(t)
	
	local damageCount = 0

	local vec3 = cc.pToVec3(t.pos)
	local layerMask = 0
	if t.camp == Camp.hero then
		layerMask = 4
	else
		layerMask = 2
	end
	
	local beHitUnits = Physics.OverlapSphere(vec3, t.radius, layerMask)
	local size = beHitUnits.Length
	
	for i = 0, size - 1 do

		local collider = beHitUnits:GetValue(i)
		local obj = collider.gameObject
		local unit = _runtime.unitManager:GetUnitByObj(obj)
		
		if not unit:IsDie() and not unit:IsInvincible() then
			if not t.excludeTable or not t.excludeTable[unit] then
				
				local canHit = true
				if t.rangeType == "arc" and 
					not self:ArcJudge(t.pos, unit:GetPos(), t.dir, t.radius) then
					canHit = false
				end
				
				if canHit then
					
					local e = 
					{
						id = Event.damage,
						damageInfo = t.damageInfo,
					}
					unit:PushEvent(e)
					damageCount = damageCount + 1

					if t.excludeTable then
						t.excludeTable[unit] = unit
					end		
				end

			end
		end
	end
	
	return damageCount
end

function FightRuntime:NearstEnemy1(camp, pos, radius)

	local vec3 = cc.pToVec3(pos)
	local layerMask = 0
	if camp == Camp.hero then
		layerMask = 4
	else
		layerMask = 2
	end
	
	local units = Physics.OverlapSphere(vec3, radius, layerMask)
	
	local size = units.Length
	
	local nearstUnit = nil
	local nearstDis = 999
	
	for i = 0, size - 1 do

		local collider = units:GetValue(i)
		local obj = collider.gameObject
		local unit = _runtime.unitManager:GetUnitByObj(obj)

		if not unit:IsDie() and not unit:IsInvincible() then
		
			local dis = cc.pGetDistance(pos, unit:GetPos())
					
			if dis < nearstDis then
				nearstDis = dis
				nearstUnit = unit
			end
		end
	end
	
	return nearstUnit, nearstDis
end


function FightRuntime:CircleDamage(t, pos, radius, excludeTable)

	local damageCount = 0	
	
	for key, unit in pairs(_runtime.unitManager.units) do
		if unit.camp ~= t.camp then
			if not unit:IsDie() and not unit:IsInvincible() then
				if not excludeTable or not excludeTable[unit] then
					local unitPos = unit:GetPos()
					if cc.pGetDistance(pos, unitPos) <= radius then
						
						local e = 
						{
							id = Event.damage,
							damageInfo = t.damageInfo,
						}
						unit:PushEvent(e)
						damageCount = damageCount + 1

						if excludeTable then
							excludeTable[unit] = unit
						end	
					end
				end
			end
		end
	end	
	
	return damageCount
end

function FightRuntime:ArcDamage(t, pos, dir, radius, excludeTable)
	
	local damageCount = 0	
	local fanPos2 = cc.pAdd(pos, cc.pMul(dir, radius))
	local theta = math.rad(t.angle or 90)
	
	for key, unit in pairs(_runtime.unitManager.units) do
		if unit.camp ~= t.camp then
			if not unit:IsDie() and not unit:IsInvincible() then
				if not excludeTable or not excludeTable[unit] then
					local unitPos = unit:GetPos()
					if IsCircleIntersectFan(unitPos.x, unitPos.y, 0.2, pos.x, pos.y, fanPos2.x, fanPos2.y, theta) then
						
						local e = 
						{
							id = Event.damage,
							damageInfo = t.damageInfo,
						}
						unit:PushEvent(e)
						damageCount = damageCount + 1

						if excludeTable then
							excludeTable[unit] = unit
						end	
					end
				end
			end
		end
	end	
	
	return damageCount
end

function FightRuntime:RectDamage(t, pos, dir, width, height, excludeTable)
	
	local damageCount = 0
	local midPos = cc.pAdd(pos, cc.pMul(dir, height / 2))
	local upMidPos = cc.pAdd(pos, cc.pMul(dir, height))
	local tempPos1 = cc.pRotateByAngle(upMidPos, midPos, math.rad(90))
	local rectXDir = cc.GetDir(midPos, tempPos1)
	local rightMidPos = cc.pAdd(midPos, cc.pMul(rectXDir, width / 2))
	
	for key, unit in pairs(_runtime.unitManager.units) do
		if unit.camp ~= t.camp then
			if not unit:IsDie() and not unit:IsInvincible() then
				if not excludeTable or not excludeTable[unit] then
					local unitPos = unit:GetPos()
					
					if IsCircleIntersectRectangle(unitPos.x, unitPos.y, 0.2, midPos.x, midPos.y, upMidPos.x, upMidPos.y, rightMidPos.x, rightMidPos.y) then
						
						local e = 
						{
							id = Event.damage,
							damageInfo = t.damageInfo,
						}
						unit:PushEvent(e)
						damageCount = damageCount + 1

						if excludeTable then
							excludeTable[unit] = unit
						end	
					end
				end
			end
		end
	end	
	
	return damageCount
end

function FightRuntime:NearstEnemy(camp, pos, radius)
	local neastDis = radius + 0.0001
	local neastEmeny

	for key, unit in pairs(_runtime.unitManager.units) do
		if unit.camp ~= camp then
			if not unit:IsDie() and not unit:IsInvincible() then
				local pos1 = unit:GetPos()
				local dis = cc.pGetDistance(pos, pos1)
				
				if dis < neastDis then
					neastDis = dis
					neastEmeny = unit
				end
			end
		end
	end
	
	return neastEmeny, neastDis
end

