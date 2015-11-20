
EventType = 
{
	button_click = 1,
}

UI = {}
UI.__index = UI

function UI:new()
	
	local o = {}
	setmetatable(o, self)

	o.eventHandles = {}
	o.eventIndex = 1

	return o
end

function UI:Init(name, obj)

	self.name = name
	self.object = _resourceManager:CreateUI(name)
	assert(self.object)
	
	obj = obj or _uguiRoot
	_platform.AddToChild(self.object, _uguiRoot, false)

	self.uiEventPool = UGUIEventPool.Instance()
	self.uiEventPool:Init(self.object)
end

function UI:AddToChild(obj)
	_platform.AddToChild(self.object, obj, false)	
end

function UI:NGUIInit(name)

	self.object = _resourceManager:CreateNGUI(name)
	
	self.uiEventPool = NGUIEventPool.Instance()
	self.uiEventPool:Init(self.object)		
end

function UI:Release()
	
	GameObject.Destroy(self.object)
end

function UI:RegisterEvent(controlName, eventType, func, data)
	
	self.eventHandles[self.eventIndex] = {func = func, data = data}
	self.uiEventPool:Register(controlName, eventType, self.eventIndex)

	local index = self.eventIndex
	self.eventIndex = self.eventIndex + 1
	
	return index
end

function UI:RegEventByObj(o, eventType, func, data)
	
	self.eventHandles[self.eventIndex] = {func = func, data = data}
	self.uiEventPool:RegisterByObj(o, eventType, self.eventIndex)

	local index = self.eventIndex
	self.eventIndex = self.eventIndex + 1
	
	return index
end

function UI:Update()
	
	while true do

		local uiEvent = self.uiEventPool:Pop()
		
		if not uiEvent then
			break
		end
		
		local index = uiEvent.data
		local eventHandle = self.eventHandles[index]
		
		eventHandle.func(eventHandle.data)
	end
end

function UI:Play(name)
	
	if not self.animator then
		self.animator = self.object:GetComponent("Animator")
	end
	
	self.animator:Play(name)
	--self.animator:
end

function UI:GetChild()
	
end

