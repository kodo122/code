
Platform = {}

function Platform.CreateNetHelper(maxIoSize)
	local netHelper = NetHelper:new()
	netHelper:Initialize(maxIoSize)
	return netHelper
end
