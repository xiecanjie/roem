require("std.functional").bind = function(fn, ...)
	local argt = {...}
	if type(argt[1]) == "table" and argt[2] == nil then
		argt = argt[1]
	else
		assert(false)
	end
	return function(...)
		local arg = {}
		for i, v in pairs(argt) do
			arg[i] = v
		end
		local i = 1
		for _, v in ipairs{...} do
			while arg[i] ~= nil do i = i + 1 end
			arg[i] = v
		end
		return fn(unpack(arg))
	end
end

local Object = require "std.object"

local prototype = Object{}

function prototype:new(...)
	local instance = self{}
	instance:initialize(...)
	return instance
end

function prototype:initialize()
end

return prototype
