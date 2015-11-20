
BattleSkillBtn = {}
BattleSkillBtn.__index = BattleSkillBtn

function BattleSkillBtn:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function BattleSkillBtn:Init(obj, name)
	
	self.object = _platform.FindChild(obj, name)
	assert(self.object)
	
	self.cdObj = _platform.FindChild(self.object, "cd")
	self.textObj = _platform.FindChild(self.object, "cd_Text")
	self.mask = self.cdObj:GetComponent("Image")
	self.cdText = self.textObj:GetComponent("Text")
		
	self.mask.fillAmount = 0
	self.cdText.text = ""
end

function BattleSkillBtn:SetCD(time)
	
	self.totalTime = time
	self.timer = STimer:new()
	self.timer:SetTimeOutTick(time)
	self.timer:Reset()
	
	self.isCD = true
end

function BattleSkillBtn:IsCD()
	return self.isCD
end

function BattleSkillBtn:Update()

	if self.isCD then
		if self.timer:IsTimeOut() then
			self.mask.fillAmount = 0
			self.cdText.text = ""
			self.isCD = false
		else
			local leftTime = self.timer:LeftTime()
			self.mask.fillAmount = leftTime / self.totalTime
			self.cdText.text = string.format("%.1f", leftTime / 1000)
		end	
	end
end
