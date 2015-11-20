
Stick = {}
Stick.__index = Stick

function Stick:new()
	
	local o = {}
	setmetatable(o, self)
	
	o.isStartStick = false
	o.stickInfo = {}
	o.isStop = true
	
	return o
end

function Stick:Init()
	
	self.isStop = false
	self.isStartStick = false
	
	return true
end

function Stick:Refresh()

	if self.isStop then
		return
	end
	local luaTouches = {}

	if _platform.platform == "windows" then
		
		if Input.GetMouseButton(0) then
			
			local fingerId = 1
			local vec3 = Input.mousePosition			
			local pos = cc.p(vec3.x, vec3.y)

			if self:IsPosValid(pos) then
				luaTouches[fingerId] = {position = pos}
			end
		end
	else
		local touches = Input.touches
		local size = touches.Length
	
		for i = 0, size - 1 do
			
			local touch = touches:GetValue(i)
			local fingerId = touch.fingerId
			local vec3 = touch.position	
			local pos = cc.p(vec3.x, vec3.y)
			if self:IsPosValid(pos) then
				luaTouches[fingerId] = {position = pos}
			end
		end	
	end

	if self.isStartStick then
		local touchData = luaTouches[self.fingerId]
		if touchData then
			self:OnStickMove(touchData.position)
		else
			self:OnStickEnd()
		end
	else
		--bug  todo   stick self is ui
		--if not LuaHelper.IsClickUI() then
			for key, val in pairs(luaTouches) do
				self:OnStickBegan(key, val.position)
				break
			end
		--end
	end
end

function Stick:IsPosValid(pos)
	
	if pos.x > _platform.screen.width * 3 / 4 then -- or pos.y > _screen.height * 4 / 5 then
		return false
	end
	return true
end

function Stick:OnStickBegan(fingerId, pos)
	
	self.isStartStick = true
	self.fingerId = fingerId
	self.lastPos = pos
	self.currPos = pos
end

function Stick:OnStickMove(pos)
	self.lastPos = self.currPos
	self.currPos = pos
end

function Stick:OnStickEnd()
	self.isStartStick = false
end

function Stick:Stop()
	self.isStartStick = false
	self.isStop = true
end

function Stick:Start()
	
end

function Stick:GetMoveByOp()
	
	self:Refresh()
	
	if not self.isStartStick then
		return false
	end
	local dis = cc.pGetDistance(self.lastPos, self.currPos)
	if dis < 2 then
		return false
	end

	local vec = cc.pNormalize(cc.pSub(self.currPos, self.lastPos))
	
	return true, vec
end

--[[
function Stick:IsClickScene(pos)
	local ray = _uguiCamera:ScreenPointToRay(Vector3(pos.x, pos.y, 0))
	return not Physics.Raycast(ray)
end
]]