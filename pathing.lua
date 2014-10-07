--[[
	Dota 2 Pathing Library
	Created by Myll. www.github.com/Myll
]]

if Pathing == nil then
	print("[PATHING] Creating custom pathing.")
	Pathing = {}
end

function Pathing:Setup(nMapLength)
	MAP = {}
	HALF_LENGTH = nMapLength/2-32
	local gridnavCount = 0
	-- Check the center of each square on the map to see if it's blocked by the GridNav.
	for x=-HALF_LENGTH, HALF_LENGTH, 64 do
		local mapRow = {}
		for y=HALF_LENGTH, -HALF_LENGTH,-64 do
			if GridNav:IsTraversable(Vector(x,y,50)) == false or GridNav:IsBlocked(Vector(x,y,50)) then
				table.insert(mapRow, 1)
				--DebugDrawBox(Vector(x,y,150), Vector(-32,-32,0), Vector(32,32,0), 255, 0, 0, 20, 60)
				gridnavCount=gridnavCount+1
			else
				table.insert(mapRow, 0)
			end
		end
		table.insert(MAP, mapRow)
	end
	MAP = self:Transpose(MAP)
	print("Total GridNav squares added: " .. gridnavCount)

	-- Value for walkable tiles
	local walkable = 0

	-- Library setup
	local Grid = require ("jumper/grid") -- The grid class
	local Pathfinder = require ("jumper/pathfinder") -- The pathfinder lass

	-- Creates a grid object
	local grid = Grid(MAP)
	-- Creates a pathfinder object using Jump Point Search
	MyFinder = Pathfinder(grid, 'JPS', walkable)
end

function Pathing:BlockRectangularArea(leftBorderX, rightBorderX, topBorderY, bottomBorderY)
	if leftBorderX%64 ~= 0 or rightBorderX%64 ~= 0 or topBorderY%64 ~= 0 or bottomBorderY%64 ~= 0 then
		print("One of the values does not divide evenly into 64. Returning.")
		return
	end
	local blockedCount = 0
	for x=leftBorderX+32, rightBorderX-32, 64 do
		for y=topBorderY-32, bottomBorderY+32,-64 do
			blockedCount=blockedCount+1
			local Tx = self:WorldToTileX(x)
			--print("Tx = " .. Tx)
			local Ty = self:WorldToTileY(y)
			--print("Ty = " .. Ty)
			MAP[Ty][Tx] = 1
		end
	end
	--print("Total closed squares added: " .. blockedCount)
end

