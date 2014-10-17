local Object = require "Roem.Object"

local prototype = Object{}

function prototype:buildExpectationResult(options)
	return self:new(options)
end

function prototype:initialize(options)
	self.matcherName = options.matcherName
	self.expected	 = options.expected
	self.actual		 = options.actual
	self.message	 = self:formatMessage(options)
	self.stack		 = self:formatStack(options)
	self.passed		 = options.passed
end

function prototype:formatMessage(options)
	if options.passed then
		return "Passed."
	end
	
	if options.message ~= nil then
		return options.message
	end
	
	if options.exception ~= nil then
		if options.messageFormatter ~= nil then
			return options.messageFormatter(options.exception)
		end
		return ""
	end
	
	return ""
end

function prototype:formatStack(options)
	if options.passed then
		return ""
	end
	if options.exception ~= nil then
		if options.stackFormatter ~= nil then
			return options.stackFormatter(options.exception)
		end
		return ""
	end
	return ""
end

return prototype
