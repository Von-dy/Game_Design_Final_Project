function _init()
 z=0 --beat speed
 c=0 --beat count

 --game object
 game={
   --0=menu, 1=travel, 2=boss, 3=game over
   state=2,
   frame_counter=0
 }
 --player list
 players = {}
 --hitscan list
 hitboxes = {}
 makeplayer(1)
 boss=generic_boss()
end

--generic boss class
function generic_boss()
 boss={
  state=0,
  hp=0,
  x=138,
  y=60,
  id=0
 }
 return boss
end

--determines what boss
--is being fought based on id (n)
function make_boss(n)
 if n==1 then
  --make heart boss
  heart_boss()
 end
end

--create the heart boss
function heart_boss()
 boss.ct=time()
 boss.bullets={}
 boss.sprite=17
 boss.name="heart"
 boss.state=0
 boss.hp=1
 boss.id=1
 boss.av={}
 boss.valves={}
 for i=1,4 do
  v=make_valve(i)
  add(boss.valves,v)
 end
end

--makes the valves for the heart boss
function make_valve(n)
 lx=96
 ly=22
 if n==2 then lx=120 ly=22 end
 if n==3 then lx=96 ly=100 end
 if n==4 then lx=120 ly=100 end
 valve={
 id=n,
 hp=50,
 x=lx,
 y=ly,
 sprite=16,
 bullets={}
 }
 return valve
end

--make a bullet for some owner in some direction
function make_bullet(o,d)
 b={
 x=o.x,
 y=o.y,
 d=d,
 sprite=21,
 spd=1
 }
 return b
end

--make a bullet that moves diagonally
function make_diagonal_bullet(o,diag)
 b={
 x=o.x,
 y=o.y,
 dia=diag,
 sprite=17,
 spd=1
 }
 return b
end

--determining what the heart boss does based on state
function hb_logic(s)
        timer=time()-boss.ct
        --if state 0 do nothing

        --if state 1 do clot attacks and valve bursts
        t=players[1]
        if s==1 then
         --determine side player is on
         --left(0) right(1)
         if t.x<=60 then side=0 else side=1 end
         --every 5 seconds do a clot attack
         if timer%5==0 then
                clot_attack(side)
         end
         --every 8 seconds find what valve will burst
         if timer%10==8 then
          boss.av=vb()
         end
         --every 10 seconds start a new valve burst volley
         if timer%10==0 then
          valve_burst(boss.av)
         end
        end

        --if in state 2 then do flood attack and streams
        if s==2 then
         --determine what valve will burst every 4 seconds
         if timer%5==4 then
          boss.av=vb()
         end
         --valve burst every 5 seconds
         if timer%5==0 then
          valve_burst(boss.av)
         end
         --every 20 seconds change where flood is coming from
         if timer%20==0 then
          --flood()
         end
        end

        --move whatever bullets have been shot
        move_bullets()
end

--rain clots of blood on one side of screen
function clot_attack(side)
 --generate where bullets will spawn
 for i=0,64,3 do
  tile={x=i,y=8}
  if side==1 then tile.x+=64 end
  t=rnd(5)
  if t<=1 then add(boss.bullets,make_bullet(tile,3)) end
 end
end

--determines what random valve
--bursts
function vb()
 id=flr(rnd(4))+1
 for v in all(boss.valves) do
  if id==v.id then v.sprite=7 return v end
 end
end

--for a valve, shoot a
--burst of bullets out
function valve_burst(v)
 v.sprite=16
 --make 8 bullets, 4 diagonals 4 straight
 for i=0,7 do
  if i<4 then
  b=make_bullet(v,i)
  add(boss.bullets,b)
  else
  b=make_diagonal_bullet(v,i)
  add(boss.bullets,b)
  end
 end
end

function move_bullets()
 for b in all(boss.bullets) do
  --save tokens
  d=b.d
  x=b.x
  y=b.y
  dia=b.dia
  spd=b.spd

  --delete bullets
  if x>128 or x<0 or y>112or y<8 then del(boss.bullets,b) end

  --normal bullet movement
  if d==0 then x-=spd
  elseif d==1 then x+=spd
  elseif d==2 then y-=spd
  elseif d==3 then y+=spd
  end

  --diagonal bullet movement
  if dia==4 then x-=spd y-=spd
  elseif dia==5 then x-=spd y+=spd
  elseif dia==6 then x+=spd y-=spd
  elseif dia==7 then x+=spd y+=spd
  end

  --update bullet values
  b.x=x
  b.y=y
 end
end

function makeplayer(slot)
 p={
   --0=grounded, 1=airborne, 2=crouch, 3=dodge
   state=0,
   last_action=0,
   num=slot,
   sprite=206,
   x=0,
   y=32,
   dx=0,
   dy=0,
   w=7,
   h=7,
   --direction(l/r)
   d=1,
   --jump flag
   j=0,
   --attacking flag
   a=0,
   --dodge duration
   dodge=0,
   --dodge cooldown
   dcl=60
 }
 --add player to list
 add(players,p)
