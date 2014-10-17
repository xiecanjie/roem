local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(events)
	self.reporters = {}
	
	for _, event in ipairs(events or {}) do
		self[event] = function(self, ...)
			self:dispatch(event, ...)
		end
	end
end

function prototype:add(reporter)
	table.insert(self.reporters, reporter)
end

function prototype:dispatch(event, ...)
	for _, reporter in ipairs(self.reporters) do
		local func = reporter[event]
		if func ~= nil then
			func(reporter, ...)
		end
	end
end

return prototype