function Pathing:AddUnit(unit)
	unit.movementInProgress = false
	unit.next = nil
	unit.movementOrders = {}
	unit.pathing = true

	-- Constantly check if we have movement orders.
	Timers:CreateTimer(function()
		if not unit.pathing then
			unit:ClearOrders()
			return nil
		end
		-- Can't move a dead unit right?
		--[[if not unit:IsAlive() then
			unit.movementOrders = {}
			unit.movementInProgress = false
			return nil
		end]]
		local p = unit:GetAbsOrigin()
		if #unit.movementOrders > 0 and not unit.movementInProgress then
			-- Give the unit the next movement order.
			unit.next = unit.movementOrders[1]
			unit:MoveToPosition(unit.next)
			NEXT = unit.next
			--print("Moving unit.")
			unit.movementInProgress = true
			table.remove(unit.movementOrders, 1)
		end

		if unit.movementInProgress then
			if self:IsPointWithinSquare(p, unit.next) then
				--print("ArrivedAtMovementTarget")
				unit.movementInProgress = false
				if #unit.movementOrders < 1 then
					print("Final node reached.")
				end
			-- Anti-stuck code
			elseif unit:IsIdle() then
				--print("Idle.")
				unit:MoveToPosition(unit.next)
			end
		end
		return .02
	end)

	function unit:MoveWithPathing(v)
		local start = unit:GetAbsOrigin()
		--DebugDrawCircle(start, Vector(0,0,255), 5, 6, false, 60)
		local sX = Pathing:SnapToCenter(start.x)
		local sY = Pathing:SnapToCenter(start.y)
   	 	 --DebugDrawCircle(Vector(sX,sY,start.z), Vector(0,255,0), 5, 5, false, 60)
     	 --DebugDrawBox(Vector(sX,sY,start.z+1), Vector(-32,-32,0), Vector(32,32,0), 255, 0, 0, 4, 60)

		-- Define start and goal locations coordinates
		local startx, starty = Pathing:WorldToTileX(sX), Pathing:WorldToTileY(sY)
		local endx, endy = Pathing:WorldToTileX(v.x), Pathing:WorldToTileY(v.y)

		-- Calculates the path, and its length
		local path, length = MyFinder:getPath(startx, starty, endx, endy, false)
		if path then
			path:filter()
			unit:ClearOrders()
			local movementOrders = {}
			--self:InitiateMovement(path)
		 -- print(('Path found! Length: %.2f'):format(length))
			for node, count in path:iter() do
			--  print(('Step: %d - x: %d - y: %d'):format(count, node.x, node.y))
			  local v2 = Vector(Pathing:TileToWorldX(node.x), Pathing:TileToWorldY(node.y), start.z)
			  table.insert(movementOrders, v2)
			  DebugDrawBox(v2, Vector(-32,-32,0), Vector(32,32,0), 0, 255, 0, 30, 2)
			end
			unit.movementOrders = movementOrders
		end
	end

	function unit:ClearOrders()
		unit.movementInProgress = false
		unit.next = nil
		unit.movementOrders = {}
	end

	function unit:InitiateMovement(nodes)
		-- Initiate the first movement.
		-- Find first node with an X and Y.
		for node, count in nodes do
			if node:getX() ~= nil and node:getY() ~= nil then
				unit:MoveToPosition(Vector(Pathing:TileToWorldX(node:getX()), Pathing:TileToWorldY(node:getY()), 160))
				table.remove()
			end
		end
		Timers:CreateTimer(function()
			if not unit.movementInProgress then
				
			end
			if unit:ArrivedAtMovementTarget() then
				-- Go to next movement.

			end
			return .02
		end)
	end

	function unit:RemovePathing()
		unit.pathing = false
	end

	--[[
	-- give the unit a unique id
	local id = DoUniqueString("pathID")
	unit.pathID = id
	if not group then
		local newGroup = {}
		newGroup[id] = true
		table.insert(GROUPS, {})
	else
		-- add the unit to the specified group.
		group[id] = true
	end

	function group:RemoveUnit(unit)

	end]]
end

function Pathing:AddGroup(group)
	group.speed = 0
	group.formation = "normal"

	Timers:CreateTimer(function()
		if not unit.pathing then
			unit.movementInProgress = false
			unit.next = nil
			unit.movementOrders = {}
			return nil
		end
		-- Can't move a dead unit right?
		--[[if not unit:IsAlive() then
			unit.movementOrders = {}
			unit.movementInProgress = false
			return nil
		end]]
		local p = unit:GetAbsOrigin()
		if #unit.movementOrders > 0 and not unit.movementInProgress then
			-- Give the unit the next movement order.
			unit.next = unit.movementOrders[1]
			unit:MoveToPosition(unit.next)
			NEXT = unit.next
			--print("Moving unit.")
			unit.movementInProgress = true
			table.remove(unit.movementOrders, 1)
		end

		if unit.movementInProgress then
			if self:IsPointWithinSquare(p, unit.next) then
				--print("ArrivedAtMovementTarget")
				unit.movementInProgress = false
				if #unit.movementOrders < 1 then
					print("Final node reached.")
				end
			-- Anti-stuck code
			elseif unit:IsIdle() then
				--print("Idle.")
				unit:MoveToPosition(unit.next)
			end
		end
		return .02
	end)

	function group:SetSpeed(fSpeed)
		group.speed = fSpeed
	end

	function group:DefineSubGroup(subgroup)

	end

	function group:AddUnit(unit)
		table.insert(group, unit)
	end

	function group:RemoveUnit(unit)

	end

	function group:Delete()

	end

	function group:MoveToPosition(v)

	end

	function group:Stop()

	end
end

-------------------- UTILITY FUNCTIONS -----------------------

function Pathing:ChangeWalkable(tC, walkable)
	MAP[tC.x][tC.y] = walkable
end

function Pathing:IsPointWithinSquare(p, s)
	--if math.pow(player.hero:GetAbsOrigin().x,2) + math.pow(player.hero:GetAbsOrigin().y,2) <= math.pow(platformRadius-20,2)
	if (p.x > s.x-16 and p.x < s.x+16) and (p.y > s.y-16 and p.y < s.y+16) then
		return true
	else
		return false
	end
