local functional         = require "std.functional"
local string             = require "std.string"
local table              = require "std.table"
local list               = require "std.list"
local Object		     = require "Roem.Object"
local Suite			     = require "Roem.Suite"
local Spec			     = require "Roem.Spec"
local Expectation	     = require "Roem.Expectation"
local Matchers			 = require "Roem.Matchers"
local MatchersUtil	     = require "Roem.Matchers.Util"
local Spy				 = require "Roem.Spy"
local SpyRegistry	     = require "Roem.Spy.Registry"
local Any				 = require "Roem.Any"
local ObjectContaining   = require "Roem.ObjectContaining"
local QueueRunner	     = require "Roem.QueueRunner"
local ReportDispatcher   = require "Roem.ReportDispatcher"
local ExceptionFormatter = require "Roem.ExceptionFormatter"
local ExpectationResult  = require "Roem.ExpectationResult"

local prototype = Object{}

function prototype:initialize()
	self.runnableResources = {}
	
	self.currentSpec = nil
	self.currentlyExecutingSuites = {}
	self.currentDeclarationSuite = nil
	
	self.totalSpecsDefined = 0
	
	local currentSpies = function()
		local currentRunnable = self:currentRunnable()
		if currentRunnable == nil then
			error("Spies must be created in a before function or a spec")
		end
		return self.runnableResources[currentRunnable].spies
	end
	self.spyRegistry = SpyRegistry:new({ currentSpies = currentSpies })
	
	local reportEvents = 
	{
		"started", 
		"done", 
		"suiteStarted", 
		"suiteDone", 
		"specStarted", 
		"specDone", 
	}
	self.reporter = ReportDispatcher:new(reportEvents)
	
	local params = 
	{
		description = "--TopLevelSuite--", 
		queueRunner = self:bind("queueRunnerFactory"), 
		onStart = function(suite)
			self.reporter:suiteStarted(suite)
		end, 
		resultCallback = function(attrs)
			self.reporter:suiteDone(attrs)
		end, 
	}
	self.topSuite = Suite:new(params)
	self.currentDeclarationSuite = self.topSuite
	
	Expectation:addCoreMatchers(Matchers:getCoreMatchers())
	
	local commands = 
	{
		"describe",				"it", 
		"beforeAll",			"afterAll", 
		"beforeEach",			"afterEach", 
		"expect", 
		"createSpy",            "createSpyObject",      "spyOn", 
		"any",                  "objectContaining", 
		"pending",				"fail", 
	}
	self.fenv = list.depair(list.map(function(command)
		return { command, self:bind(command), }
	end, commands))
end

function prototype:getfenv()
	return self.fenv
end

function prototype:addReporter(reporter)
	self.reporter:add(reporter)
end

function prototype:execute()
	local runnablesToRun = { self.topSuite }
	
	local allFns = list.map(function(runnable)
		return self:method(runnable, "execute")
	end, runnablesToRun)
	
	self.reporter:started({ totalSpecsDefined = self.totalSpecsDefined })
	
	local params = 
	{
		queueableFns = allFns, 
		onComplete = self:method(self.reporter, "done"), 
	}
	self:queueRunnerFactory(params)
end

--------------------------------------------------------------------------------
-- private

function prototype:bind(method, ...)
	local argt = { ... }
	table.insert(argt, 1, self)
	return functional.bind(self[method], argt)
end

function prototype:method(object, method, ...)
	local argt = { ... }
	table.insert(argt, 1, object)
	return functional.bind(object[method], argt)
end