end

function makehitbox(x,y,w,h,name)
 hbox = {
  x=x,
  y=y,
  w=w,
  h=h
 }
 hitboxes[name]=hbox
 add(hitboxes,hbox)
end

--movement functions
function groundmovement(player)
 --import vars
 local x=player.x
 local y=player.y
 local dx=player.dx
 local dy=player.dy

 --manage state
 if player.state<3 then
  if (solid(x,y+9) or solid(x+7,y+9)) then
   player.state=0
   dy=0
   player.sprite=206
  else
   player.state=1
   player.sprite=205
  end
 end

 --left
 if btn(0) then
  --change direction
  if player.d==1 then
   player.d=0
  end
  --move
  if dx > -2 then
   dx-=0.25
  end
  player.sprite=202
 end
 --right
 if btn(1) then
  if player.d==0 then
   player.d=1
  end
  if dx < 2 then
   dx+=0.25
  end
  player.sprite=203
 end
 --up
 if btn(2) then
  if player.j==0 then
   player.j=1
   dy=-3.5
  end
  if dy > -3 then
   dy-=0.03
  end
  player.sprite=205
 end
 --down
 if btn(3) then
  --crouch
  player.state=2
  --crawl (feel free to delete, just set dx=0)
  if dx~=0 then
   dx-=(dx/2)
  end
  player.sprite=204
 end
 --attack
 if btn(4) then
  --start attack if not attacking
  if player.a==0 then
   makehitbox(x,y,10,3,"player")
   player.a=1
  end
 end
 --extend hitbox
 if player.a==1 then
  --track position
  hitboxes["player"].x=x+2
  hitboxes["player"].y=y+2
  --attack left
  if player.d==1 then
   if hitboxes["player"].w<50 then
    hitboxes["player"].w+=3
    player.sprite=203
   else
    player.a=2
   end
  --attack right
  else
   if hitboxes["player"].w>-50 then
    hitboxes["player"].w-=3
    player.sprite=202
   else
    player.a=2
   end
  end
 --retract hitbox
 elseif player.a==2 then
  hitboxes["player"].x=x+2
  hitboxes["player"].y=y+2
  if player.d==1 then
   if hitboxes["player"].w>0 then
    hitboxes["player"].w-=3
   else
    --finish attack
    del(hitboxes,hitboxes["player"])
    player.a=0
   end
  else
   if hitboxes["player"].w<0 then
    hitboxes["player"].w+=3
   else
    --finish attack
    del(hitboxes,hitboxes["player"])
    player.a=0
   end
  end
 end

 --dodge
 if btn(5) then
  if player.dcl==0 then
   player.state=3
   player.dcl=100
   player.sprite=201
  end
 end
 if player.state==3 then
  if player.dodge<40 then
   dx=0
   dy=-0.15
   player.dodge+=1
   player.sprite=201
  else
   player.state=1
   player.dodge=0
  end
 else
  --cooldown
  if player.dcl>0 then
   player.dcl-=1
  end
 end

 --gravity
 if not solid(x,y+player.h+(dy+ 0.1)) then
  dy+=0.15
 else
  if player.j==1 then
   player.j=0
  end
  dy=0
 end

 --inertia
 if dx > 0 then
  dx-=0.06
 elseif dx < 0 then
  dx+=0.06
 end
 if dx > -0.06 and dx < 0.06 then
  dx=0
 end

 --horizontal movement
 if not (solid(x+dx,y+dy) or solid(x+7+dx,y+dy) or solid(x+7+dx,y+6+dy) or solid(x+dx,y+6+dy)) then
  if player.state==1 then
   x+=(dx/2+dx/4)
  else
   x+=dx
  end
  y+=dy
 else
  dx=0
  dy=0
 end
 --ground bounce
 if y>105 then
 y=104
 end
 --update vars
 player.x=x
 player.y=y
 player.dx=dx
 player.dy=dy
end

function solid(x,y)
 val=mget(x/8,y/8)
 return fget(val,0)
end

function _update60()
 if game.state==2 then
  for p in all(players) do
   groundmovement(p)
  end
  --determine what boss you are fighting
  if boss.id==0 then make_boss(1) end
  --change what boss state
  if btnp(4) then music(0) boss.state=(boss.state+1)%3 end
  if boss.id==1 then hb_logic(boss.state) end
  heart_beat()
 end
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==3 then c=0 else sfx(0) end end
end

function _draw()
 cls()
 map(0,0,0,0,16,16)
 draw_boss()
 print(boss.state)
 for p in all(players) do
  spr(p.sprite,p.x,p.y)
  print(p.state,32,16)
  print(p.dcl,32,26)
  --print(p.a,32,32)
 end
 for h in all(hitboxes) do
  rectfill(h.x,h.y,h.x+h.w,h.y+h.h)
  --print(h.w,32,42)
 end
 for b in all(boss.bullets) do
  spr(b.sprite,b.x,b.y)
 end
end

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
