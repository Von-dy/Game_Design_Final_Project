
function draw_boss()
 if c==1 then 
  draw_valves()
  sspr(88, 0, 32, 32, 75,39, 46, 46)
 else
  draw_valves()
  sspr(88, 0, 32, 32, 76,40, 44, 44)
 end
 draw_face()
end

function draw_face()
 local y=0
 local x=0

 for p in all(players) do
   y=p.y
   x=p.x
 end
 
  circfill(88, 56, 4, 7)
  circfill(100, 56, 4, 7)
 if boss.state>=1 then
   --left brow
  line(84, 49, 90, 53, 2)
  line(85, 50, 92, 54, 2)
  line(85, 51, 93, 55, 8)
  --right brow
  line(101, 49, 98, 53, 2)
  line(103, 50, 96, 54, 2)
  line(103, 51, 95, 55, 8)

  --angry mouth
  draw_lips(1, 91, 72, 16, 1, 5)
 else
  --happy mouth
  draw_lips(0, 91, 72, 16, 1, 5)
 end
 --pupil tracking
 draw_pupils(88, 56, 4, 12)
end

--left center_x, left center_y, radius, distance
function draw_pupils(c_x, c_y, r, d)
 local x=c_x-1
 local y=c_y
 local p_y=0
 local p_x=0

 for p in all(players) do
   p_y=p.y
   p_x=p.x
 end

 if p_y<=c_y then y-=1 end
 if p_y<=c_y+32 then y-=1 end
 if p_x>=c_x+20 then x+=1 end
 if p_x<=c_x-20 then x-=1 end
 if p_x>c_x-20 and p_x<c_x+20 then y+=1 end

 rectfill(x,y,x+2,y+2,0)
 rectfill(x+d,y,x+d+2, y+2, 0)
end

--mood, x, y, length, primary_col, secondary_col
function draw_lips(m, x, y, len, p_col, s_col)
 local l=len*2
 if m==0 then --happy mood
  for i=0, len-1 do
   pset(x+i, y-4*sin(i/l), p_col)
   pset(x+i, (y-1)-4*sin(i/l), s_col)
   pset(x+i, (y-2)-4*sin(i/l), s_col)
   if c!=1 then 
    pset(x+i, (y-3)-4*sin(i/l), p_col)
   else
    pset(x+i, (y-3)-4*sin(i/l), s_col)
    pset(x+i, (y-3)-4*sin(i/l), p_col)
   end
  end
 elseif m==1 then --angry mood
  for i=0, len-1 do
    pset(x+i, y+3*sin(i/l), p_col)
    pset(x+i, (y+1)+3*sin(i/l), s_col)
    pset(x+i, (y+2)+3*sin(i/l), s_col)
    if c!=1 then 
     pset(x+i, (y+3)+3*sin(i/l), p_col)
     if i%2==0 and i!=0 then pset(x+i, (y+2)+3*sin(i/l), 7) end
    else
     pset(x+i, (y+3)+3*sin(i/l), s_col)
     pset(x+i, (y+4)+3*sin(i/l), p_col)
     if i%2==0 and i!=0 then pset(x+i, (y+3)+3*sin(i/l), 7) end
    end
   end
  end
 end

 function draw_valves()
  sspr(80, 0, 8, 8, 108, 8, 8, 38)
  sspr(80, 8, 8, 8, 108, 74, 8, 38)
  sspr(80, 0, 8, 8, 84, 8, 8, 38)
  sspr(80, 8, 8, 8, 84, 74, 8, 38)
 end
