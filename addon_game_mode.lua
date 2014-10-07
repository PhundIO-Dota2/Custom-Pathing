-- Generated from template


-- module_loader by Adynathos.
BASE_MODULES = {
	'timers', 'pathing_abilities',

	'jumper/core/heuristics',
	'jumper/core/node', 'jumper/core/path',
	'jumper/grid', 'jumper/pathfinder',

	'jumper/search/astar', 'jumper/search/bfs',
	'jumper/search/dfs', 'jumper/search/dijkstra',
	'jumper/search/jps'
}

local function load_module(mod_name)
	-- load the module in a monitored environment
	local status, err_msg = pcall(function()
		require(mod_name)
	end)

	if status then
		log(' module ' .. mod_name .. ' OK')
	else
		err(' module ' .. mod_name .. ' FAILED: '..err_msg)
	end
end

-- Heap must be included specially
  require('jumper/core/bheap')

-- Load all modules
for i, mod_name in pairs(BASE_MODULES) do
	load_module(mod_name)
end
