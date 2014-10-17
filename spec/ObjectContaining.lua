describe("ObjectContaining", function()
	it("matches any actual to an empty object", function()
		local containing = objectContaining({})
		expect(containing:matches("foo")):toBe(true)
	end)
	
	it("does not match an empty object actual", function()
		local containing = objectContaining("foo")
		expect(function()
			containing:matches({})
		end):toThrow("You must provide an object to objectContaining, not 'foo'.")
	end)
	
	it("matches when the key/value pair is present in the actual", function()
		local containing = objectContaining({ foo = "fooVal" })
		local other = { foo = "fooVal", bar = "barVal", }
		expect(containing:matches(other)):toBe(true)
	end)
	
	it("does not match when the key/value pair is not present in the actual", function()
		local containing = objectContaining({ foo = "fooVal" })
		local other = { bar = "barVal", quux = "quuxVal", }
		expect(containing:matches(other)):toBe(false)
	end)
	
	it("does not match when the key is present but the value is different in the actual", function()
		local containing = objectContaining({ foo = "other" })
		expect(containing:matches({ foo = "fooVal", bar = "barVal", })):toBe(false)
	end)
	
	it("mismatchValues parameter must return array with mismatched reason", function()
		local containing = objectContaining({ foo = "other" })
		
		local mismatchKeys = {}
		local mismatchValues = {}
		
		containing:matches({ foo = "fooVal", bar = "barVal", }, mismatchKeys, mismatchValues)
		
		expect(#mismatchValues):toBe(1)
		expect(mismatchValues[1]):toEqual("'foo' was 'fooVal' in actual, but was 'other' in expected.")
	end)
	
	it("adds keys in expected but not actual to the mismatchKeys parameter", function()
		local containing = objectContaining({ foo = "fooVal" })
		
		local mismatchKeys = {}
		local mismatchValues = {}
		
		containing:matches({ bar = "barVal" }, mismatchKeys, mismatchValues)
		
		expect(#mismatchKeys):toBe(1)
		expect(mismatchKeys[1]):toEqual("expected has key 'foo', but missing from actual.")
	end)
	
	it("matches recursively", function()
		local containing = objectContaining({ one = objectContaining({ two = {} }) })
		expect(containing:matches({ one = { two = {} } })):toBe(true)
	end)
end)
