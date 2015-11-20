
STimer = {}
STimer.__index = STimer

function STimer:new()
	
	local o = {}
	setmetatable(o, self)

	self.isFirstTime = true
	self.timeOutTick = 0
	self.tick = 0

	return o
end

function STimer:SetTimeOutTick(tick)
	
	self.timeOutTick = tick
end

function STimer:Reset()
	self.tick = _time.tick
	self.isFirstTime = false
end

function STimer:IsTimeOut()
	
	if self.isFirstTime then
		return true
	end
	return (_time.tick - self.tick) >= self.timeOutTick
end

function STimer:LeftTime()
	return self.timeOutTick - (_time.tick - self.tick)
end


RealTimer = {}
RealTimer.__index = RealTimer

function RealTimer:new()
	
	local o = {}
	setmetatable(o, self)

	self.isFirstTime = true
	self.timeOutTick = 0
	self.tick = 0

	return o
end

function RealTimer:SetTimeOutTick(tick)
	
	self.timeOutTick = tick
end

function RealTimer:Reset()
	self.tick = _time.realTime
	self.isFirstTime = false
end

function RealTimer:IsTimeOut()
	
	if self.isFirstTime then
		return true
	end
	return (_time.realTime - self.tick) >= self.timeOutTick
end

function RealTimer:LeftTime()
	return self.timeOutTick - (_time.realTime - self.tick)
end


