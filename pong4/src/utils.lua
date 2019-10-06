function collides(a, b)
  -- aabb algorithm
  local collidesX = a.x + a.width >= b.x and b.x + b.width >= a.x
  local collidesY = a.y + a.height >= b.y and b.y + b.height >= a.y
  return collidesX and collidesY
end

function center(a, b)
  -- returns the middle point between two numbers
  return a*.5 - b*.5
end
