local functional = require "std.functional"
local table      = require "std.table"
local list       = require "std.list"
local Object     = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(data)
	local nop = function()
	end
	
	self.parentSuite			  = data.parentSuite
	self.description              = data.description
	self.onStart                  = data.onStart or nop
	self.resultCallback           = data.resultCallback or nop
	self.expectationFactory       = data.expectationFactory
	self.expectationResultFactory = data.expectationResultFactory
	
	self.clearStack = data.clearStack or function(fn)
		fn()
	end
	
	self.beforeFns		= {}
	self.afterFns		= {}
	self.beforeAllFns	= {}
	self.afterAllFns	= {}
	self.queueRunner	= data.queueRunner or nop
	
	self.children = {}
	
	self.result = 
	{
		description = self.description, 
		fullName = self:getFullName(), 
		failedExpectations = {}, 
	}
end

function prototype:expect(actual)
	return self.expectationFactory(self, actual)
end

function prototype:getFullName()
	local fullName = self.description
	local parentSuite = self.parentSuite
	while parentSuite ~= nil do
		if parentSuite.parentSuite ~= nil then
			fullName = parentSuite.description .. " " .. fullName
		end
		parentSuite = parentSuite.parentSuite
	end
	return fullName
end

function prototype:beforeEach(fn)
	table.insert(self.beforeFns, 1, fn)
end

function prototype:beforeAll(fn)
	table.insert(self.beforeAllFns, fn)
end

function prototype:afterEach(fn)
	table.insert(self.afterFns, 1, fn)
end

function prototype:afterAll(fn)
	table.insert(self.afterAllFns, fn)
end

function prototype:addChild(child)
	table.insert(self.children, child)
end

function prototype:status()
	if not table.empty(self.result.failedExpectations) then
		return "failed"
	end
	
	return "finished"
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
	
	local allFns = {}
	allFns = list.concat(allFns, self.beforeAllFns)
	for _, child in ipairs(self.children) do
		table.insert(allFns, functional.bind(child.execute, { child }))
	end
	allFns = list.concat(allFns, self.afterAllFns)
	
	local runnerParams = 
	{
		queueableFns = allFns, 
		onComplete = complete, 
		userContext = self:sharedUserContext(), 
		onException = functional.bind(self.onException, { self })
	}
	self.queueRunner(runnerParams)
end

function prototype:sharedUserContext()
	if self.sharedContext == nil then
		self.sharedContext = {}
		if self.parentSuite then
			self.sharedContext = self.parentSuite:clonedSharedUserContext()
		end
	end
	return self.sharedContext
end

function prototype:clonedSharedUserContext()
	return table.clone(self:sharedUserContext())
end

function prototype:onException(...)
	if self:isAfterAll() then
		local data = 
		{
			matcherName = "", 
			passed = false, 
			expected = "", 
			actual = "", 
			exception = select(1, ...)
		}
		local result = self.expectationResultFactory(data)
		table.insert(self.result.failedExpectations, result)
		return
	end
	
	for _, child in ipairs(self.children) do
		child:onException(...)
	end
end

function prototype:addExpectationResult(...)
	if self:isAfterAll() and self:isFailure(...) then
		local result = self.expectationResultFactory(select(2, ...))
		table.insert(self.result.failedExpectations, result)
		return
	end
	
	for _, child in ipairs(self.children) do
		child:addExpectationResult(...)
	end
end

--------------------------------------------------------------------------------
-- private

function prototype:isAfterAll()
	return (self.children[1].result.status ~= nil)
end

function prototype:isFailure(...)
	return (not select(1, ...))
end

return prototype
