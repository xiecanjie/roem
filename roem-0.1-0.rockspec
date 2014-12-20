package = 'roem'
version = '0.1-0'
dependencies = {
	'lua >= 5.1',
	'lua_cliargs >= 2.0',
	'stdlib >= 40-1',
	'penlight >= 1.0.0-1',
}
source = {
	url = '',
	dir = '',
}
description = {
	summary = 'Elegant Lua unit testing.',
	detailed = [[
		An elegant, extensible, testing framework.
		Ships with a large amount of useful asserts,
		plus the ability to write your own. Output
		in pretty or plain terminal format, JSON,
		or TAP for CI integration. Great for TDD
		and unit, integration, and functional tests.
	]],
	homepage = 'https://github.com/xiecanjie/Roem',
	license = 'MIT <http://opensource.org/licenses/MIT>',
}
build = {
	type = 'builtin',
	modules = {
		['Roem.Any'                          ] = 'src/Roem/Any.lua',
		['Roem.Context'                      ] = 'src/Roem/Context.lua',
		['Roem.ExceptionFormatter'           ] = 'src/Roem/ExceptionFormatter.lua',
		['Roem.Expectation'                  ] = 'src/Roem/Expectation.lua',
		['Roem.ExpectationResult'            ] = 'src/Roem/ExpectationResult.lua',
		['Roem.init'                         ] = 'src/Roem/init.lua',
		['Roem.Matcher'                      ] = 'src/Roem/Matcher.lua',
		['Roem.Matchers'                     ] = 'src/Roem/Matchers.lua',
		['Roem.ObjectContaining'             ] = 'src/Roem/ObjectContaining.lua',
		['Roem.Object'                       ] = 'src/Roem/Object.lua',
		['Roem.QueueRunner'                  ] = 'src/Roem/QueueRunner.lua',
		['Roem.ReportDispatcher'             ] = 'src/Roem/ReportDispatcher.lua',
		['Roem.Reporter'                     ] = 'src/Roem/Reporter.lua',
		['Roem.Spec'                         ] = 'src/Roem/Spec.lua',
		['Roem.Spy'                          ] = 'src/Roem/Spy.lua',
		['Roem.Suite'                        ] = 'src/Roem/Suite.lua',
		['Roem.Matchers.toBeCloseTo'         ] = 'src/Roem/Matchers/toBeCloseTo.lua',
		['Roem.Matchers.toBeDefined'         ] = 'src/Roem/Matchers/toBeDefined.lua',
		['Roem.Matchers.toBeFalsy'           ] = 'src/Roem/Matchers/toBeFalsy.lua',
		['Roem.Matchers.toBeGreaterThan'     ] = 'src/Roem/Matchers/toBeGreaterThan.lua',
		['Roem.Matchers.toBeLessThan'        ] = 'src/Roem/Matchers/toBeLessThan.lua',
		['Roem.Matchers.toBe'                ] = 'src/Roem/Matchers/toBe.lua',
		['Roem.Matchers.toBeNil'             ] = 'src/Roem/Matchers/toBeNil.lua',
		['Roem.Matchers.toBeTruthy'          ] = 'src/Roem/Matchers/toBeTruthy.lua',
		['Roem.Matchers.toContain'           ] = 'src/Roem/Matchers/toContain.lua',
		['Roem.Matchers.toEqual'             ] = 'src/Roem/Matchers/toEqual.lua',
		['Roem.Matchers.toHaveBeenCalled'    ] = 'src/Roem/Matchers/toHaveBeenCalled.lua',
		['Roem.Matchers.toHaveBeenCalledWith'] = 'src/Roem/Matchers/toHaveBeenCalledWith.lua',
		['Roem.Matchers.toMatch'             ] = 'src/Roem/Matchers/toMatch.lua',
		['Roem.Matchers.toThrow'             ] = 'src/Roem/Matchers/toThrow.lua',
		['Roem.Matchers.Util'                ] = 'src/Roem/Matchers/Util.lua',
		['Roem.Spy.CallTracker'              ] = 'src/Roem/Spy/CallTracker.lua',
		['Roem.Spy.Registry'                 ] = 'src/Roem/Spy/Registry.lua',
		['Roem.Spy.Strategy'                 ] = 'src/Roem/Spy/Strategy.lua',
	},
	install = {
		bin = {
			['roem'] = 'bin/roem',
		},
	},
}


