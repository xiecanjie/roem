local QueueRunner = require "Roem.QueueRunner"

describe("QueueRunner", function()
	it("runs all the functions it's passed", function()
		local calls = {}
		local queueableFn1 = createSpy("fn1")
		local queueableFn2 = createSpy("fn2")
		local queueRunner = QueueRunner:new
		{
			queueableFns = { queueableFn1, queueableFn2, }
		}
		queueableFn1.will:callFake(function()
			table.insert(calls, "fn1")
		end)
		queueableFn2.will:callFake(function()
			table.insert(calls, "fn2")
		end)
		
		queueRunner:execute()
		
		expect(calls):toEqual({ "fn1", "fn2", })
	end)
	
	it("calls exception handlers when an exception is thrown in a fn", function()
		local queueableFn = function()
			error("fake error")
		end
		local onExceptionCallback = createSpy("on exception callback")
		local queueRunner = QueueRunner:new
		{
			queueableFns = { queueableFn }, 
			onException	= onExceptionCallback, 
		}
		
		queueRunner:execute()
		
		local exceptionType = { "message", "fileName", "line", "stack", }
		expect(onExceptionCallback):toHaveBeenCalledWith(any(exceptionType))
	end)
	
	it("calls a provided complete callback when done", function()
		local queueableFn = createSpy("fn")
		local completeCallback = createSpy("completeCallback")
		local queueRunner = QueueRunner:new
		{
			queueableFns = { queueableFn }, 
			onComplete = completeCallback, 
		}
		
		queueRunner:execute()
		
		expect(completeCallback):toHaveBeenCalled()
	end)
	
	it("calls a provided stack clearing function when done", function()
		local queueableFn = function(done)
			done()
		end
		local afterFn = createSpy("afterFn")
		local completeCallback = createSpy("completeCallback")
		local clearStack = createSpy("clearStack")
		local queueRunner = QueueRunner:new
		{
			queueableFns = { queueableFn, afterFn, }, 
			clearStack = clearStack, 
			onComplete = completeCallback, 
		}
		
		clearStack.will:callFake(function(fn)
			fn()
		end)
		
		queueRunner:execute()
		
		expect(afterFn):toHaveBeenCalled()
		expect(clearStack):toHaveBeenCalledWith(completeCallback)
	end)
end)
