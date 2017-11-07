-- Collision Detection, Timers, Trackers, Math, Reusable Misc

function solid(x,y)
 return fget(mget(x/8,y/8),0)
end

function hcollide(x1,w1,y1,h1,x2,w2,y2,h2)
 return (x2>x1+w1 or x2+w2<x1 or y2>y1+h1 or y2+h2<y1) == false
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==3 then c=0 sfx(0,1) end end
end

function music_player(boss,state)
 --heart boss
 if boss.id==1 then
  --no music
  if state==0 then music(-1) end
  --start at track 0
  if state==1 then music(0) end
 end
end

function col_collision(p,c)
 for i=p.x+3,p.x+6 do
  for j=p.y+3,p.y+6 do
   if pget(i,j)==c then p.hp-=1 end
  end
 end
end

function update_menu()
 local ready_count=0
 for p in all(players) do
  update_player_menu(p)
  if p.syringe.ready==true then ready_count+=1 end
 end
 if ready_count==#players then game.state=1 end
end

function update_player_menu(p)
 --selection buttons
  if p.syringe.ready==false then 
   if btnp(0, p.n) then p.curr_choice-=1 end
   if btnp(1, p.n) then p.curr_choice+=1 end
  end
  if btnp(4, p.n) then if p.syringe.ready==false then p.syringe.ready=true else p.syringe.ready=true end end
 --selection boundries
 if p.curr_choice<0 then p.curr_choice=0 end
 if p.curr_choice>3 then p.curr_choice=3 end
end

function update_game()
 for p in all(players) do
   if p.hp<=0 then _init() end
   groundmovement(p)
   col_collision(p,10)
  end
  --determine what boss you are fighting
  if boss.id==0 then make_boss(1) end
  --fighting heart boss
  boss_logic(boss.id)
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==3 then c=0 sfx(0,1) end end
end
