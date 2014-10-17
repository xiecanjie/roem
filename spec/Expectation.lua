local Expectation = require "Roem.Expectation"

describe("Expectation", function()
	it(".addCoreMatchers makes matchers available to any expectation", function()
		local coreMatchers = {}
		coreMatchers.toQuux = function()
		end
		Expectation:addCoreMatchers(coreMatchers)
		
		local expectation = Expectation:new()
		expect(expectation.toQuux):toBeDefined()
	end)
	
	it("wraps matchers's compare functions, passing in matcher dependencies", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = true })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = {}
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util,
			actual = "an actual",
			addExpectationResult = addExpectationResult, 
		}
		
		expectation:toFoo("hello")
		
		expect(matcherFactory):toHaveBeenCalledWith(util)
	end)
	
	it("wraps matchers's compare functions, passing the actual and expected", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = true })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = { buildFailureMessage = createSpy("buildFailureMessage") }
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util, 
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
		}
		
		expectation:toFoo("hello")
		
		expect(matcher.compare):toHaveBeenCalledWith("an actual", "hello")
	end)
	
	it("reports a passing result to the spec when the comparison passes", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = true })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = { buildFailureMessage = createSpy("buildFailureMessage") }
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util, 
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = true, 
			message = "", 
			expected = "hello", 
			actual = "an actual", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(true, result)
	end)
	
	it("reports a failing result to the spec when the comparison fails", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = false })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = { buildFailureMessage = createSpy("buildFailureMessage").will:returnValue("") }
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util, 
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = false, 
			message = "", 
			expected = "hello", 
			actual = "an actual", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(false, result)
	end)
	
	it("reports a failing result and a custom fail message to the spec when the comparison fails", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = false, message = "I am a custom message", })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = false, 
			expected = "hello", 
			actual = "an actual", 
			message = "I am a custom message", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(false, result)
	end)
	
	it("reports a passing result to the spec when the comparison fails for a negative expectation", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = false })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = { buildFailureMessage = createSpy("buildFailureMessage").will:returnValue("") }
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util, 
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
			isNot = true, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = true, 
			message = "", 
			expected = "hello", 
			actual = "an actual", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(true, result)
	end)
	
	it("reports a failing result to the spec when the comparison passes for a negative expectation", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = true })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local util = { buildFailureMessage = createSpy("buildFailureMessage").will:returnValue("default message") }
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			util = util, 
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
			isNot = true, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = false, 
			expected = "hello", 
			actual = "an actual", 
			message = "default message", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(false, result)
	end)
	
	it("reports a failing result and a custom fail message to the spec when the comparison passes for a negative expectation", function()
		local matcher = createSpyObject("matcher", "compare")
		matcher.compare.will:returnValue({ pass = true, message = "I am a custom message", })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
			isNot = true, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = false, 
			expected = "hello", 
			actual = "an actual", 
			message = "I am a custom message", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(false, result)
	end)
	
	it("reports a passing result to the spec when the 'not' comparison passes, given a negativeCompare", function()
		local matcher = createSpyObject("matcher", "compare", "negativeCompare")
		matcher.compare.will:returnValue({ pass = true })
		matcher.negativeCompare.will:returnValue({ pass = true })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
			isNot = true, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = true, 
			expected = "hello", 
			actual = "an actual", 
			message = "", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(true, result)
	end)
	
	it("reports a failing result and a custom fail message to the spec when the 'not' comparison fails, given a negativeCompare", function()
		local matcher = createSpyObject("matcher", "compare", "negativeCompare")
		matcher.compare.will:returnValue({ pass = true })
		matcher.negativeCompare.will:returnValue({ pass = false, message = "I'm a custom message", })
		local matcherFactory = createSpy("matcherFactory").will:returnValue(matcher)
		Expectation:addCoreMatchers({ toFoo = matcherFactory })
		
		local addExpectationResult = createSpy("addExpectationResult")
		local expectation = Expectation:new
		{
			actual = "an actual", 
			addExpectationResult = addExpectationResult, 
			isNot = true, 
		}
		
		expectation:toFoo("hello")
		
		local result = 
		{
			matcherName = "toFoo", 
			passed = false, 
			expected = "hello", 
			actual = "an actual", 
			message = "I'm a custom message", 
		}
		expect(addExpectationResult):toHaveBeenCalledWith(false, result)
	end)
end)
