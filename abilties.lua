function getMovePoint(keys)
      local p = keys.target_points[1]
      --DebugDrawCircle(p, Vector(0,0,255), 5, 6, false, 60)
      local snapX = Pathing:SnapToCenter(p.x)
      local snapY = Pathing:SnapToCenter(p.y)
      --DebugDrawCircle(Vector(snapX,snapY,p.z), Vector(0,255,0), 5, 5, false, 60)
      --DebugDrawBox(Vector(snapX,snapY,p.z+1), Vector(-32,-32,0), Vector(32,32,0), 255, 0, 0, 4, 60)
      keys.caster:MoveWithPathing(Vector(snapX,snapY,p.z))
end

function getClosedPoint(keys)
      local p = keys.target_points[1]
      local snapX = Pathing:Snap(p.x)
      local snapY = Pathing:Snap(p.y)
     --DebugDrawCircle(Vector(snapX,snapY,p.z+1), Vector(0,255,0), 5, 5, false, 60)
     DebugDrawBox(Vector(snapX,snapY,p.z+1), Vector(-64,-64,0), Vector(64,64,40), 255, 0, 0, 20, 400)
     Pathing:BlockRectangularArea(snapX-64, snapX+64, snapY+64, snapY-64)
end