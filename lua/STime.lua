
STime = {}
STime.__index = STime

function STime:new()
	
	local o = {}
	setmetatable(o, self)

	o.frame = 1
	o.isTimeScale = false
	o.timeScaleTimer = RealTimer:new()

	--set time
	o:Update()

	return o
end

function STime:Update()
	
	self.deltaTime = Time.deltaTime
	self.time = Time.time
	self.tick = self.time * 1000
	self.realTime = Time.realtimeSinceStartup
	self.frame = self.frame + 1
	
	if self.isTimeScale then
		if self.timeScaleTimer:IsTimeOut() then
			Time.timeScale = 1
			self.isTimeScale = false
		end
	end
end

function STime:Scale(scale, time)
	if not self.isLock then
		Time.timeScale = scale
		self.isTimeScale = true
		self.timeScaleTimer:SetTimeOutTick(time)
		self.timeScaleTimer:Reset()
	end
end

function STime:Lock(b)
	self.isLock = b
end


IntervalTime = {}
IntervalTime.__index = IntervalTime

function IntervalTime:new(time)
	
	local o = {}
	setmetatable(o, self)

	o.totalTime = time

	return o
end

function IntervalTime:Start()
	self.startTime = _time.time
end

function IntervalTime:GetPercent()
	local per = (_time.time - self.startTime) / self.totalTime
	if per > 1 then
		per = 1
	end
	return per
end

--均加速
AccInIntervalTime = {}
AccInIntervalTime.__index = AccInIntervalTime

function AccInIntervalTime:new(time)
	
	local o = {}
	setmetatable(o, self)

	o.totalTime = time

	return o
end

function AccInIntervalTime:Start()
	self.startTime = _time.time
end

function AccInIntervalTime:GetPercent()
	
	local per = (_time.time - self.startTime) / self.totalTime
	if per > 1 then
		return 1
	end
	per = per * per
	return per
end


AccOutIntervalTime = {}
AccOutIntervalTime.__index = AccOutIntervalTime

function AccOutIntervalTime:new(time)
	
	local o = {}
	setmetatable(o, self)

	o.totalTime = time

	return o
end

function AccOutIntervalTime:Start()
	self.startTime = _time.time
end

function AccOutIntervalTime:GetPercent()

	local useTime = _time.time - self.startTime
	local per = useTime / self.totalTime
	
	if per > 1 then
		return 1
	end
	
	per = 2 * per - (per * per)
	return per
end

--速率加速
RateInIntervalTime = {}
RateInIntervalTime.__index = RateInIntervalTime
function RateInIntervalTime:new(time, rate)
	
	local o = {}
	setmetatable(o, self)

	o.totalTime = time
	o.rate = rate

	return o
end

function RateInIntervalTime:Start()
	self.startTime = _time.time
end

function RateInIntervalTime:GetPercent()

	local useTime = _time.time - self.startTime
	local per = useTime / self.totalTime
	
	if per > 1 then
		return 1
	end
	
	return math.pow(per, self.rate)
end

RateOutIntervalTime = {}
RateOutIntervalTime.__index = RateOutIntervalTime
function RateOutIntervalTime:new(time, rate)
	
	local o = {}
	setmetatable(o, self)

	o.totalTime = time
	o.rate = rate

	return o
end

function RateOutIntervalTime:Start()

	self.startTime = _time.time
end

function RateOutIntervalTime:GetPercent()

	local useTime = _time.time - self.startTime
	local per = useTime / self.totalTime
	
	if per > 1 then
		return 1
	end
	
	return math.pow(per, 1 / self.rate)
end


MixIntervalTime = {}
MixIntervalTime.__index = MixIntervalTime

function MixIntervalTime:new(...)
	
	local o = {}
	setmetatable(o, self)

	o.sections = {...}
	o.sectionIndex = 1

	return o
end

function MixIntervalTime:Start()

	self.totalTime = 0
	for _, val in ipairs(self.sectons) do
		self.totalTime = self.totalTime + val.time
	end
	self.currSecStartTime = _time.time
	self.currStartPer = 0
	self.currSecPer = self.sectons[1].time / self.totalTime	
end

local StyleToPer = 
{
	accIn = function(per, sec)
		return per * per
	end,
	accOut = function(per, sec)
		return 2 * per - (per * per)
	end,
	rateIn = function(per, sec)
		return math.pow(per, sec.rate)
	end,
	rateOut = function(per, sec)
		return math.pow(per, 1 / sec.rate)
	end,
}
function MixIntervalTime:GetPercent()

	local currSection = self.sectons[self.sectionIndex]
	local currSecUseTime = _time.time - self.currSecStartTime
	local currSecPer = currSecUseTime / currSection.time
	
	if currSecPer > 1 then
		currSecPer = 1
	else	
		currSecPer = StyleToPer[currSection.style](currSecPer, currSection)
	end	
	
	local per = currSecPer * self.currSecPer + self.currStartPer
	
	if currSecPer == 1 then
		if self.sectionIndex <= #self.sectons then
			self.sectionIndex = self.sectionIndex + 1
			self.currSecStartTime = _time.time
			self.currStartPer = self.currStartPer + self.currSecPer
			self.currSecPer = self.sectons[self.sectionIndex].time / self.totalTime
		end		
	end

	return per
end