function prototype:currentSuite()
	return self.currentlyExecutingSuites[#self.currentlyExecutingSuites]
end

function prototype:currentRunnable()
	return self.currentSpec or self:currentSuite()
end

function prototype:expectationFactory(spec, actual)
	local params = 
	{
		util = MatchersUtil:new(), 
		actual = actual, 
		addExpectationResult = self:method(spec, "addExpectationResult"), 
	}
	return Expectation:Factory(params)
end

function prototype:expectationResultFactory(attrs)
	attrs.messageFormatter = self:method(ExceptionFormatter, "message")
	attrs.stackFormatter = self:method(ExceptionFormatter, "stack")
	return ExpectationResult:buildExpectationResult(attrs)
end

function prototype:defaultResourcesForRunnable(runnable)
	self.runnableResources[runnable] = { spies = {} }
end

function prototype:clearResourcesForRunnable(runnable)
	self.spyRegistry:clearSpies()
	self.runnableResources[runnable] = nil
end

function prototype:beforeAndAfterFns(suite)
	return function()
		local befores, afters, beforeAlls, afterAlls = {}, {}, {}, {}
		
		while suite ~= nil do
			befores = list.concat(befores, suite.beforeFns)
			afters = list.concat(afters, suite.afterFns)
			suite = suite.parentSuite
		end
		
		befores = list.reverse(befores)
		beforeAlls = list.reverse(beforeAlls)
		
		local result = 
		{
			befores = list.concat(beforeAlls, befores), 
			afters = list.concat(afters, afteralls), 
		}
		return result
	end
end

function prototype:getSpecName(suite, spec)
	return suite:getFullName() .. " " .. spec.description
end

function prototype:clearStack(fn)
	fn()
end

function prototype:queueRunnerFactory(options)
	options.clearStack = options.clearStack or self:bind("clearStack")
	options.fail = self.fail
	QueueRunner:new(options):execute()
end

function prototype:suiteFactory(description)
	local suite
	
	local suiteStarted = function(suite)
		table.insert(self.currentlyExecutingSuites, suite)
		self:defaultResourcesForRunnable(suite)
		self.reporter:suiteStarted(suite.result)
	end
	
	local resultCallback = function(attrs)
		self:clearResourcesForRunnable(suite)
		table.remove(self.currentlyExecutingSuites)
		self.reporter:suiteDone(attrs)
	end
	
	local params = 
	{
		description = description, 
		parentSuite = self.currentDeclarationSuite, 
		queueRunner = self:bind("queueRunnerFactory"), 
		onStart = suiteStarted, 
		expectationFactory = self:bind("expectationFactory"), 
		expectationResultFactory = self:bind("expectationResultFactory"), 
		resultCallback = resultCallback, 
	}
	suite = Suite:new(params)
	return suite
end

function prototype:describe(description, specDefinitions)
	local suite = self:suiteFactory(description)
	self:addSpecsToSuite(suite, specDefinitions)
	return suite
end

function prototype:addSpecsToSuite(suite, specDefinitions)
	local parentSuite = self.currentDeclarationSuite
	parentSuite:addChild(suite)
	self.currentDeclarationSuite = suite
	
	local succ, err = pcall(specDefinitions, suite)
	if not succ then
		self:it("encountered a declaration exception", function()
			error(err)
		end)
	end
	
	self.currentDeclarationSuite = parentSuite
end

function prototype:specFactory(description, fn, suite, timeout)
	local spec = nil
	
	self.totalSpecsDefined = self.totalSpecsDefined + 1
	
	local specStarted = function(spec)
		self.currentSpec = spec
		self:defaultResourcesForRunnable(spec)
		self.reporter:specStarted(spec.result)
	end
	
	local specResultCallback = function(result)
		self:clearResourcesForRunnable(spec)
		self.currentSpec = nil
		self.reporter:specDone(result)
	end
	
	local params = 
	{
		beforeAndAfterFns = self:beforeAndAfterFns(suite), 
		expectationFactory = self:bind("expectationFactory"), 
		resultCallback = specResultCallback, 
		getSpecName = self:bind("getSpecName", suite), 
		onStart = specStarted, 
		description = description, 
		expectationResultFactory = self:bind("expectationResultFactory"), 
		queueRunnerFactory = self:bind("queueRunnerFactory"), 
		userContext = self:method(suite, "clonedSharedUserContext"),
		queueableFn = fn, 
	}
	spec = Spec:new(params)
	return spec
end

function prototype:it(description, fn)
	local spec = self:specFactory(description, fn, self.currentDeclarationSuite)
	self.currentDeclarationSuite:addChild(spec)
	return spec
end

function prototype:beforeAll(beforeAllFunction)
	self.currentDeclarationSuite:beforeAll(beforeAllFunction)
end

function prototype:afterAll(afterAllFunction)
	self.currentDeclarationSuite:afterAll(afterAllFunction)
end

function prototype:beforeEach(beforeEachFunction)
	self.currentDeclarationSuite:beforeEach(beforeEachFunction)
end

function prototype:afterEach(afterEachFunction)
	self.currentDeclarationSuite:afterEach(afterEachFunction)
end

function prototype:expect(actual)
	local currentRunnable = self:currentRunnable()
	if currentRunnable == nil then
		error("'expect' was used when there was no current spec")
	end
	return currentRunnable:expect(actual)
end

function prototype:createSpy(name)
	return Spy:create(name)
end

function prototype:createSpyObject(name, ...)
	if not (select("#", ...) > 0) then
		error("createSpyObject requires a list of method names to create spies for")
	end
	
	local object = {}
	for _, name in ipairs({ ... }) do
		object[name] = Spy:create(object, name)
	end
	return object
end

function prototype:spyOn(...)
	return self.spyRegistry:spyOn(...)
end

function prototype:any(...)
	return Any:new(...)
end

function prototype:objectContaining(...)
	return ObjectContaining:new(...)
end

function prototype:pending()
	error(Spec.pendingSpecExceptionMessage)
end

function prototype:fail(err)
	local message = "Failed"
	if err ~= nil then
		message = message .. ": " .. err
	end
	local params = 
	{
		matcherName = "", 
		passed = false, 
		expected = "", 
		actual = "", 
		message = message, 
	}
	self:currentRunnable():addExpectationResult(false, params)
end

return prototype
