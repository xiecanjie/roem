local ExpectationResult = require "Roem.ExpectationResult"

describe("ExpectationResult", function()
	it("defaults to passed", function()
		local result = ExpectationResult:buildExpectationResult({ passed = "some-value" })
		expect(result.passed):toBe("some-value")
	end)
	
	it("message defaults to Passed for passing specs", function()
		local result = ExpectationResult:buildExpectationResult({ passed = true, message = "some-value", })
		expect(result.message):toBe("Passed.")
	end)
	
	it("message returns the message for failing expectations", function()
		local result = ExpectationResult:buildExpectationResult({ passed = false, message = "some-value", })
		expect(result.message):toBe("some-value")
	end)
	
	it("delegates message formatting to the provided formatter if there was an Error", function()
		local fakeError = { message = "foo" }
		local messageFormatter = createSpy("exception message formatter").will:returnValue(fakeError.message)
		local result = ExpectationResult:buildExpectationResult
		{
			passed = false, 
			exception = fakeError, 
			messageFormatter = messageFormatter, 
		}
		
		expect(messageFormatter):toHaveBeenCalledWith(fakeError)
		expect(result.message):toEqual("foo")
	end)
	
	it("delegates stack formatting to the provided formatter if there was an Error", function()
		local fakeError = { stack = "foo" }
		local stackFormatter = createSpy("stack formatter").will:returnValue(fakeError.stack)
		local result = ExpectationResult:buildExpectationResult
		{
			passed = false, 
			exception = fakeError, 
			stackFormatter = stackFormatter, 
		}
		
		expect(stackFormatter):toHaveBeenCalledWith(fakeError)
		expect(result.stack):toEqual("foo")
	end)
	
	it("matcherName returns passed matcherName", function()
		local result = ExpectationResult:buildExpectationResult({ matcherName = "some-value" })
		expect(result.matcherName):toBe("some-value")
	end)
	
	it("expected returns passed expected", function()
		local result = ExpectationResult:buildExpectationResult({ expected = "some-value" })
		expect(result.expected):toBe("some-value")
	end)
	
	it("actual returns passed actual", function()
		local result = ExpectationResult:buildExpectationResult({ actual = "some-value" })
		expect(result.actual):toBe("some-value")
	end)
end)
