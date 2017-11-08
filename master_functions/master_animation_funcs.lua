function _draw()
 cls()
 map(0,0,0,0,16,16)
 if game.state==0 then draw_menu() end
 if game.state==2 then draw_game() end
 if game.state==3 then gameover() end
end

function draw_menu()
 --menu "actors"
 for p in all(players) do 
  draw_characters(p)
  draw_syringe(p)
  draw_instructions(p)
 end
end

function draw_characters(p)
 local x=0
 local y=0
 if p.n==0 or p.n==2 then x=17 else x=77 end
 if p.n==0 or p.n==1 then y=24 else y=88 end
 if p.curr_choice==0 then spr(22, x, y) else spr(19, x, y) end
 if p.curr_choice==1 then spr(54, x+8, y) else spr(51, x+8, y) end
 if p.curr_choice==2 then spr(6, x+16, y) else spr(3, x+16, y) end
 if p.curr_choice==3 then spr(38, x+24, y) else spr(35, x+24, y) end
end

function draw_syringe(p)
 local x=0
 local y=32
 local fc=game.frame_counter
 local cc=p.curr_choice
 local p_col=p.syringe.p_col
 local s_col=p.syringe.s_col
 local circ_1=p.syringe.circ_1
 local circ_2=p.syringe.circ_2
 local circ_3=p.syringe.circ_3
 local circ_4 =p.syringe.circ_4

 if p.n==0 then x=8 else x=68 end
 spr(7, x, y, 6, 1)
 if cc==0 then p_col=2 s_col=8 end
 if cc==1 then p_col=1 s_col=12 end
 if cc==2 then p_col=3 s_col=11 end
 if cc==3 then p_col=4 s_col=9 end
 
 rectfill(x+9, y+1, x+41, y+6, p_col)
 rectfill(x+42, y+2, x+42, y+5, p_col)
 rectfill(x+43, y+3, x+43, y+4, p_col)

 if fc<30 then 
  if fc%12==0 then circ_1+=.5 end
  if fc%15==0 then circ_2+=.5 end
  if fc%14==0 then circ_3+=.5 end
  if fc%13==0 then circ_4+=.5 end
  if circ_1==3 then circ_1=0 end
  if circ_2==3 then circ_2=0 end
  if circ_3==3 then circ_3=0 end
  if circ_4==3 then circ_4=0 end
 end
 if game.frame_counter<30 then
  circfill(x+10, y+5-circ_1, 1, s_col)
  circ(x+19, y+5-circ_2, 1, s_col)
  circfill(x+29, y+5-circ_3, 1, s_col)
  circ(x+38, y+5-circ_4, 1, s_col)
 else
  circ(x+11, y+5-circ_1, 1, s_col)
  circfill(x+20, y+5-circ_2, 1, s_col)
  circ(x+28, y+5-circ_3, 1, s_col)
  circfill(x+37, y+5-circ_4, 1, s_col) 
 end 

 p.syringe.circ_1=circ_1
 p.syringe.circ_2=circ_2
 p.syringe.circ_3=circ_3
 p.syringe.circ_4=circ_4
end

function draw_instructions(p)
 local x=0
 local y=0
 if p.n==0 or p.n==2 then x=8 else x=68 end
 if p.n==0 or p.n==1 then y=40 else y=104 end

 if p.n==0 then 
  print("<- ->=cycle", x+5, y+1)
  print("z=lock", x+5, y+9)
 elseif p.n==1 then 
  print("a/f=cycle", x+5, y+1)
  print("lshift,=lock", x+5, y+9)
 end
end

function draw_game()
 draw_boss()
 draw_players()
 draw_hud()
 draw_bullets()
end

function draw_players()
 for p in all(players) do
  local p_s=p.cc
 end
end

--given id of boss, draw the hp
function draw_hud(id)
 --heart boss
 local hpleft=0
 if id==1 then 
  for v in all(boss.valves) do
   if v.sprite==1 then rectfill(v.x,v.y,v.x+3,v.y+8,1) end
   hpleft+=v.hp
  end
  rectfill(0,4,(hpleft/200)*128,6,10)
 --end heart boss drawing
 end
end

function draw_boss()
 if boss.id==1 then draw_heart() end
 if boss.id==2 then draw_stomach() end
 --if boss.id==3 then draw_lungs() end
 --if boss.id==4 then draw_brain() end
end

function draw_heart()
 sspr(0, 96, 8, 8, 108, 8, 8+c, 38)
 sspr(0, 104, 8, 8, 108, 74, 8+c, 38)
 sspr(0, 96, 8, 8, 84, 8, 8+c, 38)
 sspr(0, 104, 8, 8, 84, 74, 8+c, 38)
 sspr(0, 64, 32, 32, 76,40, 44+c, 44+c)
 draw_eyes(boss.state, 88, 56, 4, 12, 2, 8)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
end

function draw_stomach()
 sspr(32, 64, 32, 32, 76, 40, 44, 44)
 draw_eyes(boss.state, 88, 56, 4, 12, 3, 11)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
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
   if i==e_r then 
    line(l_e_x-i, e_y-e_r+i-1, l_e_x+i, e_y-e_r+i-1, p_col)
    line(r_e_x-i, e_y-e_r+i-1, r_e_x+i, e_y-e_r+i-1, p_col)
   else
    line(l_e_x-i-1, e_y-e_r+i-1, l_e_x+i+1, e_y-e_r+i-1, p_col)
    line(r_e_x-i-1, e_y-e_r+i-1, r_e_x+i+1, e_y-e_r+i-1, p_col)
   end
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
