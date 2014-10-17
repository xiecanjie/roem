local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(data)
	self.queueableFns = data.queueableFns or {}
	self.onComplete = data.onComplete or function()
	end
	self.clearStack = data.clearStack or function(fn)
		fn()
	end
	self.onException = data.onException or function()
	end
	self.userContext = data.userContext or {}
	self.fail = data.fail or function()
	end
end

function prototype:execute()
	self:run(self.queueableFns, 0)
end

--------------------------------------------------------------------------------
-- private

function prototype:run(queueableFns, recursiveIndex)
	local handleException = function(exception)
		self.onException(exception)
	end
	
	for _, fn in ipairs(queueableFns) do
		-- ???: userContext?
		local succ, exception = xpcall(fn, function(err)
			return self:createException(err)
		end)
		if not succ then
			handleException(exception)
		end
	end
	
	self.clearStack(self.onComplete)
end

function prototype:createException(err)
	local exception = {}
	
	local info = debug.getinfo(4)
	exception.fileName = info.short_src
	exception.line     = info.currentline
	exception.stack    = string.sub(debug.traceback("", 3), 2)
	
	if type(err) == "table" then
		exception.name     = err.name
		exception.message  = err.message
	end
	
	if type(err) == "string" then
		exception.message  = err
		local fileName, line, message = string.match(err, "^(.-):(%d+): (.*)")
		if fileName ~= nil then
			exception.message  = message
			exception.fileName = fileName
			exception.line     = line
		end
	end
	
	return exception
end

return prototype
