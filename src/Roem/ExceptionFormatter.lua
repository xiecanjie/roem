local Object = require "Roem.Object"

local prototype = Object{}

function prototype:message(exception)
	local message = ""
	
	if exception.name ~= nil then
		message = message .. exception.name .. ": " .. exception.message
	else
		message = message .. exception.message .. " thrown"
	end
	
	if exception.fileName ~= nil then
		message = message .. " in " .. exception.fileName
	end
	
	if exception.line ~= nil then
		message = message .. " (line " .. exception.line .. ")"
	end
	
	return message
end

function prototype:stack(exception)
	local indent = string.rep(" ", 4)
	local lines = string.split(exception.stack, "\n")
	return table.concat(list.map(function(line)
		return string.gsub(line, "^	", indent)
	end, lines), "\n")
end

return prototype
