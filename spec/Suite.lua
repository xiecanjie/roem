local Suite = require "Roem.Suite"

describe("Suite", function()
	it("returns its full name", function()
		local suite = Suite:new
		{
			description = "I am a suite", 
		}
		expect(suite:getFullName()):toEqual("I am a suite")
	end)
	
	it("returns its full name when it has parent suites", function()
		local parentSuite = Suite:new
		{
			description = "I am a parent suite", 
			parentSuite = createSpy("pretend top level suite"), 
		}
		local suite = Suite:new
		{
			description = "I am a suite", 
			parentSuite = parentSuite, 
		}
		expect(suite:getFullName()):toEqual("I am a parent suite I am a suite")
	end)
	
	it("adds before functions in order of needed execution", function()
		local suite = Suite:new
		{
			description = "I am a suite", 
		}
		local outerBefore = createSpy("outerBeforeEach")
		local innerBefore = createSpy("insideBeforeEach")
		
		suite:beforeEach(outerBefore)
		suite:beforeEach(innerBefore)
		
		expect(suite.beforeFns):toEqual({ innerBefore, outerBefore, })
	end)
	
	it("runs beforeAll functions in order of needed execution", function()
		local fakeQueueRunner = createSpy("fake queue runner")
		local suite = Suite:new
		{
			description = "I am a suite", 
			queueRunner = fakeQueueRunner, 
		}
		local firstBefore = createSpy("outerBeforeAll")
		local lastBefore = createSpy("insideBeforeAll")
		local fakeIt = { execute = createSpy("it") }
		
		suite:beforeAll(firstBefore)
		suite:beforeAll(lastBefore)
		suite:addChild(fakeIt)
		suite:execute()
		
		local suiteFns = fakeQueueRunner.calls:mostRecent().args[1].queueableFns
		suiteFns[1]()
		expect(firstBefore):toHaveBeenCalled()
		suiteFns[2]()
		expect(lastBefore):toHaveBeenCalled()
	end)
	
	it("adds after functions in order of needed execution", function()
		local suite = Suite:new
		{
			description = "I am a suite", 
		}
		local outerAfter = createSpy("outerAfterEach")
		local innerAfter = createSpy("insideAfterEach")
		
		suite:afterEach(outerAfter)
		suite:afterEach(innerAfter)
		
		expect(suite.afterFns):toEqual({ innerAfter, outerAfter, })
	end)
	
	it("runs afterAll functions in order of needed execution", function()
		local fakeQueueRunner = createSpy("fake queue runner")
		local suite = Suite:new
		{
			description = "I am a suite", 
			queueRunner = fakeQueueRunner, 
		}
		local firstAfter = createSpy("outerAfterAll")
		local lastAfter = createSpy("insideAfterAll")
		local fakeIt = { execute = createSpy("it") }
		
		suite:afterAll(firstAfter)
		suite:afterAll(lastAfter)
		suite:addChild(fakeIt)
		
		suite:execute()
		
		local suiteFns = fakeQueueRunner.calls:mostRecent().args[1].queueableFns
		suiteFns[2]()
		expect(firstAfter):toHaveBeenCalled()
		suiteFns[3]()
		expect(lastAfter):toHaveBeenCalled()
	end)
	
	it("delegates execution of its specs, suites, beforeAlls, and afterAlls", function()
		local parentSuiteDone = createSpy("parent suite done")
		local fakeQueueRunnerForParent = createSpy("fake parent queue runner")
		local parentSuite = Suite:new
		{
			description = "I am a parent suite", 
			queueRunner = fakeQueueRunnerForParent, 
		}
		local fakeQueueRunner = createSpy("fake queue runner")
		local suite = Suite:new
		{
			description = "with a child suite", 
			queueRunner = fakeQueueRunner, 
		}
		local fakeSpec1 = { execute = createSpy("fakeSpec1") }
		local beforeAllFn = createSpy("beforeAll")
		local afterAllFn = createSpy("afterAll")
		
		spyOn(suite, "execute")
		
		parentSuite:addChild(fakeSpec1)
		parentSuite:addChild(suite)
		parentSuite:beforeAll(beforeAllFn)
		parentSuite:afterAll(afterAllFn)
		
		parentSuite:execute(parentSuiteDone)
		
		local parentSuiteFns = fakeQueueRunnerForParent.calls:mostRecent().args[1].queueableFns
		parentSuiteFns[1]()
		expect(beforeAllFn):toHaveBeenCalled()
		parentSuiteFns[2]()
		expect(fakeSpec1.execute):toHaveBeenCalled()
		parentSuiteFns[3]()
		expect(suite.execute):toHaveBeenCalled()
		parentSuiteFns[4]()
		expect(afterAllFn):toHaveBeenCalled()
	end)
	
	it("calls a provided onStart callback when starting", function()
		local suiteStarted = createSpy("suiteStarted")
		local fakeQueueRunner = function(attrs)
			attrs.onComplete()
		end
		local suite = Suite:new
		{
			description = "with a child suite", 
			onStart = suiteStarted, 
			queueRunner = fakeQueueRunner, 
		}
		local fakeSpec1 = { execute = createSpy("fakeSpec1") }
		
		suite:execute()
		
		expect(suiteStarted):toHaveBeenCalledWith(suite)
	end)
	
	it("calls a provided onComplete callback when done", function()
		local suiteCompleted = createSpy("parent suite done")
		local fakeQueueRunner = function(attrs)
			attrs.onComplete()
		end
		local suite = Suite:new
		{
			description = "with a child suite", 
			queueRunner = fakeQueueRunner, 
		}
		local fakeSpec1 = 
		{
			execute = createSpy("fakeSpec1"), 
		}
		
		suite:execute(suiteCompleted)
		
		expect(suiteCompleted):toHaveBeenCalled()
	end)
	
	it("calls a provided result callback when done", function()
		local suiteResultsCallback = createSpy("suite result callback")
		local fakeQueueRunner = function(attrs)
			attrs.onComplete()
		end
		local suite = Suite:new
		{
			description = "with a child suite", 
			queueRunner = fakeQueueRunner, 
			resultCallback = suiteResultsCallback, 
		}
		local fakeSpec1 = 
		{
			execute = createSpy("fakeSpec1"), 
		}
		
		suite:execute()
		
		expect(suiteResultsCallback):toHaveBeenCalledWith
		{
			status = "finished", 
			description = "with a child suite", 
			fullName = "with a child suite", 
			failedExpectations = {}, 
		}
	end)
	
	it("has a status of failed if any afterAll expectations have failed", function()
		local suite = Suite:new
		{
			expectationResultFactory = function()
				return "hi"
			end, 
		}
		suite:addChild({ result = { status = "done" } })
		
		suite:addExpectationResult(false)
		expect(suite:status()):toBe("failed")
	end)
end)
