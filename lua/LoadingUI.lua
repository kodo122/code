
LoadingUI = {}
LoadingUI.__index = LoadingUI

function LoadingUI:new()
	
	local o = {}
	setmetatable(o, self)

	return o
end

function LoadingUI:Init()
	
	self.ui = UI:new()
	self.ui:Init("loading_ui")
	self.barObj = _platform.FindChild(self.ui.object, "loading03")
	self.barImage = self.barObj:GetComponent("Image")
	--self.barWidth = self.barRectTransform.rect.width
	--self.barHeight = self.barRectTransform.rect.height	
end

function LoadingUI:Update()
	
	self.ui:Update()
end

function LoadingUI:SetPercent(percent)
	
	self.barImage.fillAmount = percent
	--self.barRectTransform.sizeDelta = Vector2(self.barWidth * percent, self.barHeight)
end

function LoadingUI:GetObject()
	return self.ui.object
end

function LoadingUI:Release()
	
	self.ui:Release()
end