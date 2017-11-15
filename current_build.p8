pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

--change map
function set_area(x,y)
 for i=0,15 do
  for j=0,15 do
   mset(i,j,mget(i+x,j+y))
  end
 end
end

function _init()
 music(-1)
 sfx(-1)
 set_area(16,0)
 lbx,lby,z,c=0,0,0,0 --beat speed,count
 --game object
 game={
   --0=pmenu, 1=travel, 2=boss, 3=game over, 4=main menu
   state=4,
   frame_counter=0,
   playerct=1
 }
 --player list
 players = {}
 --hitscan list
 hitboxes = {}
 boss=generic_boss()
end

--generic boss class
function generic_boss()
 boss={
  state=0,
  hp=0,
  x=100,
  y=60,
  id=0,
  hboxes={},
  hitcooldown=0
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
 if n==2 then
 	--make stomach
 	stomach()
 end
 if n==3 then
  --make lung boss
  lungs()
 end
set_area(lbx/8,lby/8)
 scoreboard()
end

--create the heart boss
function heart_boss()
 boss.ct=time()
 boss.bullets={}
 lbx,boss.name,boss.state,boss.hp,boss.id=256,"heart",0,1,1
 boss.av={}
 boss.valves={}
 for i=1,4 do
  v=make_valve(i)
  add(boss.valves,v)
 end
end

function stomach()
 boss.ct=time()
 boss.bullets={}
 boss.enzymes={}
 lbx,boss.name,boss.state,boss.hp,boss.id,boss.hit=384,"stomach",0,100,2,0
end

function lungs()
 boss.ct=time()
 boss.hboxes= {}
 lhb,rhb,mhb=makehitbox(30,40,28,56),makehitbox(69,40,28,56),makehitbox(56,8,16,65)
 add(boss.hboxes,lhb)
 add(boss.hboxes,rhb)
 add(boss.hboxes,mhb)
 lbx,lby,boss.name,boss.state,boss.phase,boss.hp,boss.id=0,128,"lungs",0,0,100,3
end

--makes the valves for the heart boss
function make_valve(n)
 lx,ly=86,28
 if n==2 then lx=110 ly=28 end
 if n==3 then lx=86 ly=100 end
 if n==4 then lx=110 ly=100 end
 valve={
 id=n,
 hp=10,
 x=lx,
 y=ly,
 sprite=16,
 bullets={},
 hbox=makehitbox(lx,ly,3,8,nil)
 }
 return valve
end

--make a bullet for some owner in some direction
function make_bullet(o,d,sp)
 b={
 x=o.x,
 y=o.y,
 d=d,
 sprite=sp,
 spd=1,
 hbox=makehitbox(o.x+2,o.y+2,4,4,nil)
 }
 return b
end

function stomach_logic(s)
 timer=time()-boss.ct
 t=players[1]
 if boss.hit<=3 then s=0 end
 if boss.hit>3 and boss.hit<7 then s=1 end
 if boss.hit>=7 and boss.hit<9 then s=2 end
 if boss.hit==9 then 
  --kill boss
 end
  --first phase
 if s==0 then
  --spawn wave every six seconds
  if timer%6==0 then
   wave()
  end
  if timer%8==0 then 
   spawn_food(t)
  end
  if timer%11==0 then 
   local i=flr(rnd(3))+1
   spawn_enzyme(i)
  end
 end
 --second phase
 if s==1 then 
  if timer%6==0 then
   wave()
  end
  if timer%4==0 then 
   spawn_food(t)
  end
  if timer%11==0 then 
   local i=flr(rnd(3))+1
   spawn_enzyme(i)
  end
 end
 --final phase
 if s==2 then
	 if timer%6==0 then
	   wave()
	 end
	 if timer%4==0 then 
	  spawn_food(t)
	 end
	 if timer%11==0 then 
	  local i=flr(rnd(2))
	  if i==0 then i=3 end
   spawn_enzyme(i)
	 end
 end
 
 move_bullets()
 for e in all(boss.enzymes) do 
  move_enzyme(e)
 end
 boss.state=s
end

--determining what the heart boss does based on state
function hb_logic(s)
 timer=time()-boss.ct
 t=players[1]

 --if all valves destroyed
 if #boss.valves==0 then
  --death animation of boss
  --change game state
  --go to stomach boss
  make_boss(2)
 end

 if t.x<=60 then side=0 else side=1 end

 --check valve hp
 for v in all(boss.valves) do
  if v.hp<=0 then del(boss.valves,v) end
 end

 --if state 0 do nothing until attacked
	if s==0 then
	 for v in all(boss.valves) do
	  if v.hp<10 then s=1 boss.ct=time() end
	 end
	end

 --if state 1 do clot attacks and valve bursts
 if s==1 then
  --every 5 seconds do a clot attack
  if timer%5==0 then
   clot_attack(side)
  end
  --every 8 seconds find what valve will burst
  if timer%10==8 then
   boss.av=vb()
  end
  --every 10 seconds start a new valve burst volley
  if timer%10==0 and boss.av then
   valve_burst(boss.av)
  end

  if #boss.valves<=2 then s=2 end
 end

 --if in state 2 then do flood attack and streams
 if s==2 then
  --determine what valve will burst every 4 seconds
  if timer%5==4 then
   boss.av=vb()
  end
  --valve burst every 5 seconds
  if timer%5==0 and boss.av then
   valve_burst(boss.av)
  end
  --every 5 seconds do a clot attack
  if timer%5==0 then
   clot_attack(side)
  end
  --every 10 seconds change where flood is coming from
  if timer%6==0 then
   mini_heart()
  end
 end
 --move whatever bullets have been shot
 move_bullets()
 --update boss state
 if boss.id==1 then
  boss.state=s
 end
end

--lungs logic
function lungs_logic(s)
 timer=time()-boss.ct
 t=players[1]

end

function wave()
 --which pit to spawn from
 local side=flr(rnd(2))
 local space={x=32,y=104}
 if side==1 then space.x=96 end
 local height=3+side
 for i=0,height do 
  b=make_bullet(space,11,72)
  b.y-=8*i
  b.hbox.y-=8*i
  b.spawn_time=time()
  add(boss.bullets,b)
 end
end

function spawn_food(t)
 local sprite=195
 if flr(rnd(2))==1 then sprite=196 end
 local b=make_bullet(boss,13,sprite)
 b.targetx=t.x
 b.targety=t.y
 b.offset=flr(rnd(10)) - flr(rnd(10))
 b.ang=food_angle(b)
 add(boss.bullets,b)
end

function food_angle(b)
 local dx=boss.x-b.targetx+b.offset
 local dy=b.targety-boss.y
 return atan2(dx,dy)
end

function spawn_enzyme(i)
 sp=199
 if i==2 then sp=201 end
 if i==3 then sp=200 end
 e={
 x=120,
 y=8,
 id=i,
 spd=1,
 sprite=sp,
 hbox=makehitbox(120,0,7,7),
 state=0,
 spawn=time(),
 }
 add(boss.enzymes,e)
end

function move_enzyme(e)
 x,y,spd,id,state=e.x,e.y,e.spd,e.id,e.state
 hbx,hby=e.hbox.x,e.hbox.y
 --delete if out of bounds 
 if x>128 or x<0 or y<0 or y>112 then del(boss.enzymes, e) end
 --delete if hit player
 for p in all(players) do
  if p.state~=3 and hcollide(hbx,7,hby,7,p.x,p.w,p.y,p.h) then del(boss.enzymes,e) p.hp-=1 end
 end
 
 
 --move first enzyme horizontally until it matches with player
 if id==1 then
  --move along horizontally
  if state==0 then 
   x-=1
   hbx-=1
   for p in all(players) do
    if x<p.x+6 and x>p.x-6 then state=1 end
   end
  end
  
  --if same axis as a player, attack
  if state==1 then y+=1 hby+=1 end
  if state==5 then
   y+=1
   hbx=-10
   hby=-10
   if y==112 then 
    if x>104 then boss.hit+=1 end
    del(boss.enzymes,e)
   end
  end
 
 --move along vertically until on same axis as a player   
 elseif id==2 then
  --move along vertically
  if state==0 then
   y+=1 
   hby+=1 
   for p in all(players) do
    if y<p.y+6 and y>p.y-6 then state=1 end
   end
  end
  
  --if on same axis as player
  if state==1 then x-=1 hbx-=1 end 
  if state==5 then 
   y+=1 
   hbx=-10 
   hby=-10
   if y==112 then 
    if x>48 and x<88 then boss.hit+=1 end
    del(boss.enzymes,e)
   end
  end 
 
 --teleport above different fruit and burst occasionally  
 elseif id==3 then
  --change spawns every so often
  if state==4 then del(boss.enzymes,e) end
  if state==1 then x,y,hbx,hby=10,60,10,60 end
  if state==2 then x,y,hbx,hby=68,60,68,60 end
  if state==3 then x,y,hbx,hby=116,60,116,60 end
  if state==5 then
   y+=1
   hbx=-10
   hby=-10
   if y==112 then 
    if x<24 then boss.hit+=1 end
    del(boss.enzymes,e)
   end
  end
  if state~=5 then
   if (time()-e.spawn)%3==0 then state+=1 end
   if (time()-e.spawn)%8+1==0 then
    for i=0,1 do
     add(boss.bullets,make_bullet(e,i,48))
    end
   end 
  end
 end
 --update vals
 e.x,e.y,e.spd,e.id,e.state=x,y,spd,id,state
 e.hbox.x,e.hbox.y=hbx,hby
end

--rain clots of blood on one side of screen
function clot_attack(side)
 --generate where bullets will spawn
 for i=0,64,8 do
  tile={x=i,y=8}
  if side==1 then tile.x+=64 end
  t=rnd(5)
  if t<=3.5 then add(boss.bullets,make_bullet(tile,3,48)) end
 end
end

--determines what random valve
--bursts
function vb()
 ids={}
 --compose list of all valves
 for v in all(boss.valves) do
  add(ids,v.id)
 end
 selector=flr(rnd(#ids))+1
 id=ids[selector]
 --find which valve is the active one
 for v in all(boss.valves) do
  if id==v.id then v.sprite=1 return v end
 end
end

--shoot a mini heart across the screen
function mini_heart()
 local y=flr(rnd(104))+8
 tile={x=128, y=y}
 add(boss.bullets,make_bullet(tile,10,23))
end

--for a valve, shoot a
--burst of bullets out
function valve_burst(v)
 v.sprite=16
 --make 8 bullets, 4 diagonals 4 straight
 for i=0,7 do
  add(boss.bullets,make_bullet(v,i,48))
 end
end

function move_bullets()
 for b in all(boss.bullets) do
  --save tokens
  d,x,y,hbox,dia,spd,good=b.d,b.x,b.y,b.hbox,b.dia,b.spd,true
  hx,hy=hbox.x,hbox.y

  --bullet collision with player
		for p in all(players) do
   if p.state~=3 and hcollide(hx,hbox.w,hy,hbox.h,p.x,p.w,p.y,p.h) then
    p.hp-=1
    del(boss.bullets,b)
    good=false
    p.hitcooldown=120
    p.scores[boss.id].hitstaken+=1
   end
  end

  --if no collide with player
  if good then
	  --delete bullets
	  if x>128 or x<0 or y>112 or y<8 or solid(hbox.x,hbox.y) or solid(hbox.x+hbox.w, hbox.y+hbox.h) then del(boss.bullets,b)
	  else

	  --normal bullet movement
	  if d==0 then x-=spd hx-=spd
	  elseif d==1 then x+=spd hx+=spd
	  elseif d==2 then y-=spd hy-=spd
	  elseif d==3 then y+=spd hy+=spd
	  end

	  --diagonal bullet movement
	  if d==4 then x-=spd y-=spd hx-=spd hy-=spd
	  elseif d==5 then x-=spd y+=spd hx-=spd hy+=spd
	  elseif d==6 then x+=spd y-=spd hx+=spd hy-=spd
	  elseif d==7 then x+=spd y+=spd hx+=spd hy+=spd
	  end

	  --special bullet movement
	  --mini heart
	  if d==10 then x-=spd y+=1.5*cos(.5*time()) hx-=spd hy+=1.5*cos(.5*time()) end
          --wave
	  if d==11 then
	   if time()-b.spawn_time>3 then del(boss.bullets,b) end
	  end 
	  --thrown food
	  if d==13 then x-=spd*cos(b.ang) hx-=spd*cos(b.ang) y+=spd*sin(b.ang) hy+=spd*sin(b.ang) end
	  --update bullet values
	  b.x=x
	  b.y=y
	  hbox.x=hx
	  hbox.y=hy
	  b.hbox=hbox
	  end
  end
 end
end

--[[function col_collision(p,c)
 for i=p.x+3,p.x+6 do
  for j=p.y+3,p.y+6 do
   if pget(i,j)==c then p.hp-=1 end
  end
 end
end]]

function makeplayer(slot)
 p={
  --menu items
  curr_choice = 0,
  syringe={
  p_col=3,
  s_col=11,
  circ_1=0,
  circ_2=0,
  circ_3=0,
  circ_4=0,
  ready=false
 },
   --0=grounded, 1=airborne, 2=crouch, 3=invuln
   state=0,
   last_action=0,
   scores={ total=0 },
   n=slot,
   sprite=6,
   x=20,
   y=31,
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
   --attacking cooldown
   ac=0,
   --dodge duration
   dodge=0,
   --dodge cooldown
   dcl=60,
   dflag=0,
   hp=3,
   hitcooldown=0,
   hitbox={}
 }
 if slot==1 then p.x=12 end
 --add player to list
 add(players,p)
end

--track stats for score
function scoreboard()
 --sorry for the token count, but there's no easy way to clone tables in pico 8
 thisboard={
  bossid=boss.id,
  lasttime=time(),
  timer=0,
  total=0,
  hitstaken=0,
  hitsgiven=0
 }
 players[1].scores[boss.id]=thisboard
 if game.playerct==2 then
  thatboard={
   bossid=boss.id,
   lasttime=time(),
   timer=0,
   hitstaken=0,
   hitsgiven=0
  }
  players[2].scores[boss.id]=thatboard
 end
end

function makehitbox(x,y,w,h)
 hbox = {
  x=x,
  y=y,
  w=w,
  h=h
 }
 return hbox
end

--hurt collision
function hcollide(x1,w1,y1,h1,x2,w2,y2,h2)
 return (x2>x1+w1 or x2+w2<x1 or y2>y1+h1 or y2+h2<y1) == false
end


--movement functions
function groundmovement(player)
 --import vars
 x,y,dx,dy,state,d,w,h,j,a,ac,dcl,dodge,dflag,n=player.x,player.y,player.dx,player.dy,player.state,player.d,player.w,player.h,player.j,player.a,player.ac,player.dcl,player.dodge,player.dflag,player.n
 hbox=player.hitbox
 --manage state
 if state<3 then
  if (solid(x,y+9) or solid(x+w,y+9)) then
   state=0
   j=0
   dy=0
  else
   state=1
  end
 end

 --left
 if btn(0,n) then
  --change direction
  if d==1 then d=0 end
  --move
  if dx > -2 then dx-=0.25 end
 end

 --right
 if btn(1,n) then
  if d==0 then d=1 end
  if dx < 2 then dx+=0.25 end
 end

 --up
 if btn(2,n) then
  if j==0 then
   j=1
   dy=-3.5
  end
  if dy > -3 then dy-=0.03 end
 end

 --down
 if btn(3,n) then
  --crouch
  state=2
  --crawl (feel free to delete, just set dx=0)
  if dx~=0 then
   dx-=(dx/8)
   h=3
  end
 else
  h=7
 end

 --attack
 if btn(4,n) then
  --start attack if not attacking
  if a==0 and ac<1 then
   player.hitbox=makehitbox(x,y,10,3)
   a,ac=1,40
  end
 end

 --extend hitbox
 if player.a==1 then
  --track position
  hbox.y=y+2
  --attack right
  if d==1 then
   hbox.x=x+2
   if hbox.w<50 then
    hbox.w+=3
   else
    a=2
   end
  --attack left
  else
   hbox.x=x-(hbox.w-4)
   if hbox.w<50 then
    hbox.w+=3
    hbox.x-=3
   else
    a=2
   end
  end

 --retract hitbox
 elseif player.a==2 then
  hbox.y=y+2
  if d==1 then
   hbox.x=x+2
   if hbox.w>0 then
    hbox.w-=3
   else
    --finish attack
    hbox={}
    a=0
   end
  else
   hbox.x=x-(hbox.w-8)
   if hbox.w>0 then
    hbox.w-=3
   else
    --finish attack
    hbox={}
    a=0
   end
  end
 end

 --attack cooldown
 if ac>0 then
  ac-=1
 end

 --dodge
 if btn(5,n) then
  if dcl==0 then
   dflag=1
   state=3
   dcl=100
  end
 end

 --if invuln
 if state==3 then
  --if the player was dodging
  if dflag==1 then
   if dodge<40 then
    dx=0
    dy=-0.15
    dodge+=1
   --player was hit
   elseif player.hitcooldown>0 then
    player.hitcooldown-=1
   else
    state,dodge,dflag=1,0,0
   end
  end
 end

 --cooldown
 if dcl>0 then
  dcl-=1
 end
 if player.hitcooldown>0 then
  player.hitcooldown-=1
 end

 --gravity
 if not (solid(x,y+7+(dy+ 0.1)) or solid(x+player.w,y+7+(dy+0.1))) then
  dy+=0.15
 else
  if j==1 then
   j=0
  end
  dy=0
 end

 --inertia
 if dx > 0 then
  dx-=0.1
 elseif dx < 0 then
  dx+=0.1
 end
 if dx > -0.06 and dx < 0.06 then
  dx=0
 end

 --horizontal movement
 if not (solid(x+dx,y+dy) or solid(x+7+dx,y+dy) or solid(x+7+dx,y+6.5+dy) or solid(x+dx,y+6.5+dy)) then
  if state==1 then
   x+=(dx/2+dx/4)
  else
   x+=dx
  end
  y+=dy
 else
  dx,dy=0,0
 end
 --ground bounce
 if y>116 then
  dy=-3.2
  if player.hitcooldown==0 then player.hp-=1 player.hitcooldown=120 end
 end
 if solid(x,y+7) or solid(x+7,y+7) then
  y-=0.1
 end
 --update vars
 if (x<0 or x>122) then
  x=player.x
 end

 player.x,player.y,player.dx,player.dy,player.state,player.d,player.w,player.h,player.j,player.a,player.ac,player.dcl,player.dodge,player.dflag=x,y,dx,dy,state,d,w,h,j,a,ac,dcl,dodge,dflag
 player.hitbox=hbox
end

function boss_interaction(id,player)
 --heart interaction
 if id==1 then
  for v in all(boss.valves) do
   if attackcollide(player,v) then v.hp-=1 end
  end
 end
 --stomach interaction
 if id==2 then
    for enz in all(boss.enzymes) do
     if attackcollide(player,enz) then enz.state=5 end
    end
  if fget(mget(player.x/8,player.y/8),4) then player.hp-=1 end
 end
 --lungs interaction
 if id==3 then
  for hb in all(boss.hboxes) do
   if attackcollide(player,hb) then boss.hp-=1 end
  end
 end
end

function attackcollide(p,hb)
 local hbp=p.hitbox
 --check for collision
 if hbp.x and boss.hitcooldown==0 and hcollide(hbp.x,hbp.w,hbp.y,hbp.h,hb.x,hb.w,hb.y,hb.h) then
   boss.hitcooldown=30
   p.a=2
   p.scores[boss.id].hitsgiven+=1
   return true
 end
 return false
end

function solid(x,y)
 return fget(mget(x/8,y/8),0)
end

function music_player(boss,state)
 --heart boss
 if boss.id==1 then
  --no music
  if state==0 then music(-1) end
  --start at track 0
  if state==1 then music(0) end 
 end
 --stomach
 if boss.id==2 then
  if state==0 then music(-1) end
 end
end

function boss_logic(id)
 s=boss.state
 if boss.id==1 then
  hb_logic(s)
  heart_beat()
 end
 if boss.id==2 then
  stomach_logic(s)
 end
 if boss.id==3 then
  lungs_logic(s)
 end
 --if phase change
 if s~=boss.state then music_player(boss,boss.state) end
 if boss.hitcooldown>0 then
  boss.hitcooldown-=1
 end
end

function _update60()
 game.frame_counter+=1
 if game.frame_counter>=60 then game.frame_counter=0 end
 if game.state==0 then update_menu() end
 if game.state==2 then update_game() end
 if game.state==3 then update_gameover() end
 if game.state==4 then update_mainmenu() end
end

function update_mainmenu()
 --navigation
 if btn(2) then
  game.playerct=1
 elseif btn(3) then
  game.playerct=2
 end
 if btn(4) then
  --make players
  makeplayer(0)
  if game.playerct==2 then
   makeplayer(1)
   players[2].curr_choice+=1
  end
  game.state=0
 end
end

function update_menu()
 local ready_count=0
 for p in all(players) do
  update_player_menu(p)
  if p.syringe.ready==true then ready_count+=1 end
 end
 if ready_count==#players then game.state=2 end
end

function update_player_menu(p)
 --selection buttons
  if p.syringe.ready==false then
   if btnp(0, p.n) then p.curr_choice-=1 end
   if btnp(1, p.n) then p.curr_choice+=1 end
  end
  if btnp(4, p.n) then
   if p.syringe.ready==false then
    if game.playerct==1 then
     p.syringe.ready=true
    else
     if p.n==0 and players[2].curr_choice~=p.curr_choice then
      p.syringe.ready=true
     elseif p.n==1 and players[1].curr_choice~=p.curr_choice then
      p.syringe.ready=true
     end
    end
   end
  end
 --selection boundries
 if p.curr_choice<0 then p.curr_choice=0 end
 if p.curr_choice>3 then p.curr_choice=3 end
end

function update_game()
 count=0
 for p in all(players) do
   if p.hp<=0 then count+=1 end
   if game.playerct==1 then
    if count>0 then game.state=3 end
   else
    if count==2 then game.state=3 end
   end
   if p.hp>0 then
    groundmovement(p)
    boss_interaction(boss.id,p)
    update_player_sprite(p)
   else p.x=-20 end
  end
  --determine what boss you are fighting
  if boss.id==0 then make_boss(3) end
  --fighting heart boss
  boss_logic(boss.id)
  update_timers()
end

function update_timers()
 local t=time()
 local currboss=boss.id
 for p in all(players) do
  if t-p.scores[boss.id].lasttime>2 and p.hp>0 then
   p.scores[boss.id].timer+=1
   p.scores[boss.id].lasttime=t
   p.scores[boss.id].total=(100*p.scores[boss.id].hitsgiven)-(50*p.scores[boss.id].hitstaken)-p.scores[boss.id].timer
  end
 end
end

function update_player_sprite(p)
 local p_s=0
 local p_state=p.state
 local p_d=p.d
 local p_c=p.curr_choice
 --0=grounded, 1=airborne, 2=crouch, 3=dodge
 if p_state==0 then if p_d==1 then p_s=2 else p_s=1 end end
 if p_state==1 then p_s=4 end
 if p_state==2 then p_s=3 end
 --color offset
 if p_state!=3 then
  if p_c==0 then p_s+=16 end
  if p_c==1 then p_s+=48 end
  --green is the base so no offset is applied
  if p_c==3 then p_s+=32 end
  p.sprite=p_s
 else p.sprite=16 end
end

function update_gameover()
 --x to restart
 if btn(5) then _init() end
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==3 then c=0 sfx(0,1) end end
end

function _draw()
 cls()
 map(0,0,0,0,16,16)
 if game.state==0 then draw_menu() end
 if game.state==2 then draw_game() end
 if game.state==3 then draw_gameover() end
 if game.state==4 then draw_mainmenu() end
end

function draw_mainmenu()
 --title
 print("definitely not cuphead",20,30,3)
 line(15,38,112,38)
 --mode choice
 print("1 player",20,90,11)
 print("2 players",20,100)
 --cursor
 if game.playerct==1 then spr(39,10,89) else
  spr(39,10,99)
 end
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
 --wtf
 spr(7, x, y, 6, 1)
 spr(10,x+4*8,y,2,1)
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
  --code for keyboard layout
  print("<- ->=cycle", x+5, y+1)
  print("z=lock", x+5, y+9)
  print("controls:", x+5, y+22)
  print("arrow keys", x+5, y+30)
  print("z=attack", x+5, y+38)
  print("x=dodge", x+5, y+46)

  --code for controller layout
  --print("d-pad=cycle", x+5, y+1)
  --print("x=lock", x+5, y+9)
  --print("controls:", x+5, y+22)
  --print("d-pad=move", x+5, y+30)
  --print("x=attack", x+5, y+38)
  --print("o=dodge", x+5, y+46)
 elseif p.n==1 then
  --code for keyboard layout
  print("s and f=cycle", x+5, y+1)
  print("lshift=lock", x+5, y+9)
  print("controls:", x+5, y+22)
  print("e,s,d,f", x+5, y+30)
  print("lshift=attack", x+5, y+38)
  print("a=dodge", x+5, y+46)
 end

  --code for controller layout
  --print("d-pad=cycle", x+5, y+1)
  --print("x=lock", x+5, y+9)
  --print("controls:", x+5, y+22)
  --print("d-pad=move", x+5, y+30)
  --print("x=attack", x+5, y+38)
  --print("o=dodge", x+5, y+46)
end

function draw_game()
 draw_boss()
 draw_players()
 draw_hud(boss.id)
 draw_bullets()
end

function draw_players()
 --debug stuff
 print(players[1].scores[boss.id].timer,5,2)
 print(players[1].x,20,2,7)
 print(players[1].y,80,2)
 for p in all(players) do
  local p_cc=p.curr_choice
  local p_hb=p.hitbox
  local pcol=0
  local scol=0

  if p_cc==0 then
   pcol=2
   scol=8
  end
  if p_cc==1 then
   pcol=1
   scol=12
  end
  if p_cc==2 then
   pcol=3
   scol=11
  end
  if p_cc==3 then
   pcol=9
   scol=10
  end
  spr(p.sprite,p.x,p.y)
  if p_hb.x then
  for i=0, p_hb.w-1 do
   local col=flr(rnd(3))
   if col>1 then pset(p_hb.x+i, 2*sin(i/p_hb.w)+p_hb.y+2, pcol) else pset(p_hb.x+i, 2*sin(i/p_hb.w)+p_hb.y+2, scol) end
  end
  end
 end
end

--given id of boss, draw the hp
function draw_hud(id)
 --heart boss
 local hpleft=0
 if id==1 then
  for v in all(boss.valves) do
   hpleft+=v.hp
  end
  rectfill(0,4,(hpleft/40)*128,6,10)
 --end heart boss drawing
 end
 --stomach boss
 if id==2 then
  rectfill(0,4,(9-boss.hit)/9*128,6,10)
 end
 for p in all(players) do
  tempx=10
  if p.n==1 then tempx=80 end
  if p.hp>0 then
   for h=1,p.hp do
    spr(32,tempx+h*8,120)
   end
  end
 end
 --lung boss
 if id==3 then
  rectfill(0,4,(boss.hp/10)/9*128,6,10)
 end
 print(boss.state,20,60)
end

function draw_boss()
 if boss.id==1 then draw_heart() end
 if boss.id==2 then draw_stomach() draw_food() draw_enzymes() end
 if boss.id==3 then draw_lungs() end
 --if boss.id==4 then draw_brain() end
end

function draw_enzymes()
 for e in all(boss.enzymes) do
  spr(e.sprite,e.x,e.y)
 end
end

function draw_food()
 --apple
 sspr(8,96,16,16,0,104,24,16)
 --plum
 sspr(8,112,8,8,112,104,16,16)
 --banana
 sspr(24,104,16,16,56,104,24,16,false,true)
end

function draw_heart()
 sspr(0, 96, 8, 8, 108, 8, 8, 38)
 sspr(0, 104, 8, 8, 108, 74, 8, 38)
 sspr(0, 96, 8, 8, 84, 8, 8, 38)
 sspr(0, 104, 8, 8, 84, 74, 8, 38)
 sspr(0, 64, 32, 32, 76,40, 44+c%2, 44+c%2)
 draw_eyes(boss.state, 88, 56, 4, 12, 2, 8)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
end

function draw_stomach()
 sspr(32, 64, 32, 32, 76, 40, 44, 44)
 draw_eyes(boss.state, 88, 56, 4, 12, 3, 11)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
end

function draw_lungs()
 --trachea
 sspr(0, 112, 6, 8, 56, 8, 16, 64)
 --left lung
 sspr(65, 66, 13, 28, 31, 40, 26, 56)
 --right lung
 sspr(82, 66, 13, 28, 71, 40, 26, 56)
 draw_eyes(0, 48, 56, 6, 31, 14, 8)
 --show hurtboxes (debug)
 for hb in all(boss.hboxes) do
  rect(hb.x,hb.y,hb.x+hb.w,hb.y+hb.h)
 end
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

function draw_bullets()
 for b in all(boss.bullets) do
  spr(b.sprite,b.x,b.y)
 end
end

function draw_gameover()
 cls()
 print("game over",50,30,3)
 line(50,36,84,36,3)
 print("time",24,42,11)
 print("hits",44,42)
 print("flubs",64,42)
 print("score",92,42)
 local ypos=56
 for p in all(players) do
  spr(p.sprite,12,ypos)
  print(p.scores[boss.id].timer,30,ypos)
  print(p.scores[boss.id].hitsgiven,50,ypos)
  print(p.scores[boss.id].hitstaken,70,ypos)
  print(p.scores[boss.id].total,96,ypos)
  ypos+=16
 end
 print("x to restart",45,100,3)
end
__gfx__
00000000000b30000003b0000000000000b33b0000b33b000003b000000770007777777777777777777777777700000000000000000000000000000000000000
0000000000b33b0000b33b00000000000b333bb00b333bb000b33b00000770007000000000000000000000000070000000000000000000000000000000000000
007007000333b3b00b3b333000000000b3733733b37337330b3b3330000770007000000000000000000000000007000000000000000000000000000000000000
0007700037373330033373730000000003b333b003b333b0337337b3000777777000000000000000000000000000700000000000000000000000000000000000
0007700003b333b00b333b3000b33b0000333b0000333b000b333b30000777777000000000000000000000000000555500000000000000000000000000000000
007007000033b300003b33000bb333b00030030000300300003b3300000770007000000000000000000000000007000000000000000000000000000000000000
0000000033b3b3b00b3b3b333373373300b0030000b00300b33b3b3b000770007000000000000000000000000070000000000000000000000000000000000000
00000000b0303030030303030b3b3b3000b00b0000b00b0030300303000770007777777777777777777777777700000000000000000000000000000000000000
00076000000820000002800000000000008228000082280000028000000000000000000000000000000000000007700077777777777777777777777777000000
00677600008228000082280000000000082228800822288000822800000000000000000000000000000000000007700070000000000000000000000000700000
06767770022282800828222000000000827227228272272208282220088088000000000000000000000000000007700070000000000000000000000000070000
778778672727222002227272000000000282228002822280227227828ee8ee800000000000000000000000000007777770000000000000000000000000007000
067776700282228008222820008228000022280000222800082228208eeeee800000000000000000000000000007777770000000000000000000000000005555
0076770000228200002822000882228000200200002002000028220008eee8000000000000000000000000000007700070000000000000000000000000070000
67767676228282800828282222722722008002000080020082282828008e80000000000000000000000000000007700070000000000000000000000000700000
70700707802020200202020208282820008008000080080020200202000800000000000000000000000000000007700077777777777777777777777777000000
06666660000490000009400000000000004994000049940000094000000000000000000000000000000000000000000000000000000000000000000000000000
00666600004994000049940000000000049994400499944000499400000000000000000000000000000000000000000000000000000000000000000000000000
00bbbb000999494004949990000000004979979949799799049499900bbbbb000000000000000000000000000000000000000000000000000000000000000000
06bbbb60979799900999797900000000094999400949994099799749003333b00000000000000000000000000000000000000000000000000000000000000000
06bbbb60094999400499949000499400009994000099940004999490003333b00000000000000000000000000000000000000000000000000000000000000000
06bbbb600099490000949900044999400090090000900900009499000bbbbb000000000000000000000000000000000000000000000000000000000000000000
006bb600994949400494949999799799004009000040090049949494000000000000000000000000000000000000000000000000000000000000000000000000
00066000409090900909090904949490004004000040040090900909000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c10000001c0000000000000c11c0000c11c000001c000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000c11c0000c11c00000000000c111cc00c111cc000c11c00000000000000000000000000000000000000000000000000000000000000000000000000
007777000111c1c00c1c111000000000c1711711c17117110c1c1110000000000000000000000000000000000000000000000000000000000000000000000000
0777777017171110011171710000000001c111c001c111c0117117c1000000000000000000000000000000000000000000000000000000000000000000000000
0777777001c111c00c111c1000c11c0000111c0000111c000c111c10000000000000000000000000000000000000000000000000000000000000000000000000
007777000011c100001c11000cc111c00010010000100100001c1100000000000000000000000000000000000000000000000000000000000000000000000000
0007700011c1c1c00c1c1c111171171100c0010000c00100c11c1c1c000000000000000000000000000000000000000000000000000000000000000000000000
00000000c0101010010101010c1c1c1000c00c0000c00c0010100101000000000000000000000000000000000000000000000000000000000000000000000000
ffff77772e282e8222eeee22dddddddd4f44f44fef8e8f8f8111181122888822ffffffffff3333ff7777777766666666fffff33feeeeffeeffffffff00000000
ffff7777e282e82e2e2277e2ddddddddf77f47f7f8ff88e81818188828227782fffafffffbfa773f7777777766666666fffabf73eeeefeeeffffffff00000000
ffff777782e22e28e222277eddddddddf4f7f4f48ef8e88f1888881182222778f9fffaffb9fff7737777777766666666f9ffbaf3feefffefffffffff00000000
ffff7777282e88e2e222222edddddddd44744f7ff88efef81118111182222228ffffffffbffffff37777777766666666fffffbbfefeeeeeeffffffff00000000
7777ffffe2e22e2ee222222edddddddd7ff7f747efef888e8888118882222228fff9ffffbff9fff37777777766666666fff9ffffeffeeeeeffffffff00000000
7777ffff28228288e222222eddddddddf474f4fff8f8e8f81181888182222228ffff9fffbfff9ff37777777766666666ffff9ffffeeeeeffffffffff00000000
7777ffffe28e2e2e2e2222e2dddddddd4fff7f478e8f8fe81181181128222282faffff9ffbffff3f7777777766666666faffff9feeefeeeeffffffff00000000
7777ffff8e2828e222eeee22dddddddd4744474fe8fe8e8f1811188122888822afffffffafbbbbff7777777766666666afffffffeeffeeeeffffffff00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008888888000011110000088888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110220008888888822010010000000008888223330000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001011222288888888821110010000000000008223333333888800000000000000111110000000011110000000000000000000000000000000000000000
000000110012228888881888111111000000000000008233333338833333000000000001eee100000000eee11000000000000000000555555555555000000000
00000010111228888821111111110000000000000000823bbb8822883333000000000011e2ee00000000eeee1000000000000000555565f66556665550000000
00000111112288888222111111100000000000000000022bbbb22282222330000000001ee2eee0000000ee2e1100000000000055565ff6555566eee655000000
00000111122228882222211111000000000000000000008bbbbbbb22bbb333000000011ee2eee000000eee2ee100000000000556ee5fff66566eee5e65500000
00000111228828882221111111000000000000000000008bbbbbbbbbbbb33300000001eee2eee100001ee12eee1100000005566ee55f55665ee55e655ff50000
00011111288828811111111112000000000000000000008bbbbbbbbbbb8333000000118822222e1001e2e12eeee10000055566e5555655555555555556ff5000
00011111188128888111111222200000000000000000003bbbbbbbbbbb83333000001e822e82ee1001e22e2222e110005556eee5566565eeee55fffffe5f5500
00011111888122288888818122200000000000000000003bbbbbbbbbbb82333000001e82e882ee0000ee222822ee100055f6ee5ff66556e66e6655fffe5fff50
00011118881112222888818111120000000000000000003bbbbbbbbbbb8233300001ee82e882ee0000ee82e882ee11005ff6e65f6e6eee55ee56eefffe566fff
00011228811811112288828222122200000000000000033bbbbbbbbbbb3233300011e82e1282ee0000ee821e82eee1005ff56fff6e5ffe65e6556eeeee5eeee6
0001122281888221828222882212220000000000000003bbbbbbbbbbbb333330001ee2e112822e0000e1821e822ee10055f56f6eee5feee5e66555effff6e5e6
0002111222222221182281882218220000000000000003bbbbbbbbbbb3333330001e82e128e2220000e12e1182eee10055f5efee655f66e6e66e65555ffff5e5
0000228111111128112821882211220000000000000003bbbbbbbbbbb3333330001e22e2288ee20000e12821128ee10056f5e6e555ff55ee556ffffeeeee6655
0000028881288822828821882211220000000000000033bbbbbbbbbb88333330011e211ee28881000011eeee128eee105ef5eee56ff65666566e6ff566555555
000002288828111888812118211220000000000000003bbbbbbbbbb88333333001e221e2ee22810000e2e2ee1e8eee105ef55556ef655656565e56f56eeee655
000002288821881188822812218220000000000000333bbbbbbbb8888333330001e2e1288ee28100001ee1e8811eee105eeeeeee6f555555555e55f5556ee550
000000228122288888222812218220000000000000333bbbbbbb88222333330001e81e281ee281000011e1e8881882105e56e665556eff665fff6ee556655600
00000022211828882211281881820000000033333333bbbbbbb882233333300001ee128ee8e2210000e111e22e112e105e555555655e6ff556eeee5665000000
00000002281821882181228888220000000332bbbbbbbbbbbb8822333333300001eee22ee8e82e0000e112e2e222ee1056555555556eeeff55e6655555000000
00000000281122882181128822200000000382bbbbbbbbbbb82222333333000001ee28eee8e82e0000e112e28ee22e105556fef655555eee6555555555000000
000000002281128218882282220000003333822bbbbbbbbbb82333333330000001e282e122e82e0000ee22ee888eee10066efff55555555ee555555500000000
000000000288118218822882220000003338882bbbbbbbbbb33333333300000001ee8ee128e88e00008eeeee1288ee1000055555555555655000000000000000
000000000288882218221822200000003382222bbbbbbbb3333333333000000001e88e12eeeee8000088eeee11288e1000056655555555565000000000000000
000000000028888888281822000000003382bbbbbbbbb333333333330000000001e8eeeee888880000088888e1112e1000006555566665550000000000000000
000000000022288888881222000000003332bbbbbbbb3333333330000000000001e11ee8800000000000000088e11e1000005556665555660000000000000000
0000000000022288888112200000000033333bbb88883333333000000000000001e1e8880000000000000000088eee1000005666555555500000000000000000
000000000000222881112200000000000033388888223333000000000000000001ee800000000000000000000088ee1000000665555655600000000000000000
000000000000002221222000000000000003332222233300000000000000000001e88000000000000000000000088e1000000065566550000000000000000000
00000000000000002222000000000000000033333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222c1222000000bb00440000000888000009990000eeee0000ffff00000222000008880000000000000000000000000000000000000000000000000000000000
0221c220000000bbb44000000888ff000999aa000e8888e00f22ff4000022200000888000aaaa000000000000000000000000000000000000000000000000000
002112000000000b4400000008fff00009aaa000e88ee882ff2ff2f400220220008808800aa0aa00000000000000000000000000000000000000000000000000
002c1200008888804008880088ff400099aa7000e8e88282ffff42f4022000220880008800000aaa000000000000000000000000000000000000000000000000
00211200000ff8884888888088fff40099aaa700e8e88282f2f44ff40200000208000008000000aa000000000000000000000000000000000000000000000000
002112000000ff888877788808ffffff09aaaaaae8822822fff22f44022000220880008800000aaa000000000000000000000000000000000000000000000000
0021c20000000f8888877788088ff888099aa999028882200f22f44002200022088000880aa0aa00000000000000000000000000000000000000000000000000
002c120000000f88888887820008880000099900002222000044440000000000000000000aaaa000000000000000000000000000000000000000000000000000
002e820088f0ff888888888200000000000000440077770000666600000000000000000000000000000000000000000000000000000000000000000000000000
0028e20088ff88888888882200000000000000440777776006dddd60000000000000000000000000000000000000000000000000000000000000000000000000
0028820088888888888888200000000000000004777777766ddd6d6d000000000000000000000000000000000000000000000000000000000000000000000000
00288200888888888888822000000000000000a9777766766dd66d6d000000000000000000000000000000000000000000000000000000000000000000000000
002e8200088888888888220000000000000000a9777667766dd6dd6d000000000000000000000000000000000000000000000000000000000000000000000000
0028820000888888888820000000000000000a9977767766666666dd000000000000000000000000000000000000000000000000000000000000000000000000
0228e22000088888882220000000000000000a990777766006666dd0000000000000000000000000000000000000000000000000000000000000000000000000
222e82220000088222200000400000000000a9990066660000dddd00000000000000000000000000000000000000000000000000000000000000000000000000
1122110000044000000440009a000000000a99990066660000ffff00000000000000000000000000000000000000000000000000000000000000000000000000
01111000022222500bbbbb3099aa00000aaa9a99066776660feeefe0000000000000000000000000000000000000000000000000000000000000000000000000
0122100022227725bbbb77b3a99aaaaaaaa99a9066727775feeffffe000000000000000000000000000000000000000000000000000000000000000000000000
0111100022222775bbbbb7730a9999999999a99062772275feffeefe000000000000000000000000000000000000000000000000000000000000000000000000
0122100022222225bbbbbbb30a9aaaaaaaaaa99067772275fefeeffe000000000000000000000000000000000000000000000000000000000000000000000000
0111100022222255bbbbbb3300999aaa9999990066727775fffeffee000000000000000000000000000000000000000000000000000000000000000000000000
01221000022225500bbbb3300009999999999000066775550ffffee0000000000000000000000000000000000000000000000000000000000000000000000000
12222100005555000033330000000999990000000055550000eeee00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888228822888222822888888822888888228888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888222822888882282888888222888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888282282888222888888228882888888288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888222222888888222888228882888822288888
8888888888888888888888888888888888888888888888888888888888888888888888888888888888ff888ff888822228888228222888882282888222288888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888ff8ff8888828828888228222888888822888222888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5bbb5bb55bbb55755cc5557555555eee5e5e5eee5ee555555666555555555cc555555eee5ee55ee5555555555555555555555555555555555555555555555555
55b55b5b5b5b575555c55557555555e55e5e5e555e5e555556565575577755c555555e555e5e5e5e555555555555555555555555555555555555555555555555
55b55b5b5bbb575555c55557555555e55eee5ee55e5e555556665777555555c555555ee55e5e5e5e555555555555555555555555555555555555555555555555
55b55b5b5b55575555c55557555555e55e5e5e555e5e555556555575577755c555555e555e5e5e5e555555555555555555555555555555555555555555555555
55b55b5b5b5555755ccc5575555555e55e5e5eee5e5e55555655555555555ccc55555eee5e5e5eee555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55bb55bb557556565575555555555cc555555eee5e5e5eee5ee555555566555555555cc555555eee5eee55555566555555555ccc55555eee5e5e5eee5ee55555
5b5b5b555755565655575777577755c5555555e55e5e5e555e5e555556555575577755c5555555e55e555555565557775777555c555555e55e5e5e555e5e5555
5b5b5bbb5755556555575555555555c5555555e55eee5ee55e5e555556555777555555c5555555e55ee5555556555555555555cc555555e55eee5ee55e5e5555
5b5b555b5755565655575777577755c5555555e55e5e5e555e5e555556555575577755c5555555e55e555555565557775777555c555555e55e5e5e555e5e5555
5bb55bb5557556565575555555555ccc555555e55e5e5eee5e5e55555566555555555ccc55555eee5e5555555566555555555ccc555555e55e5e5eee5e5e5555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee55ee5ee555555656566656665666566655555666565556665666566655665666566655665575557555555555555555555555555555555555555555555555
55e55e5e5e5e55555656565556565656556555555656565556565565565556565656566656555755555755555555555555555555555555555555555555555555
55e55e5e5e5e55555666566556665665556555555666565556665565566556565665565656665755555755555555555555555555555555555555555555555555
55e55e5e5e5e55555656565556565656556555555655565556565565565556565656565655565755555755555555555555555555555555555555555555555555
5eee5ee55e5e55555656566656565656556556665655566656565565565556655656565656655575557555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
566655555666566555555666565556555575566656555666566656665566566656665566557555555ee555ee5555555555555555555555555555555555555555
565655555565565655555656565556555755565656555656556556555656565656665655555755555e5e5e5e5555155555555555555555555555555555555555
566655555565565655555666565556555755566656555666556556655656566556565666555755555e5e5e5e5551715555555555555555555555555555555555
565555555565565655555656565556555755565556555656556556555656565656565556555755555e5e5e5e5551771555555555555555555555555555555555
565555555666565655555656566656665575565556665656556556555665565656565665557555555eee5ee55551777155555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555551777715555555555555555555555555555555
557556665555566555575ccc555555ee5eee555556665555566557555ccc557555555eee5ee55ee555555566555177115cc555555eee5e5e5eee5ee555555666
57555656555556565575555c55555e5e5e5e555556565555565655755c55555755555e5e5e5e5e5e555556555777117155c5555555e55e5e5e555e5e55555656
575556665555565657555ccc55555e5e5ee5555556665555565655575ccc555755555eee5e5e5e5e555556555555555555c5555555e55eee5ee55e5e55555666
575556555555565655755c5555555e5e5e5e55555655555556565575555c555755555e5e5e5e5e5e555556555777577755c5555555e55e5e5e555e5e55555655
557556555575565655575ccc55555ee55e5e555556555575565657555ccc557555555e5e5e5e5eee55555566555555555ccc555555e55e5e5eee5e5e55555655
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555558888
5eee5eee5eee55555575566655555665575555555ccc555555ee5eee5555566655555665555755555ccc557555555eee5ee55ee555555566555555555ccc8888
5e5555e55e555555575556565555565655755777555c55555e5e5e5e5555565655555656557557775c55555755555e5e5e5e5e5e5555565557775777555c8888
5ee555e55ee555555755566655555656555755555ccc55555e5e5ee55555566655555656575555555ccc555755555eee5e5e5e5e55555655555555555ccc8888
5e5555e55e5555555755565555555656557557775c5555555e5e5e5e555556555555565655755777555c555755555e5e5e5e5e5e55555655577757775c558888
5eee5eee5e5555555575565555755656575555555ccc55555ee55e5e5555565555755656555755555ccc557555555e5e5e5e5eee55555566555555555ccc8888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee55ee5ee555555555566556665666565655755575555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55e55e5e5e5e55555555565656565656565657555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55e55e5e5e5e55555555565656655666565657555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55e55e5e5e5e55555555565656565656566657555557555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee5ee55e5e55555666566656565656566655755575555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55575555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55755555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5ccc55555ccc55555ccc55555ccc55555cc55c5555555cc55c555575555555555555555555555555555555555555555555555555555555555555555555555555
5c5c55555c5c55555c5c55555c5c555555c55c55555555c55c555557555555555555555555555555555555555555555555555555555555555555555555555555
5c5c55555c5c55555c5c55555c5c555555c55ccc555555c55ccc5557555555555555555555555555555555555555555555555555555555555555555555555555
5c5c55755c5c55755c5c55755c5c557555c55c5c557555c55c5c5557555555555555555555555555555555555555555555555555555555555555555555555555
5ccc57555ccc57555ccc57555ccc57555ccc5ccc57555ccc5ccc5575555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555666565556665666566655665666566655665575557555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555656565556565565565556565656566656555755555755555555555555555555555555555555555555555555555555555555555555555555555555555555
55555666565556665565566556565665565656665755555755555555555555555555555555555555555555555555555555555555555555555555555555555555
55555655565556565565565556565656565655565755555755555555555555555555555555555555555555555555555555555555555555555555555555555555
56665655566656565565565556655656565656655575557555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5eee55ee5ee555555665566656665656555556665655566656665666556656665666556655755575555555555555555555555555555555555555555555555555
55e55e5e5e5e55555656565656565656555556565655565655655655565656565666565557555557555555555555555555555555555555555555555555555555
55e55e5e5e5e55555656566556665656555556665655566655655665565656655656566657555557555555555555555555555555555555555555555555555555
55e55e5e5e5e55555656565656565666555556555655565655655655565656565656555657555557555555555555555555555555555555555555555555555555
5eee5ee55e5e55555666565656565666566656555666565655655655566556565656566555755575555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
566655555666566555555666565556555575566656555666566656665566566656665566557555555ee555ee5555555555555555555555555555555555555555
565655555565565655555656565556555755565656555656556556555656565656665655555755555e5e5e5e5555555555555555555555555555555555555555
566655555565565655555666565556555755566656555666556556655656566556565666555755555e5e5e5e5555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828282288882822282228888888888888888888888888888888888888888888888888888888222822882228882822282288222822288
82888828828282888888828288288828828882888888888888888888888888888888888888888888888888888888888882882882888828828288288282888288
82888828828282288888822288288828822282228888888888888888888888888888888888888888888888888888888222882882228828822288288222822288
82888828828282888888888288288828888288828888888888888888888888888888888888888888888888888888888288882888828828828288288882828888
82228222828282228888888282228288822282228888888888888888888888888888888888888888888888888888888222822282228288822282228882822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100010101011010000010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2929292929292929292929292929292940404040404040404040404040404040414141414141414141414141414141414d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343414141434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040414141434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040434343434343434343434343434343434d4d4d4849484c4d4d4d4d484c484d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040414141414141414141414141414141414d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292940404040404040404040404040404040414141414141414141414141414141414d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a41414a4a4a4a4a4a4a4a4a4a41414a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a46474646464a4a47474646464a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4a4a46464746474a4a46464746474a4a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000001070090700107022000250002800012000120001200011000110001000011000110001200010000100000f0000f0000e000000000000000000000000000000000000000000000000000000000000000
0114000009554095540c55410550095540c5540f5541055011554115540c554155501c5541555417554155500755407554175540c5500b5540e554115540e550145541455410554175500e5540f5541055414550
011400000705307053186750700307053070531867507003070530705318675070030705307053186750700307053070531867507003070530705318675070030705307053186750705307003070531867507053
01140000105002150518570185701b5721b57218570185701d5701d5701c5721c572185701857015570155701755017550175521755217552175520000000000095500c55000000000001b5521c5521855221552
011400000915000000000000410009150001000010004100051500010000100041000515000100001000410007150001000010002100071500010000100041000215000100001000210004150001000010004100
01140000105002150518570185701b5701b57018570185702157021570205701c570205701c5701a570185701a5501a5501a5501a5501a5501a550186050700315551155510f551105511b5521c5521855221552
011400000c5540c5540f554105500c5540c5540b5540c5500e5540e5540c55415550115540e5540e5540c5500755407554175540c5500b5540e554115540e550145541455410554175500e5540f5541055414550
01140000105002150518570185701c5721c57218570185701d5721d5721c5701a57018570155721157015500175001750017570175701a5701a5701d5701d5701057014570170501a0501c5521b5521a55218552
011400000c1500c0000c000101000c1500c1000c100101000e1500c1000c100101000e1500010000100041000b1500010000100021000e150001000010004100081500010000100021000b150001000010004100
01140000105002150518570185701b5721b57218570185701d5701d5701c5721c57218570185701a5701a5701355013550135521355213552135520000000000095500c55000000000001a5521b5521c55220552
011400000705307053186750700307053070531867507003070530705318675070030705307053186750700307053070531867507003070530705318675070031867507003186050700307003070031860507053
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01020304
00 01020504
00 06020708
02 010a0904
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

