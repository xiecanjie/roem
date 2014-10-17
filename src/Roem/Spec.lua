local Object = require "Roem.Object"

local prototype = Object{}

prototype.pendingSpecExceptionMessage = "=> marked Pending"

function prototype:isPendingSpecException(exception)
	local message = exception.message
	return (string.find(message, prototype.pendingSpecExceptionMessage) ~= nil)
end

function prototype:initialize(data)
	local nop = function()
	end
	
	self.expectationFactory = data.expectationFactory
	self.resultCallback = data.resultCallback or nop
	self.description = data.description or ""
	self.queueableFn = data.queueableFn
	self.beforeAndAfterFns = data.beforeAndAfterFns or function()
		return { befores = {}, afters = {}, }
	end
	self.userContext = data.userContext or function()
		return {}
	end
	self.onStart = data.onStart or nop
	self.getSpecName = data.getSpecName or function()
		return ""
	end
	self.expectationResultFactory = data.expectationResultFactory or function()
		return {}
	end
	self.queueRunnerFactory = data.queueRunnerFactory or nop
	self.catchingExceptions = data.catchingExceptions or function()
		return true
	end
	
	if self.queueableFn == nil then
		self:pend()
	end
	
	self.result = 
	{
		description = self.description, 
		fullName = self:getFullName(), 
		failedExpectations = {}, 
		passedExpectations = {}, 
	}
end

function prototype:addExpectationResult(passed, data)
	local expectationResult = self.expectationResultFactory(data)
	if passed then
		table.insert(self.result.passedExpectations, expectationResult)
	else
		table.insert(self.result.failedExpectations, expectationResult)
	end
end

function prototype:expect(actual)
	return self.expectationFactory(self, actual)
end

function prototype:execute(onComplete)
	local complete = function()
		self.result.status = self:status()
		self.resultCallback(self.result)
		if onComplete then
			onComplete()
		end
	end
	
	self.onStart(self)
	
	if self.markedPending then
		complete()
		return
	end
	
	local fns = self.beforeAndAfterFns()
	local allFns = list.concat(fns.befores, { self.queueableFn }, fns.afters)
	local params = 
	{
		queueableFns = allFns, 
		onException = bind(self.onException, self), 
		onComplete = complete, 
		userContext = self.userContext(), 
	}
	self.queueRunnerFactory(params)
end

function prototype:onException(e)
	if self:isPendingSpecException(e) then
		self:pend()
		return
	end
	
	local result = 
	{
		matcherName = "", 
		passed = false, 
		expected = "", 
		actual = "", 
		exception = e, 
	}
	self:addExpectationResult(false, result)
end

function prototype:pend()
	self.markedPending = true
end

function prototype:status()
	if self.markedPending then
		return "pending"
	end
	
	if not table.empty(self.result.failedExpectations) then
		return "failed"
	end
	
	return "passed"
end

function prototype:getFullName()
	return self.getSpecName(self)
end

return prototype
