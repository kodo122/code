
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
	self.stickTouchData = 0
	self.isTouching = false
	
	self.eventTimer = STimer:new()
	self.eventTimer:SetTimeOutTick(100)	

	self.stickUI = _runtime.ui:GetObject()
	self.stickCenter = _platform.FindChild(self.stickUI, "Touch")
	self.stickFrame =  _platform.FindChild(self.stickUI, "Area")
	
	self.centerTransform = self.stickCenter.transform
	self.frameTransform = self.stickFrame.transform

	self:SetActive(false)
	
	return true
end

function Stick:Update()

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
		local touchData = luaTouches[self.stickInfo.fingerId]
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

function Stick:SetActive(b)
	self.stickCenter:SetActive(b)
	self.stickFrame:SetActive(b)
end

function Stick:OnStickBegan(fingerId, pos)
	
	self.isStartStick = true
	self:SetActive(true)

	local stickInfo = {}
	stickInfo.fingerId = fingerId
	stickInfo.framePos = pos
	stickInfo.centerPos = pos
	
	self.stickInfo = stickInfo
		
	self.centerTransform.position = _uguiCamera:ScreenToWorldPoint(Vector3(pos.x, pos.y, 3))
	self.frameTransform.position = _uguiCamera:ScreenToWorldPoint(Vector3(pos.x, pos.y, 3))
end

function Stick:OnStickMove(pos)
	
	local touchData = self.stickInfo
	assert(touchData)
		
	touchData.centerPos = pos		
	local pos3 = cc.pNormalize(cc.pSub(pos, touchData.framePos))		
	
	if cc.pGetDistance(touchData.framePos, pos) > 70 then
	
		local pos4 = cc.pMul(pos3, 70)
		local pos5 = cc.pSub(pos, pos4)
		
		touchData.framePos = pos5
		self.frameTransform.position = _uguiCamera:ScreenToWorldPoint(Vector3(pos5.x, pos5.y, 3))
	end
		
	if cc.pGetDistance(touchData.framePos, pos) > 35 then 
		
		local pos4 = cc.pMul(pos3, 35)
		local pos5 = cc.pAdd(touchData.framePos, pos4)
		
		touchData.centerPos = pos5
	else
		touchData.centerPos = pos
	end
	self.centerTransform.position = _uguiCamera:ScreenToWorldPoint(Vector3(touchData.centerPos.x, touchData.centerPos.y, 3))
end

function Stick:OnStickEnd()
	self.isStartStick = false
	self.stickInfo = nil
	self:SetActive(false)
end

function Stick:Stop()
	self.isStartStick = false
	self.stickInfo = nil
	self:SetActive(false)
	self.isStop = true
end

function Stick:Start()
	
end

function Stick:GetMoveByOp()
	
	if not self.isStartStick then
		return false
	end
	
	local dis = cc.pGetDistance(self.stickInfo.centerPos, self.stickInfo.framePos)
	if dis < 10 then
		return false
	end

	local vec = cc.pNormalize(cc.pSub(self.stickInfo.centerPos, self.stickInfo.framePos))
	
	return true, vec
end

--[[
function Stick:IsClickScene(pos)
	local ray = _uguiCamera:ScreenPointToRay(Vector3(pos.x, pos.y, 0))
	return not Physics.Raycast(ray)
end
]]