end

function Pathing:Transpose( m )
    local res = {}
 
    for i = 1, #m[1] do
        res[i] = {}
        for j = 1, #m do
            res[i][j] = m[j][i]
        end
    end
 
    return res
end

function Pathing:WorldToTileX(wC)
	local offset = wC + HALF_LENGTH
	local n = offset/64
	return n+1
end

function Pathing:WorldToTileY(wC)
	local offset = HALF_LENGTH-wC
	local n = offset/64
	return n+1
end

function Pathing:TileToWorldX(tC)
	return (tC-1)*64 - HALF_LENGTH
end

function Pathing:TileToWorldY(tC)
	return -1*((tC-1)*64 - HALF_LENGTH)
end

function Pathing:Snap(c)
	return 64*math.floor(0.5 + c/64)
end

function Pathing:SnapToCenter(c)
	return 32+64*math.floor(c/64)
end

function Pathing:PrintMap()
	for i,v in ipairs(MAP) do
		s = ""
		for i2,v2 in ipairs(v) do
			s = s .. v2 .. " "
			local x = self:TileToWorldX(i)
			local y = self:TileToWorldY(i2)
			if v2 == 1 then
				-- good test to see if tile funcs are working correctly.
				--x = self:TileToWorldX(self:WorldToTileX(x))
				--y = self:TileToWorldY(self:WorldToTileY(y))
				--DebugDrawBox(Vector(x,y,150), Vector(-32,-32,0), Vector(32,32,0), 0, 0, 255, 20, 60)
			elseif v2 == 0 then
				--DebugDrawBox(Vector(x,y,150), Vector(-32,-32,0), Vector(32,32,0), 0, 255, 0, 20, 60)
				--DebugDrawCircle(Vector(x,y,150), Vector(0,255,0), 10, 6, false, 60)
			else
				DebugDrawBox(Vector(x,y,150), Vector(-32,-32,0), Vector(32,32,0), 255, 0, 0, 20, 60)
			end
			--print("\n")
		end
		print(s)
	end
end

function GameMode:PrintMap()
  print( '******* PrintMap ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      Pathing:PrintMap()
    end
  end
end

function GameMode:ManualMove()
  print( '******* ManualMove ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      cmdPlayer:GetAssignedHero():MoveToPosition(NEXT)
    end
  end
end

function GameMode:Suicide()
  print( '******* Suicide ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      cmdPlayer:GetAssignedHero():ForceKill(true)
    end
  end
end

function GameMode:SpawnKnight()
  print( '******* SpawnKnight ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local pos = cmdPlayer:GetAssignedHero():GetAbsOrigin()
      CreateUnitByName("npc_knight", pos+Vector(200,0,0), true, nil, nil, DOTA_TEAM_GOODGUYS)
    end
  end
end

--GetMovementTargetPosition
function GameMode:GetMoveTarget()
  print( '******* GetMoveTarget ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      local rpg = cmdPlayer:GetControlledRPGUnit()
      local v = rpg:GetMovementTargetPosition()
      --PrintVector(v)
      PrintTable(v)
    end
  end
end

------------------- COLLISION ----------------------------
-- 2D dot product.
function Pathing:DotProduct(v1,v2)
  return (v1.x*v2.x)+(v1.y*v2.y)
end

--[[
	Continuous collision algorithm, see
	http://www.gvu.gatech.edu/people/official/jarek/graphics/material/collisionFitzgeraldForsthoefel.pdf
	
	body1 and body2 are tables that contain:
	v: velocity
	c: center
	r: radius
	Returns the time-to-collision.
]]
function Pathing:TimeToCollision(body1,body2)
  local W = body2.v-body1.v
  local D = body2.c-body1.c
  local A = DotProduct(W,W)
  local B = 2*DotProduct(D,W)
  local C = DotProduct(D,D)-(body1.r+body2.r)*(body1.r+body2.r)
  local d = B*B-(4*A*C)
  if d>=0 then
    local t1=(-B-math.sqrt(d))/(2*A)
    if t1<0 then t1=2 end
    local t2=(-B+math.sqrt(d))/(2*A)
    if t2<0 then t2=2 end
    local m = math.min(t1,t2)
    --if ((-0.02<=m) and (m<=1.02)) then
    return m
      --end
  end
  return 2
end