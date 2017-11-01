
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
 for p in all(players) do y=p.y x=p.x end
  draw_eyes(boss.state, 88, 56, 4, 12, 2, 8)
  draw_lips(boss.state, 91, 72, 16, 1, 5)
  
  --pset(91,59,12)
  --pset(98,59,12)
  --if c>=1 then 
   --line(88-4,56,88+4, 56, 2)
   --line(100-4,56,100+4, 56, 2)
   --pset(97,59,12)
   --pset(92,59,12)
   --if game.frame_counter%50<=30 then
   --line(88-4,57,88+4, 57, 2)
   --line(88-3,58,88+3, 58, 2)
   --line(100-4,57,100+4, 57, 2)
   --line(100-3,58,100+3, 58, 2)
   --pset(92,60,12)
   --pset(97,60,12)
   --end
  --end
end

--mood, eye_x, eye_y, eye_r, distance, primary color, secondary color
function draw_eyes(m, e_x, e_y, e_r, d, p_col, s_col)
 local l_e_x=e_x
 local r_e_x=e_x+d

 --base circle
 circfill(e_x, e_y, e_r, 7)
 circfill(r_e_x, e_y, e_r, 7)
 
 --tracking pupils                                  -- sad pupils
 if m<=1 then draw_pupils(e_x, e_y, e_r, d, 0) else draw_pupils(e_x, e_y, e_r, d, 1) end

 --angry eyebrows
 if m==1 then 
  --left brow
 line(l_e_x-4, e_y-7, l_e_x+2, e_y-3, p_col)
 line(l_e_x-3, e_y-6, l_e_x+4, e_y-2, p_col)
 line(l_e_x-3, e_y-5, l_e_x+5, e_y-1, s_col)
 --right brow
 line(r_e_x+1, e_y-7, r_e_x-2, e_y-3, p_col)
 line(r_e_x+3, e_y-6, r_e_x-4, e_y-2, p_col)
 line(r_e_x+3, e_y-5, r_e_x+5, e_y-1, s_col)
 elseif m==2 then -- sad / eyelids
  for i=0, e_r do 
   line(l_e_x-i, e_y-e_r+i, l_e_x+i, e_y-e_r+i, p_col)
   line(r_e_x-i, e_y-e_r+i, r_e_x+i, e_y-e_r+i, p_col)
  end
  pset(91,59,12)
  pset(98,59,12)
 end

end

--left center_x, left center_y, radius, distance, mood
function draw_pupils(c_x, c_y, r, d, m)
 local x=c_x-1
 local y=c_y
 local p_y=0
 local p_x=0
 
 if m==0 then --tracking
  for p in all(players) do
   p_y=p.y
   p_x=p.x
  end
  if p_y<=c_y then y-=1 end
  if p_y<=c_y+32 then y-=1 end
  if p_x>=c_x+20 then x+=1 end
  if p_x<=c_x-20 then x-=1 end
  if p_x>c_x-20 and p_x<c_x+20 then y+=1 end
 elseif m==1 then --crying
  y+=1
 end
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
