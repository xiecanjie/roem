local Spec    = require "Roem.Spec"
local Context = require "Roem.Context"

describe("Context", function()
	local context
	
	beforeEach(function()
		context = Context:new()
	end)
	
	describe("#pending", function()
		it("throws the Pending Spec exception", function()
			expect(function()
				context:pending()
			end):toThrow(Spec.pendingSpecExceptionMessage)
		end)
	end)
	
	describe("#topSuite", function()
		it("returns the Jasmine top suite for users to traverse the spec tree", function()
			local suite = context:topSuite()
			expect(suite.description):toEqual("--TopLevelSuite--")
		end)
	end)
end)
