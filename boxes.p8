pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
------------------------------
-- misc. functions
------------------------------

--plays track depending on boss and state
function music_player(id,state)
 --no music in first phase
 if state==0 then music(-1) end
 --start when aggravated
 if state==1 then
  if id==1 then music(0)
  elseif id==2 then music(4)
  elseif id==3 then music(8)
  elseif id==4 then music(18) end
 end
 --explosion sounds
 if state==4 then music(14) end
end

function cameffects(dur)
 local st=time()
 if game.screenshake>0 then
  game.camx,game.camy=rnd(2)-1,rnd(2)-1
  game.screenshake-=1
 else
  game.camx,game.camy=0,0
 end
 camera(game.camx,game.camy)
end

--prints some string (q) based on how long
--you want a row and where you start printing
--in a color
function print_quote(q,width,startx,starty,col)
 local length=#q/width
 --every row
 for i=0,length do
  print(sub(q,i*width,(i+1)*width-1),startx,i*8+starty,col)
 end
end

--change map
function set_area(x,y)
 for i=0,15 do
  for j=0,15 do
   mset(i,j,mget(i+x,j+y))
  end
 end
end

--[[
class system code
vector code
box code *minus the extend function*
taken from dank tombs cart, author = krajzeg
]]

------------------------------
-- class system
------------------------------

-- creates a "class" object
-- with support for basic
-- inheritance/initialization
function kind(kob)
 kob=kob or {}
 setmetatable(kob,{__index=kob.extends})

 kob.new=function(self,ob)
  ob=set(ob,{kind=kob})
  setmetatable(ob,{__index=kob})
  if (kob.create) ob:create()
  return ob
 end

 return kob
end

--------------------
-- class functions -
--------------------

-- copies props to obj
-- if obj is nil, a new
-- object will be created,
-- so set(nil,{...}) copies
-- the object
function set(obj,props)
 obj=obj or {}
 for k,v in pairs(props) do
  obj[k]=v
 end
 return obj
end

-- used for callbacks into
-- entities that might or
-- might not have a method
-- to handle an event
function event(ob,name,...)
 local cb=ob[name]
 return type(cb)=="function"
  and cb(ob,...)
  or cb
end

-- returns smallest element
-- of seq, according to key
-- function
function min_of(seq,key)
 local me,mk=nil,32767
 for e in all(seq) do
  local k=key(e)
  if k<mk then
   me,mk=e,k
  end
 end
 return me
end

-------------------------------
-- boxes
-------------------------------

-- a box is just a rectangle
-- with some helper methods
box=kind()
 function box:translate(v)
  return make_box(
   self.xl+v.x,self.yt+v.y,
   self.xr+v.x,self.yb+v.y
  )
 end

 function box:overlaps(b)
  return
   self.xr>=b.xl and
   b.xr>=self.xl and
   self.yb>=b.yt and
   b.yb>=self.yt
 end

 function box:contains(pt)
  return pt.x>=self.xl and
   pt.y>=self.yt and
   pt.x<=self.xr and
   pt.y<=self.yb
 end

 --direction and value, 1 == left, 2 == right, 3 == up, 4 == down
 function box:extend(d, val)
  if d==1 then return make_box(self.xl-val, self.yt, self.xr, self.yb) end
  if d==2 then return make_box(self.xl, self.yt, self.xr+val, self.yb) end
  if d==3 then return make_box(self.xl, self.yt-val, self.xr, self.yb) end
  if d==4 then return make_box(self.xl, self.yt, self.xr, self.yb+val) end
 end

 function box:flr()
  local v1=v(flr(self.xl), flr(self.yt))
  local v2=v(flr(self.xr), flr(self.yb))
  return vec_box(v1, v2)
 end

--[[ function box:sepv(b)
  local candidates={
   v(b.xl-self.xr-1,0),
   v(b.xr-self.xl+1,0),
   v(0,b.yt-self.yb-1),
   v(0,b.yb-self.yt+1)
  }
  return min_of(candidates,vec.__len)
 end]]

function make_box(xl,yt,xr,yb)
 if (xl>xr) xl,xr=xr,xl
 if (yt>yb) yt,yb=yb,yt
 return box:new({
  xl=xl,yt=yt,xr=xr,yb=yb
 })
end

function vec_box(v1,v2)
 return make_box(
  v1.x,v1.y,
  v2.x,v2.y
 )
end

-------------------------------
-- vectors
-------------------------------

-- for some stuff, we want
-- vector math - so we make
-- a vector type with all the
-- usual operations
vec={}
function vec.__add(v1,v2)
 return v(v1.x+v2.x,v1.y+v2.y)
end
function vec.__sub(v1,v2)
 return v(v1.x-v2.x,v1.y-v2.y)
end
function vec.__mul(v1,a)
 return v(v1.x*a,v1.y*a)
end
function vec.__mul(v1,a)
 return v(v1.x*a,v1.y*a)
end
function vec.__div(v1,a)
 return v(v1.x/a,v1.y/a)
end
-- we use the ^ operator
-- to mean dot product
function vec.__pow(v1,v2)
 return v1.x*v2.x+v1.y*v2.y
end
function vec.__unm(v1)
 return v(-v1.x,-v1.y)
end
-- this is not really the
-- length of the vector,
-- but length squared -
-- easier to calculate,
-- and can be used for most
-- of the same stuff
function vec.__len(v1)
 local x,y=v1:split()
 return x*x+y*y
end
-- normalized vector
function vec:norm()
 return self/sqrt(#self)
end
-- rotated 90-deg clockwise
function vec:rotcw()
 return v(-self.y,self.x)
end
-- force coordinates to
-- integers
function vec:ints()
 return v(flr(self.x),flr(self.y))
end
-- used for destructuring,
-- i.e.:  x,y=v:split()
function vec:split()
 return self.x,self.y
end
-- has to be there so
-- our metatable works
-- for both operators
-- and methods
vec.__index = vec

-- creates a new vector
function v(x,y)
 local vector={x=x,y=y}
 setmetatable(vector,vec)
 return vector
end

-- vector for each cardinal
-- direction, ordered the
-- same way pico-8 d-pad is
dirs={
 v(-1,0),v(1,0),
 v(0,-1),v(0,1)
}

-----------------------------
-- game
-----------------------------
curr_game=kind()
function curr_game:update_game(state)
 --overworld/boss
 if state<2 then
  return function()
   update_players()
   update_boss()
  end
 --transition
 elseif state==2 then
  return function()
   if btnp(5) then init_boss() end
  end
 --game over
 elseif state==3 then
  return function()
   if btnp(5) then _init() end
  end
 --menu
 elseif state==4 then
  return function()
   update_menu()
  end
 end
end

-----------------------------
-- boss hit boxes
-----------------------------
boss_hit_boxes={
 { --heart
  {88,8,96,64},
  {112,8,120,64},
  {88,64,96,111},
  {112,64,120,111},
  {80, 40, 124, 88}
 },
 { --stomach
  {77, 48, 127, 97},
  {90, 5, 112, 48},
  {75, 96, 95, 127}
 },
 { --lungs
  {30, 50, 58, 96},
  {66, 50, 94, 96},
  {54, 8, 75, 80}
 },
 { --brain
  {40, 40, 86, 76}
 },
 { -- overworld
  {40, 79, 72, 111}, -- pox_box
  {88, 79, 120, 111} -- next_boss
 }
}
------------------------------
-- boss health boxes
------------------------------
boss_health_boxes={
 {20,20,20,20}, --heart
 {70}, --stomach
 {80,80}, --lungs
 {100}, --brain
 {}--overworld
}

------------------------------
-- boss anim box sprites
------------------------------
-- length must amtch number of anim boxes
-- maps sprite numbers to boxes
boss_anim_sprites={
 {192,192,208,208,128}, --heart
 {132,241,241}, --stomach
 {136,138,224}, --lungs
 {140}, --brain
 {204, 140} --overworld
}

boss_anim_size_vecs={
 {v(8,8), v(8,8), v(8,8), v(8,8), v(32,32)},
 {v(32,32), v(8,8), v(8,8)},
 {v(16, 32), v(16, 32), v(8, 8)},
 {v(32, 32)},
 {v(32,32), v(32,32)}
}

-----------------------------
-- boss face_points
-----------------------------

boss_eye_points={
 {88, 56, 4, 12, 2, 8}, --heart
 {92, 56, 4, 12, 3, 11}, --stomach
 {46, 62, 6, 31, 14, 8}, --lungs
 {46,62,6,31,14,8}, --brain
}

boss_lip_points={
 {91, 72, 16, 1, 5},
 {91, 72, 16, 1, 5},
 {51, 75, 21, 1, 14},
 {51,75,21,1,14}
}

------------------------------
-- boss hurt boxes
------------------------------
boss_hurt_boxes={
 { --heart
   --none
 },
 { --stomach
   {0,120,127,127}
 },
 { --lungs
   {24,120,104,128}
 },
 { --brain
   {0,120,127,127}
 },
 { --overworld
   --none
 }
}

------------------------------
-- boss rooms
------------------------------
boss_rooms={
 { --heart
  {0, 112, 127, 127}, --flr boss_rooms[1][1][1-4]
  {0, 80, 24, 87}, --plt 1 boss_rooms[1][2]
  {48, 40, 72, 47} --plt 2 boss_rooms[1][3]
  },
 { --stomach
  {0, 104, 24, 120}, --fruit 1
  {48, 104, 72, 120}, --fruit 2
  {96, 104, 112, 120} --fruit 3
  },
 { --lungs
  {0, 112, 24, 127}, --left flr
  {100, 112, 127, 127}, --right flr
  {10, 64, 26, 72}, --vert plt left --up
  {98, 64, 114, 72}, --vert plt right --down
  {56, 112, 72, 120}, --horiz plt bot --left
  {56, 28, 72, 36} --horiz plt top --right
  },
 { --brain
  {20,30,40,34}, --lplat1
  {10,60,30,64}, --lplat2
  {20,90,40,94}, --lplat3
  {88,30,108,34}, --rplat1
  {98,60,118,64}, --rplat2
  {88,90,108,94}, --rplat3
 },
 { --overworld
  {0, 112, 127, 127}
 }
}

------------------------------
-- pox box options stuff
------------------------------

pox_option={"sold","health","damage","length", "charge"}
pox_option_sprites={23,198,197,230,229}
pox_option_cost={0,1,3,2,2}

------------------------------
-- init calls
------------------------------

function _init()
 cls()
 music(-1)
 lbx,lby,mode=0,0,0
 --state: 0=overworld, 1=boss, 2=transition, 3=gameover, 4=menu
 game={shopping=false, ready_count=0,frame_counter=0, state=4, next_boss=5, b_remaining={1,2,3}, b_faught={}, difficulty=1, menu=0, menuchoice=0, scores={}, activescores={}, screenshake=0, camx=0, camy=0,particles={}}
 quotes={"there is nothing so patient, in this world or any other, as a virus searching for a host","it's in the misery of some unnamed slum that the next killer virus will emerge.","when there are too many deer in the forest or too many cats in the barn, nature restores the balance by the introduction of a communicable disease or virus.","the average adult heart beats 72 times a minute; 100,000 times a day; 3,600,000 times a year; and 2.5 billion times during a lifetime.","every day, the heart creates enough energy to drive a truck 20 miles. in a lifetime, that is equivalent to driving to the moon and back.","the stomach serves as a first line of defense for your immune system. it contains hydrochloric acid, which helps to kill off bacteria and viruses that may enter with the food you eat.","try interacting with pox box at the overworld, he may have something for you.","when fighting the heart, aim for the valves attached to it.","scarlet fever and commander cold have different abilities. commander cold stops bullets in their tracks while scarlet fever moves faster.","when fighting the lungs, be careful as they will try to blow you in all sorts of directions.","when fighting the stomach, try to avoid the stomach acid.","every player has two jumps. use them wisely!","if you see smoke while fighting the lungs, find a safe area to wait until it clears up."}
 players={}
 game.update=curr_game:update_game(game.state)
 init_area(0)
end

function init_player(num)
 return {
  n=num,
  ready=false,
  hp=3,
  hit_cooldown=0,
  pos_vec=v(0,104),
  size_vec=v(6,7),
  hit_box=make_box(0,104,6,111),
  d_vec=v(0,0),
  state=0, -- (0=grounded, 1=airbound, 2=dodging)
  d=1, -- (1=left, 2=right)
  h=0,
  jumped=0, --(-0=grounded,-2 jumps)
  jump_time=0, --used to determine when jump should end
  dodge_time=0,
  dodge_meter=100,
  attack_state=0,
  attack_box=make_box(0,0,0,0),
  mutation_tokens=3,
  shopping=false,
  shop_option=1,
  menuselect=1
 }
end

function scoreboard()
 thisboard={
  bossid=boss.id,
  lasttime=time(),
  timer=0,
  total=0,
  hitstaken=0,
  hitsgiven=0
 }
 return thisboard
end

function init_boss()
 local n=game.next_boss
 boss={id=n, timer=180,attack_counter=1,counter=0, health_boxes={},hp=200,hit_cooldown=0,state=0,hit_boxes={}, col_boxes={}, hurt_boxes={}, bullets={}, attacks={},spawn=time(),d=0,pox_box_options={}}
 -- n=1 for heart
 -- n=2 for stomach
 -- n=3 for lungs
 -- n=4 for brain
 -- n=5 for overworld

 --1. init hit_boxes
 init_boss_boxes(boss.hit_boxes, boss_hit_boxes[n])
 --2. init col_boxes
 add(boss.col_boxes, make_box(0, 0, 127, 3)) -- every boss has a cieling right?
 init_boss_boxes(boss.col_boxes, boss_rooms[n])
 --3. init hurt_boxes
 init_boss_boxes(boss.hurt_boxes, boss_hurt_boxes[n])
 --3. init hp
 init_boss_health(boss.health_boxes,boss_health_boxes[n])
 boss.max_hp=80
 if n==2 then boss.max_hp=70 elseif n==4 then boss.max_hp=100 end

 --4. game_state and overworld check
 if n==5 then game.state=0
  init_pox_box_options() -- get new options in overworld
  local r=#game.b_remaining
  music(16)
  if r>0 then game.next_boss=game.b_remaining[flr(rnd(r))+1] del(game.b_remaining, game.next_boss)
  else game.next_boss=4 end
  add(game.b_faught, game.next_boss)
 else game.state=1 game.next_boss=5 end
 --4,5 scires and stuff
 for p in all(players) do
  p.ready=false
  p.shopping=false
  p.state=1
  p.hit_box=make_box(0,104,6,111)
  game.activescores[p.n]=scoreboard()
  if game.next_boss==5 then p.mutation_tokens+=3 end --give players 3 tokens
 end

 --5. init boss functions
 boss = curr_boss:new(boss)
 boss.funcs=init_boss_functions(n)
 --6 init boss attacks
 boss.attacks=init_boss_attacks(n,0)

 --7 set map area
 init_area(n)

 --8 set game start
 game.update=curr_game:update_game(game.state)
end

function init_pox_box_options()
 local current_options={}
 for i=1,3 do add(current_options, flr(rnd(#pox_option-1))+2) end
 boss.pox_box_options=current_options
end

function init_boss_functions(n)
 return { -- controls functions boss has access to
  curr_boss:platform_movement(n),
  curr_boss:boss_logic(n),
  curr_boss:update_health(),
  curr_boss:update_bullets(),
  curr_boss:death_condition(n)
 }
end

function init_boss_health(to_table,from_table)
 for i=1,#from_table do
  local cur_box=from_table[i]
  add(to_table, cur_box)
 end
end

function init_boss_boxes(to_table, from_table)
 for i=1,#from_table do
  local cur_box=from_table[i]
  add(to_table, make_box(cur_box[1], cur_box[2], cur_box[3], cur_box[4]))
 end
end

function init_boss_attacks(id,state)
 --heart
 if id==1 and state==0 then
  return {clot_attack,vb,valve_burst}
 elseif id==1 and state==2 then
  return {clot_attack,vb,valve_burst,mini_heart}

 --stomach
 elseif id==2 and state==0 then
  return {throw_item,wave,spawn_enzyme}

 --lungs
 elseif id==3 and state==0 then
  return {spawn_debris,change_direction}
 elseif id==3 and state==2 then
  return {spawn_debris,change_direction,safespace,hurt_space}

 --brain
 elseif id==4 and state==0 then
  return {throw_item,bouncing_lightning,smart_shot,shockspace,shock_space}

 --overworld
 else
  return {}
 end
end

function init_area(id)
 --heart
 if id==0 then
   lbx,lby=128,0
 elseif id==1 then
  lbx,lby=256,0
 --stomach
 elseif id==2 then
  lbx,lby=384,0
 --lungs
 elseif id==3 then
  lbx,lby=0,128
 --brain
 elseif id==4 then
  lbx,lby=512,0
 --overworld
 elseif id==5 then
  lbx,lby=256,128
 --transition
 elseif id==6 then
  lbx,lby=384,128
end
 set_area(lbx/8,lby/8)
end
------------------------------
-- transition functions
------------------------------
function init_transition()
 music(-1)
 game.update=curr_game:update_game(2)
 lbx,lby=0,0
 init_area(6)
 random_quote=quotes[flr(rnd(#quotes))+1]
 game.state=2
 ttk=time()
end

function draw_transition()
 print_quote(random_quote,30,0,1,9)
 print("press x to continue",48,120,7)
 for i=1,4 do
  local x=i*24
  circfill(4+x,96,8,7) --draw white circle in background
  if i<4 then line(13+x,96,19+x,96,7) end
  if i>#game.b_faught then print("?", 3+x, 94, 2) end --draw sprite here
  if i<#game.b_faught then sspr(56, 8, 8, 8, x-4, 89, 16,16) end
  if game.b_faught[i] then spr(game.b_faught[i]+23, x, 92) end
 end
end
-----------------------------
-- menu functions
------------------------------
function update_menu()
 --main
 if game.menu==0 or game.menu==2 then
  if btn(2) then
   game.menuchoice=0
  elseif btn(3) then
   game.menuchoice=1
  end
 end
 if game.menu==0 then
  if btnp(5) then
   add(players,init_player(0))
   if game.menuchoice>0 then add(players,init_player(1)) end
   players[1].menuselect=0
   game.menu=2
  end
  instructions = false
  if btn(4) then --hold it
    instructions = true
    --draw instructions window
  end
 elseif game.menu==2 then
  if  btnp(5) then
   if game.menuchoice==0 then game.difficulty=0 else game.difficulty=1 end
   game.ready_count=0
   game.state=2
   game.update=curr_game:update_game(game.state)
   init_transition()
  end
 end
end
------------------------------
-- boss functions
------------------------------
curr_boss=kind()

function update_boss()
 if boss.hit_cooldown>0 then boss.hit_cooldown-=1 end
 local s=boss.state
 for f in all(boss.funcs) do f() end
 --if boss is active, do attacks
 boss.counter+=1
 if boss.counter>boss.timer then boss.counter=0 boss.attack_counter+=1 end
 if s>0 and boss.counter==0 and boss.id!=5 then --do attacks here
  boss.attacks[boss.attack_counter]()
 end
 if boss.attack_counter==#boss.attacks then boss.attack_counter=0 end
 --if change in boss state
 if s~=boss.state then music_player(boss.id,boss.state) end
end

function curr_boss:update_health()
 return function()
  local count=0
  for i=1,#(boss.health_boxes) do
   count+=boss.health_boxes[i]
  end
  boss.hp=count
  if boss.id==3 then boss.hp=count/2 end
 end
end

function curr_boss:platform_movement(id)
 local col_boxes=boss.col_boxes
 if id==2 then
  local plats={col_boxes[2], col_boxes[3], col_boxes[4]}
  return function() -- return stomach movement
   for i=1, #plats do
    local p=plats[i]
    local move_vec=v(-.25,0)
    p=p:translate(move_vec)
    if p.xr<0 then p=p:translate(v(128,0)) end
    moving_plat_collision(p, move_vec)
    plats[i]=p
    boss.col_boxes[i+1]=p
   end
  end
 end
 if id==3 then --return lung movement
  local plats={col_boxes[4], col_boxes[5], col_boxes[6], col_boxes[7]}
  local plat_vecs={v(0,-1), v(0,1), v(-1,0), v(1,0)}
  return function()
   local s=2 -- suggested stat - could slow down - speed
   for i=1, #plats do
     local p=plats[i]
     local vec=plat_vecs[i]
     local xl,yt=p.xl,p.yt
     if xl==8 then vec=v(0,-1) end
     if xl==100 then vec=v(0,1) end
     if yt==28 and xl<98 then vec=v(1,0) end
     if yt==112 and xl>10 then vec=v(-1,0) end
     plats[i]=p:translate(vec/s) -- speed used here --update local table here for player plat collision
     plat_vecs[i]=vec
     --player col with moving plats
     moving_plat_collision(plats[i],vec/s)
     boss.col_boxes[i+3]=plats[i] --update boss table here
   end
  end
 end
end

function curr_boss:death_condition(id)
 if id==5 then
  return function()
   game.ready_count=0
   for p in all(players) do if p.ready==true then game.ready_count+=1 end end
   if game.ready_count==#players then init_transition() end
  end
 else
  return function() if boss.hp==0 then init_transition() end end
 end
end

function curr_boss:boss_logic(id)
 local s=boss.state
 --heart
 if id==1 then
  return function()
   local count=0
   s=0
   for i=1,#boss.health_boxes do
    local v=boss.health_boxes[i]
    count+=1
    if v<20 then s=1 end
    if v==0 then count-=1 end
   end
   --check valves
   if count<3 then s=2 boss.timer=150  boss.attacks=init_boss_attacks(id,2) end
   boss.state=s
  end
 --stomach
 elseif id==2 then
  return function()
   if hpcheck(70) then s=0 end
   if hpcheck(69) then s=1 end
   if hpcheck(40) then s=2 boss.timer=120 end
   --wave movement
   --can be reworked
   if boss.wave then
    if boss.wave.hbox then
     local w=boss.wave.hbox
     local timer=time()-boss.wave.spawn_time
     if timer<=2 then w=w:extend(3,.6) end
     if timer>2 then w=w:extend(3,-.3) end
     if timer>5 then boss.wave={}
     else boss.wave.hbox=w
     end
    end
   end
   boss.state=s
  end
 --lungs
 elseif id==3 then
  return function()
   if hpcheck(80) then s=0 end
   if hpcheck(79) then s=1 end
   if hpcheck(40) then s=2 boss.timer=180  boss.attacks=init_boss_attacks(id,2) end
   boss.state=s
   if s>0 then
    for p in all(players) do
     local move=v(-.1,0)
     if boss.d==1 then move=v(.1,0) end
     p.hit_box=p.hit_box:translate(move)
    end
   end
   for b in all(boss.bullets) do
    b.t=boss.d
   end
  end
 --brain
 elseif id==4 then
  return function()
   if hpcheck(100) then s=0 end
   if hpcheck(99) then s=1 end
   if hpcheck(50) then s=2 end
   if hpcheck(20) then s=3 end
   boss.state=s
  end
 end
end

function curr_boss:update_bullets()
 return function()
  for b in all(boss.bullets) do
   local spd=b.spd
   local d=b.t
   local x=0
   local y=0
   local hbox=b.hbox
   --8 directions
   if d==0 then
    x=-spd
   elseif d==1 then
    x+=spd
   elseif d==2 then
    y-=spd
   elseif d==3 then
    y+=spd
   elseif d==4 then
    x-=spd
    y-=spd
   elseif d==5 then
    x-=spd
    y+=spd
   elseif d==6 then
    x+=spd
    y-=spd
   elseif d==7 then
    x+=spd
    y+=spd

   --special bullets
   --mini heart
   elseif d==10 then
    x-=spd
    y+=1.5*cos(.5*time())

   --thrown food
   elseif d==11 then
    x-=spd*cos(b.ang)
    y+=spd*sin(-b.ang)

   --enzymes
   elseif d==20 then
    if b.state==0 then
     x-=1
     for p in all(players) do
      if hbox.xl<p.hit_box.xr+6 then b.state=1 end
     end
    --if same axis as a player, attack
    elseif b.state==1 then y+=1 end

   elseif d==21 then
    --move along vertically
    if b.state==0 then
     y+=1
     for p in all(players) do
      if  hbox.yb>p.hit_box.yt-6 then b.state=1 end
     end
    --if on same axis as player
    elseif b.state==1 then x-=1 end

   --smart bullets
   elseif d==42 then
    if hbox.yt<b.target.hit_box.yt then y+=.2 else y-=.2 end
    if hbox.xl<b.target.hit_box.xl then x+=.3 else x-=.3 end
   end

   if d~=41 then
    b.hbox=hbox:translate(v(x,y))
   else
    b.hbox=hbox:translate(b.d_vec)
   end

   --wall collision
   if box_collide(b.hbox,boss.col_boxes) then
    --bouncing bullets
    if d==41 then
     b.bounce+=1
     if b.bounce<3 then
       b.d_vec.y=-b.d_vec.y
     else
      del(boss.bullets,b)
     end
    else
     del(boss.bullets,b)
    end
   end
   --out of bounds
   if hbox.xl<0 or hbox.xr>127 or hbox.yt<0 or hbox.yb>127 then
    del(boss.bullets,b)
   end
  end
 end
end

--checks if boss's hp is <= n
function hpcheck(n)
 if boss.hp<=n then return true end
end

------------------------------
-- attack functions
------------------------------
--makes a bullet with an angle
function targeted_attack(bt,tx,ty,sx,sy,o,sprite)
 local b=make_bullet(bt,sx,sy,sx+6,sy+6,sprite)
 local offset=o or 0
 b.ang=atan2(sx-tx+offset,sy-ty)
 return b
end

--make a bullet given a startx, starty, length(dx), height(dy), and type(d)
function make_bullet(t,sx,sy,dx,dy,sprite)
 local dx=dx or sx+6
 local dy=dy or sy+6
 local b={
  hbox=make_box(sx,sy,dx,dy),
  t=t,
  spd=1,
  sprite=sprite or 39
 }
 return b
end

--throw items at a player
function throw_item()
 local sx,sy,sprite=105,72,48
 if boss.id==4 then sx,sy=64,64 end
 local t=flr(rnd(#players))+1
 local target=players[t]
 local offset=flr(rnd(15)) - flr(rnd(15))
 local b=targeted_attack(11,target.hit_box.xl,target.hit_box.yt,sx,sy,offset,sprite)
 if boss.id==4 then b.spd=2 end
 add(boss.bullets,b)
end

--stomach attacks

--spawns one of two enzymes
function spawn_enzyme()
 local i=flr(rnd(2))+20
 local x=112
 local y=16
 local e=make_bullet(i,x,y,x+6,y+6,179+i)
 e.spawn=time()
 e.state=0
 add(boss.bullets,e)
end

--spawn a wave
function wave()
 --which pit to spawn from
 local side=flr(rnd(2))
 local x=32
 local y=120
 if side==1 then x=80 end
 local w={hbox=make_box(x,y,x+8,y+1),
 spawn_time=time()}
 boss.wave=w
end

--lung attacks

--spawns debris on the sides of the map
function spawn_debris()
 for i=0,4 do
	 local x=1+rnd(4)
	 local y=rnd(68)+36
	 if boss.d==0 then x=120-rnd(4) end
	 local c=make_bullet(boss.d,x,y)
	 c.spd=.2
	 add(boss.bullets,c)
	end
end

--changes the direction of bullets on the map
function change_direction()
 local direction=boss.d
 if direction==0 then direction=1
 else direction=0
 end
 boss.d=direction
end

--spawns one of two safe spaces
function safespace()
 local id=flr(rnd(2))
 local s=make_box(0,0,108,127)
 if id>0 then
  s=make_box(24,0,127,127)
 end
 boss.safe_space=s
end

--damages anybody not in a safe space
function hurt_space()
 if boss.safe_space then
  for p in all(players) do
    if box_collide(boss.safe_space,{p.hit_box})==false then
     p.hp-=1
     game.screenshake=7
     game.activescores[p.n].hitstaken+=1
    end
  end
 end
 boss.safe_space=nil
end

--heart attacks

--rain bullets from ceiling
function clot_attack()
 local side=flr(rnd(2))
 for i=0,64,4 do
  local x=i
  local y=10
  if side==1 then x+=64 end
  local t=rnd(5)
  if t<3 then add(boss.bullets,make_bullet(3,x,y)) end
 end
end

--determines what random valve
--bursts
function vb()
 local selector=flr(rnd(#boss.hit_boxes))+1
 while boss.health_boxes[selector]==0 do
  selector=flr(rnd(#boss.hit_boxes))+1
 end
 boss.av=boss.hit_boxes[selector]
end

--shoot a burst of bullets out
--of the active valve
function valve_burst()
 if boss.av then
  local v=boss.av
  --make 8 bullets, 4 diagonals 4 straight
  for i=0,7 do
   local b=make_bullet(i,v.xl,v.yt)
   local seed=flr(rnd(32))
   b.hbox.yt+=seed
   b.hbox.yb+=seed
   add(boss.bullets,b)
  end
  boss.av=nil
 end
end

--shoot some mini hearts across the screen
function mini_heart()
 for i=0,4 do
  local y=flr(rnd(104))+8
  add(boss.bullets,make_bullet(10,120,y,126,y+6,40))
 end
end
function shockspace()
 local id=boss.col_boxes[flr(rnd(#boss.col_boxes-2))+2]
 local s=make_box(id.xl-5,id.yt-5,id.xr+5,id.yb+5)

	boss.shock_space=s
end

function shock_space()
 if boss.shock_space then
  for p in all(players) do
   if box_collide(boss.shock_space,{p.hit_box}) then
    p.hp-=1
   end
  end
 end
 boss.shock_space=nil
end

-- make a lightning attack that bounces around
function bouncing_lightning()
 for i=0,4 do
 	local b=make_bullet(41,64,64)
	 b.bounce=0
	 local tx=rnd(127)
	 local ty=rnd(127)
	 local ang=atan2(64-tx,64-ty)
	 b.d_vec=v(cos(ang),sin(ang))
	 add(boss.bullets,b)
 end
end

function smart_shot()
 for i=0,2 do
  local x=rnd(8)+60
  local y=rnd(8)+60
  local b=make_bullet(42,x,y,x+2,y+2)
  b.target=players[flr(rnd(#players))+1]
  add(boss.bullets,b)
 end
end

------------------------------
-- player functions
------------------------------
function update_players()
 game.is_shopping=false
 local count=0
 for p in all(players) do
  --see if player is dead
  if p.hp<=0 then count+=1 p.hit_box.xl=-20
  --else player is alive
  else
   if p.hit_cooldown>0 then p.hit_cooldown-=1 end
   local n=p.n
   --different actions based on game state
   if p.state==4 then
    if game.state==0 then player_interact(p,n) end
    if game.state==1 then player_dodge(p,n) end -- x dodges during boss fights
    if game.state==2 and btn(5,n) and time()-ttk>2 then init_boss() end
    if game.state==3 and btn(5) then _init() end
   else
    player_movement(p,n)
    player_attack(p,n)
    player_hit(p,n)
   end
  end
  --see if all players are dead
  if count==#players then game.state=3 game.update=curr_game:update_game(3) music(15) end
 end
 update_timers()
end

function update_timers()
 local t=time()
 local currboss=boss.id
 for p in all(players) do
  if t-game.activescores[p.n].lasttime>2 and p.hp>0 then
   game.activescores[p.n].timer+=1
   game.activescores[p.n].lasttime=t
   game.activescores[p.n].total=(100*game.activescores[p.n].hitsgiven)-(50*game.activescores[p.n].hitstaken)-game.activescores[p.n].timer
  end
 end
end

function player_hit(p,n)
 for b in all(boss.bullets) do
  if p.hit_cooldown==0 and box_collide(p.hit_box,{b.hbox}) then
   del(boss.bullets,b)
   player_hurt(p)
  end
 end
 --see if hit by boss wave
 if boss.wave then
  if p.hit_cooldown==0 and box_collide(p.hit_box,{boss.wave.hbox}) then
   player_hurt(p)
  end
 end
 for hurtbox in all(boss.hurt_boxes) do
  if box_collide(p.hit_box,{hurtbox}) then
   p.d_vec.y=-3
   p.jumped=0
   if p.hit_cooldown==0 then
    player_hurt(p)
   end
  end
 end
end

function player_hurt(p)
 p.hp-=1
 game.screenshake=7
 p.hit_cooldown=120
 game.activescores[p.n].hitstaken+=1
 sfx(48)
end

function player_movement(p,n)
 --start cycle by creating copy of the players current directional vector
 local boxes=boss.col_boxes
 local x,y=p.d_vec:split()
 local p_hb=p.hit_box
 local box_up=p_hb:translate(v(0,-1.5))
 local box_down=p_hb:translate(v(0,1))
 local box_left=p_hb:translate(v(-1,0))
 local box_right=p_hb:translate(v(1,0))
 local j=p.jumped
 local state=p.state
 local a_state=p.attack_state

  --0. grounded checks
 if box_collide(box_down, boxes) then state=0 j=0 else state=1 end
 --1. moving horizontally
 --1a. moving left or right
 if btn(0,n) then
  if a_state==0 then p.d=1 end
  if x>0 then x=0 end --if turning
  if state==0 then x-=.05 else x-=.025 end --if ground or air
 elseif btn(1,n) then
  if a_state==0 then p.d=2 end
  if x<0 then x=0 end --if turning
  if state==0 then x+=.05 else x+=.025 end -- if ground or air
 else x=0 end

 --1b. horizontal velocity bounds
 if x<=-1.25 then x=-1.25 end
 if x>=1.25 then x=1.25 end

 --1c. horizontal collisions
 if box_collide(box_left, boxes) or box_collide(box_right, boxes) then x=0 end

 --3. jumping conditionals
 --3a. if player has jumped
 if btnp(2,n) and j<2 then j+=2 p.jump_time=time()+.5 y=-2.1 end
 if p.jump_time<=time() and j==2 then j=1 end --ready second jump
 if box_collide(box_up, boxes) then state=1 y=.1 end

 --3b. if player is now falling
 if box_collide(box_down, boxes) then state=0 else state=1 end
 --if floor -> flr box and reset jumps, else -> decrement y
 if state==1 then if box_collide(box_down, boxes) then j=0 p_hb:flr() else y+=.1 end end
 if y>2 then y=2 end
 --if box_collide(box_down, boxes) then state=0 else state=1 end
 if j==0 and state==0 then y=0 p_hb:flr() end
 --push out if inside block afterwards
 if state==0 and box_collide(p_hb, boxes) then p_hb=p_hb:translate(v(0,-1)) end

 -- 4. crouching changes
 -- 4a. check height
 local crouching=false
 local height=p_hb.yb-p_hb.yt
 p.h=height
 if btn(3,n) then crouching=true end
 if height==3 and crouching==false then p_hb=p_hb:extend(3, 4) end
 if height==7 and crouching==true then p_hb=p_hb:extend(3, -4) end

 --5. init dodge
 if btnp(5,n) and p.dodge_meter>=25 then state=4 x=0 y=0 p.attack_state=0 end

 --set player values
 p.jumped=j
 p.state=state
 p.d_vec=v(x,y)
 p.hit_box=player_bounds(p_hb:translate(p.d_vec))
end

function player_attack(p,n)
 local p_hb=p.hit_box
 local p_ab=p.attack_box
 local p_as=p.attack_state

 --1. can attack/press attack check
 if btnp(4,n) and p_as==0 then
  if p.d==1 then p_ab=make_box(p_hb.xl, p_hb.yt+2, p_hb.xl, p_hb.yb-2) end
  if p.d==2 then p_ab=make_box(p_hb.xr, p_hb.yt+2, p_hb.xr, p_hb.yb-2) end
  p_as=1
 end

 --2. collision checks
 --check for hit, cycle through boss hit boxes, make each box a table to re-use the box_collide function
 local damage=1 --suggested stat
 for i=1,#boss.hit_boxes do
  b=boss.hit_boxes[i]
  if box_collide(p_ab,{b}) and p_as==1 and boss.hit_cooldown==0 and boss.health_boxes[i] and boss.health_boxes[i]>0 then
   if boss.id==3 then for j=1,#boss.health_boxes do boss.health_boxes[j]-=1 end else boss.health_boxes[i]-=damage end
   p.dodge_meter+=10
   p_as=2
   boss.hit_cooldown=30
   game.activescores[p.n].hitsgiven+=1
   sfx(49)
  end
 end

 local dodge_meter_max=100 --suggested stat
 if p.dodge_meter>=dodge_meter_max then p.dodge_meter=dodge_meter_max end
 --3. hitbox movement
 --extend out
 local attack_length=35 --suggested stat
 if p_as==1 then p_ab=p_ab:extend(p.d, 1) if p_ab.xl<p_hb.xl-attack_length or p_ab.xr>p_hb.xr+attack_length then p_as=2 end end
 --reel in
 if p_as==2 then p_ab=p_ab:extend(p.d, -2) if p_ab.xl>p_hb.xl-1 and p_ab.xr<p_hb.xr+1 then p_as=0 end end

--4. connection to player
 if p.d==1 then p_ab.xr=p_hb.xl end
 if p.d==2 then p_ab.xl=p_hb.xr end
 p_ab.yt=p_hb.yt+2
 p_ab.yb=p_hb.yb-2

 --update player tables and translate box onto player
 p.attack_state=p_as
 p.attack_box=p_ab:translate(v(p.d_vec.x,0))
end

function player_dodge(p,n)
 local p_hb=p.hit_box
 local meter=p.dodge_meter
 local pressing_button=false
 if n==0 then
  for i=0, 3 do
   local dodge_speed=1.25 --suggested stat
   if btn(i,n) then p.d_vec=dirs[i+1]*dodge_speed p_hb=p_hb:translate(dirs[i+1]*dodge_speed) end
  end
   meter-=.5
 else
  meter-=.25
  if p.ready==false then p_hb=make_box(p_hb.xl-2, p_hb.yt-2, p_hb.xr+2, p_hb.yb) end
  p.ready=true
 end
 if btn(5, n) then pressing_button=true end
 if meter<=0 or pressing_button==false then p.state=1 if n==1 then p_hb=make_box(p_hb.xl+2, p_hb.yt+2, p_hb.xr-2, p_hb.yb) end p.ready=false end
 p.hit_box=player_bounds(p_hb)
 p.dodge_meter=meter
end

function player_interact(p,n)
 local p_hb=p.hit_box
 --check if in interact bounds
 -- if in pox_box bounds
 if box_collide(p_hb, {boss.hit_boxes[1]}) then p.shopping=true--pox code goes here
 elseif box_collide(p_hb, {boss.hit_boxes[2]}) then p.ready=true
 else p.state=1 end

 if p.shopping==true then
  game.is_shopping=true
  if btnp(0,n) then p.shop_option-=1 end
  if btnp(1,n) then p.shop_option+=1 end
  if p.shop_option<1 then p.shop_option=1 end
  if p.shop_option>3 then p.shop_option=3 end
  if btnp(4,n) then player_purchase(p,n) end
 end

 if (p.ready==true or p.shopping==true) and btnp(5,n) then p.ready=false p.shopping=false p.state=1 end
 p.dodge_meter=100
end

function player_purchase(p,n)
 local option_index=boss.pox_box_options[p.shop_option]
 local cost=pox_option_cost[option_index]
 if p.mutation_tokens>=cost then
  boss.pox_box_options[p.shop_option]=1
  p.mutation_tokens-=cost
  p.shopping=false
 end
end

--mid update function for player bounds
function player_bounds(p_hb)
 local x,y=0,0
 if p_hb.xl<0 then x=abs(p_hb.xl) end
 if p_hb.xr>127 then x=127-p_hb.xr end
 if p_hb.yt<0 then y=abs(p_hb.yt) end
 if p_hb.yb>127 then y=127-p_hb.yb end
 return p_hb:translate(v(x,y))
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


--------------------------
-- collisions
--------------------------

--takes in a player, and a table of boxes to check collision
function box_collide(c_box, table)
 local bool=false
 for b in all(table) do
  if c_box:overlaps(b) then bool=true end
 end
 return bool
end

function moving_plat_collision(plat, plat_vec)
 for p in all(players) do
  local p_hb=p.hit_box
  local box_down=p_hb:translate(v(0,1))
  if box_collide(box_down, {plat}) then p_hb=p_hb:translate(plat_vec) end
  p.hit_box=p_hb
 end
end

---------------------------
-- update cycles
---------------------------

function _update60()
 game.frame_counter+=1 if game.frame_counter>59 then game.frame_counter=0 end
 game.update()
end


function _draw()
 cls()
 map(0,0,0,0,16,16)
 cameffects()
 if game.state<2 then
  draw_hud()
  draw_boss(boss.id)
  draw_bullets()
  draw_platforms(boss.id)
  draw_players()
  if boss.id==2 and boss.wave and boss.wave.hbox then
   draw_box(14,boss.wave.hbox)   end
  if boss.shock_space then
	  draw_box(14,boss.shock_space)
	 end
 elseif game.state==2 then
  draw_transition()
 elseif game.state==3 then
  draw_gameover()
 elseif game.state==4 then
  draw_menu()
 end
 draw_instructions()
end

function draw_smoke(ss)
 if ss~=nil and game.frame_counter%15==0 then
  rx=rnd(20)
  if ss.xl<1 then rx+=108 end
  cloud={x=rx,y=127,sp=56,s=rnd(2)+1}
  add(game.particles,cloud)
 end
 for c in all(game.particles) do
   sspr(64,24,8,8,c.x,c.y,8*c.s,8*c.s)
   c.y-=1
   if c.y<1 then del(game.particles,c) end
  end
end

function draw_bullets()
 for b in all(boss.bullets) do
  spr(b.sprite,b.hbox.xl,b.hbox.yt)
 end
end

--draw box test func, draws boxes
function draw_box(t,b)
 rect(b.xl, b.yt, b.xr, b.yb, t)
end

-----------------------
-- render functions
-----------------------

--menu
function draw_menu()
 local sely
 --main
 if game.menu==0 then
  --draw_lips(0, {48,64,25,2,5})
  --sspr(96,0,32,32,0,0,127,127)
  --sspr(56,0,40,8,16,20,96,24)
  --print("1 player",20,90,11)
  --print("2 players",20,100)
  --print("hold z for instructions",20,110)
  if game.menuchoice==0 then sely=89 spr(17, 64, 90) spr(1, 64, 100) spr(33, 72, 100) else sely=99 spr(1, 64, 90) spr(17, 64, 100) spr(49, 72, 100) end
  spr(41,12,sely)

 --player select
 -- elseif game.menu==1 then
 --  rect(20,40,60,100,5)
 --  spr(12,22,42)
 --  if players[1].menuselect>0 then spr(38,37,64) else spr(6,37,64) end
 --  if #players>1 then
 --   rect(70,40,110,100)
 --   spr(13,72,42)
 --   if players[2].menuselect>0 then spr(38,87,64) else spr(6,87,64) end
 --  end

 --difficulty
 elseif game.menu==2 then
  print("easy",40,50)
  print("viral",40,60)
  if game.menuchoice==0 then sely=48 else sely=58 end
  spr(41,30,sely)
 end
end

function draw_instructions()
 if instructions == true and game.menu==0 then
   rect(4,4,123,123,11)
   rectfill(10,10,118,118,7)
   print("ability/interect/select: x",10,10,11)
   print("attack/purchase:         z",10,20,11)
   print("movement:       arrow keys",10,30,11)
   print("scarlet-fever (player 1)",10,40,8)
   print("ability: diffusion",10,50,8)
   print("description",10,60,8)
   print("description cont.",10,70,8)
   print("commander cold (player 2)",10,80,12)
   print("ability: chills",10,90,12)
   print("description",10,100,12)
   print("description cont.",10,110,12)
 end
end

--dodge_meter
function draw_hud()
 --draw player stuff
 draw_player_hud()
 --draw boss stuff
 draw_boss_health(boss.id)
end

--responsible for drawing player
--health and ability stuff
function draw_player_hud()
 for i=1,#players do
  local p=players[i]
  --player health
  for hp=1,p.hp do
   spr(p.n*32,0+8*hp+(i-1)*80,120)
  end
  --player ap
  rectfill(120*(i-1),2,7+120*(i-1),4,2)
  rectfill(120*(i-1),2,120*(i-1)+(p.dodge_meter/100)*7,4,8+p.n*4)
  rect(0+120*(i-1),1,8+120*(i-1),5,0)
 end
end

--given id of boss, draw the hp
function draw_boss_health(id)
 if game.state==1 then
  rectfill(24,1,104,4,2)
  rectfill(24,1,24+(boss.hp/boss.max_hp)*80,4,3)
  rect(23, 1, 105, 5, 0)
 end
end

function draw_players()
 for p in all(players) do
  local s=0
  local flip_x=false
  local flip_y=false
  local size_vec=v(8,8)
  local x,y=p.d_vec:split()
  local p_col=2
  local s_col=8
  if p.state==4 then
   if y!=0 and x!=0 then s=19
   elseif x!=0 then s=18
   elseif i!=0 then s=17
   end
   if y>0 then flip_y=true end
   if x<0 then flip_x=true end
   --if p.n==1 then spr(make_box(p.hit_box.x)) end
  else
   if p.h<7 then s=3
   elseif p.jumped>0 then s=4
   elseif x<0 then s=1
   elseif x>0 then s=2
   else s=6 end
  end
  if p.n==1 then s+=32 p_col=1 s_col=12 end
  local spr_vec=get_spr_pixels(s)
  spr_vec_to_box(p.hit_box, spr_vec, size_vec, flip_x, flip_y)
  local d=p.attack_box.xr-p.attack_box.xl
  local x=p.attack_box.xl
  local y=p.attack_box.yt
  if p.attack_state>0 then
   for i=0, d do
    local col=flr(rnd(3))
    if col>1 then pset(x+i, 2*sin(i/d)+y+2, p_col) else pset(x+i, 2*sin(i/d)+y+2, s_col) end
   end
  end
 end
end

function draw_boss(id)
 for i=1, #boss.hit_boxes do
  local draw=true
  if boss.health_boxes[i] and boss.health_boxes[i]<=0 then draw=false end
  local size_vec=boss_anim_size_vecs[id][i]
  local spr_vec=get_spr_pixels(boss_anim_sprites[id][i])
  local b=boss.hit_boxes[i]
  if draw==true then spr_vec_to_box(b, spr_vec, size_vec) end
  if id!=5 then
   draw_eyes(boss.state, boss_eye_points[id])
   draw_lips(boss.state, boss_lip_points[id])
   if id==3 then draw_smoke(boss.safe_space) end
  else
   if game.is_shopping then draw_pox_box()
   else
    local t="nice job. last boss ahead."
    if #game.b_remaining+1==3 then t="press x to interact with me"
    elseif #game.b_remaining+1==2 then t="not too bad."
    elseif #game.b_remaining+1==1 then t="ebola-chan would be proud"
    end
    print(t,1,30)
   end
  end
 end
end

function draw_pox_box()
 print("item:",1,32)
 print("cost:",1,40)
 print("mp:",1,64)
 for i=1,3 do
  local option_index=boss.pox_box_options[i]
  local name=pox_option[option_index]
  local sprite=pox_option_sprites[option_index]
  local cost=pox_option_cost[option_index]
  local x=(i*32)-#name
  print(name, x, 32, 7)
  print(cost, x, 40)
  spr(sprite, x+8, 38)

  for p in all(players) do
   if p.shopping==true then
    print(p.mutation_tokens,40+(16*p.n), 64,8+p.n*4) --print player tokens
    if p.shop_option==i then spr(16+(32*p.n),x+(12*p.n),23) end --print player option selection icon
   end
  end

 end
end

function draw_platforms(id)
 if id==2 then
  local apple_vec=v(8,96)
  local banana_vec=v(24,104)
  local plum_vec=v(8,112)
  spr_vec_to_box(boss.col_boxes[2], apple_vec, v(16,16))
  spr_vec_to_box(boss.col_boxes[3], banana_vec, v(16,16))
  spr_vec_to_box(boss.col_boxes[4], plum_vec, v(8,8))
 else
  if id!=5 then
   local start=2
   if id==1 then start=3 end
   if id==3 then start=4 end
   for i=start, #boss.col_boxes do
    local p=boss.col_boxes[i]
    local spr_vec=get_spr_pixels(110+(2*id))
    local size_vec=v(16,8)
    spr_vec_to_box(p, spr_vec, size_vec)
   end
  end
 end
end

 --mood, eye_x, eye_y, eye_r, distance, primary color, secondary color
function draw_eyes(m, pts_table)
 local e_x=pts_table[1]
 local e_y=pts_table[2]
 local e_r=pts_table[3]
 local d=pts_table[4]
 local p_col=pts_table[5]
 local s_col=pts_table[6]
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
 line(l_e_x-e_r, e_y-e_r-2, l_e_x+e_r, e_y-(e_r/2)-1, p_col)
 line(l_e_x-e_r, e_y-e_r-1, l_e_x+e_r, e_y-(e_r/2), s_col)
 --right brow
 line(r_e_x+e_r, e_y-e_r-2, r_e_x-e_r, e_y-(e_r/2)-1, p_col)
 line(r_e_x+e_r, e_y-e_r-1, r_e_x-e_r, e_y-(e_r/2), s_col)
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
  --pset(91,59,12)
  --pset(98,59,12)
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
   p_x=p.hit_box.xl
   p_y=p.hit_box.yt
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
function draw_lips(m, pts_table)
 local x=pts_table[1]
 local y=pts_table[2]
 local len=pts_table[3]
 local p_col=pts_table[4]
 local s_col=pts_table[5]

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
 elseif m==1 or m==2 then --angry mood
  for i=0, len-1 do
    pset(x+i, y+3*sin(i/l), p_col)
    pset(x+i, (y+1)+3*sin(i/l), s_col)
    pset(x+i, (y+2)+3*sin(i/l), s_col)
    if c!=1 then
     pset(x+i, (y+3)+3*sin(i/l), p_col)
     if m==1 and i%2==0 and i!=0 then pset(x+i, (y+2)+3*sin(i/l), 7) end
    else
     pset(x+i, (y+3)+3*sin(i/l), s_col)
     pset(x+i, (y+4)+3*sin(i/l), p_col)
     if m==1 and i%2==0 and i!=0 then pset(x+i, (y+3)+3*sin(i/l), 7) end
    end
   end
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
  if p.n<1 then spr(6,12,ypos) else spr(38,12,ypos) end
  print(game.activescores[p.n].timer,30,ypos)
  print(game.activescores[p.n].hitsgiven,50,ypos)
  print(game.activescores[p.n].hitstaken,70,ypos)
  print(game.activescores[p.n].total,96,ypos)
  ypos+=16
 end
 print("x to restart",45,100,3)
end

-----------------------
-- render engine/helpers
-----------------------

--draw box test func, draws boxes
function draw_box(t,b)
 rect(b.xl, b.yt, b.xr, b.yb, t)
end

-- input: start sprite num, end sprite num
-- ouput: vectors with position of sprites
function get_spr_vec_tables(start_num,end_num)
 local spr_table={}
 for i=start_num, end_num do add(spr_table, get_spr_pixels(i)) end
 return spr_table
end

-- input: sprite number that you would normally pass an spr function
-- output: x,y = cordinates of sprites top left pixel
-- detail: called during init to set up low token count tables to index sprites
function get_spr_pixels(spr_num) return v((spr_num%16)*8,flr((spr_num/16))*8) end

-- input: box to draw sprite onto, spr_num, optional size vec, width and height of sprite in sheet(used for boss rendering)
-- output: calls sspr function using box cords and vec cords
-- detail: if no spr_size_vec, assumed size is 8,8
function spr_vec_to_box(box, spr_vec, spr_size_vec, flip_x, flip_y)
 local scr_x, scr_y=box.xl, box.yt
 local scr_w, scr_h=box.xr-scr_x, box.yb-scr_y
 local spr_x, spr_y=spr_vec:split()
 local spr_w, spr_h=spr_size_vec:split()
 local flip_x=flip_x or false
 local flip_y=flip_y or false
 sspr(spr_x, spr_y, spr_w, spr_h, scr_x, scr_y, scr_w+1, scr_h+1, flip_x, flip_y)
end
__gfx__
066666600008200000028000000000000082280000822800000280005577775577757777555557777755557775577777fffffffff4fffffff4fffffff6667577
006666000082280000822800000000000822288008222880008228005b5775b5755555775b3335577533335775b57777ffffffff44fffffff44ffffff0077767
0622226002228280082822200000000082722722827227220828222053577535756665775355b3357535535775b57777ffffffff44fffffff44ffff766000777
0622226027272220022272720000000002822280028222802272278205b55b50756665775333355053bbbb3505350000ffffffff44fff4fff444fff777667770
06222260028222800822282000822800002228000022280008222820753553577533357753b557775355553575357777fffffff44fff4ffffff4ffffff706670
06222260002282000028220008822280002002000020020000282200775bb57775bbb577533b57775357753575355557fffffff4fff44ffffff44fff76665707
0062260022828280082828222272272200800200008002008228282877533577775557775b55b5775357753575333bb5ffffff44f0004ffff00f4ffff6667767
000660008020202002020202082828200080080000800800202002027775577777757777555755575557755575555557ffffff440000444440004fffff765766
0220002000000000000000000000000005050050099959509095090980000008100001100000ee000001100000000000fffffffffffffffffffffffffff76776
02020220000880000000000000000000505005055955559509099590080000801121221000000ee000e11e0000555000fffffffffffffffffffffffffff76766
022000200082280005998800000880000555555095599590599889090080080002188220000000ee0ee118e005666550ffffffffffffffffffffffffffffffff
02000020008228000998228000822800005995059598895590888895000880000288882000000eeeee811e8e56666665ffffffffffeeefffeeeffffffff77fff
0200022200988900599822800982280050599500559889595988889000088000022818200000eeeee8e11eee56666666fffffffffeeeeeeeeeeefffff7777fff
000000000099990005998800599880000555555095599590959889550080080000218220ee0eeee08ee11e8e56666666ffffffffeeee777777eeefff7777ffff
000222000059950000000000059900005050050559555595095095990800008000228200eeeeee00eee00eee56666660ffffffffee777777777eee77777fffff
0000200000050000000000000050000005005050009059509095509580000008000222000eee00000e0000e005555550fffffffee7777777777745577fffffff
06666660000c10000001c0000000000000c11c0000c11c000001c0000000000000000000000000007777775777777777ffffffee0000000000044457ffffffff
0066660000c11c0000c11c00000000000c111cc00c111cc000c11c000000000000000000000000007777755577777777fffffee000000000004444eeffffffff
06cccc600111c1c00c1c111000000000c1711711c17117110c1c11100666666008808800000000007777756577777777fffffee777777777777777eeffffffff
06cccc6017171110011171710000000001c111c001c111c0117117c1067777608ee8ee80003330000000056500000000ffffffee7777777777777eefffffffff
06cccc6001c111c00c111c1000c11c0000111c0000111c000c111c10067777608eeeee80000003007777753577777777fffffffee77777777777eeffffffffff
06cccc600011c100001c11000cc111c00010010000100100001c11000677776008eee80000333000777775b577777777ffffffffeeeeeeeeeeeeefffffffffff
006cc60011c1c1c00c1c1c111171171100c0010000c00100c11c1c1c06666660008e8000000000007777775777777777fffffffffeeeeeeeeeeeffffffffffff
00066000c0101010010101010c1c1c1000c00c0000c00c00101001010000000000080000000000007777775777777777fffffffffffeeeeeeeefffffffffffff
0cc000c007c7cc7007c7c70000cccc000070700000700007000000000550005005505505666666668888888ff8888888ffffffffffffffffffffffffffffffff
0c0c0c0c7ccc7cc77c7cccc70cccccc0070007007007070066666660577505755555055069993336888888affa888888ffffffffffffffffffffffffffffffff
0cc0000c0c1117700c111cc70c111cc000070007070000706c6c6c6057a957a70505555569aa399688888a8ff8a88888ffffffffffffffffffffffffffffffff
0c0000c0717171c7717171100171711070000700700000006c6c6c6055799a7505555050693939368888a88ff88a8888ffffffffff44444444444fffffffffff
0c000ccc0c1c11c00c1c1cc70c1c1cc00007000000070070686c6c60057797505550555563333336888a888ff888a888ffffffffff4fffffffff4fffffffffff
000000007c111cc77c1117c00c1117c0070007070700070068686c60575aa57005055550693a3a3688a8888ff8888a88fffffffff4fffffffffff4ffffffffff
000ccc000c1c1cc00c1c1c77cc1c1ccc000000000000000068686860557575505555050569a339968a88888ff88888a8ffffffffffffffffffffffffffffffff
0000c000c1ccc1c7c1ccc17cc1ccc1cc700700700000700766666660055057550505550069999396a888888ff888888affffffffffffffffffffffffffffffff
eeeeeeeeeeeeeeee99999999999999991111111c111111c13ffffffffffff333ffffffffff3333ff7777777766666666fffff33feeeeffeeffffffff99999999
222222222222272299ffff99f9999ff9111111c111171c1133333fffff333333fffafffffbfa773f7777777766666666fffabf73eeeefeeeffffffff99999999
e22722ee222222229999fff99fffff99117111c111717111a3333333333333aaf9fffaffb9fff7737777777766666666f9ffbaf3feefffefffffffff99999999
22222222222eee22999999ff9999999917171117111c1111aaaaa333333aaaaaffffffffbffffff37777777766666666fffffbbfefeeeeeeffffffff99999999
22e22222222222229999999ff9999ff9117111717111c111aaaaaaaaaaaaaaaffff9ffffbff9fff37777777766666666fff9ffffeffeeeeeffffffff99999999
222272eee2272222999999ff9fffff99111c111711171cc1fffffaaaafffffffffff9fffbfff9ff37777777766666666ffff9ffffeeeeeffffffffff99999999
22222222222222229999fff9999999991111c1111171c11cffffffffffff3333faffff9ffbffff3f7777777766666666faffff9feeefeeeeffffffff99999999
eeeeeeeeeeeeeeee9999999999999999c11117111117111133ffffffff333333afffffffafbbbbff7777777766666666afffffffeeffeeeeffffffff99999999
1111111111111111999999999ff999991c11717111111111333333333333333355555555ffffffff3ffffffffffff333eeeeeeee888888882222222200000000
ddddddddd7dddddd9999999999fff999117117111171cc11333333333333333355555555ffffffff33333fffff333333eeeeeeee888888882222222200000000
d7dd1dddddd11dd19999fff99999999917171111171c11c1aaa333333333aaaa55555555ffffffffa3333333333333aaeeeeeeee888888882222222200000000
ddddd11dddddd7dd999f99f9999ff9ff1171117111711111aaaaaa333aaaaaaa5555555577777777aaaaa333333aaaaaeeeeeeee888888882222222200000000
d111dddd11dd1ddd99f99f999999fff911111c1711111111fffaaaaaaaaaafff5555555577777777aaaaaaaaaaaaaaafeeeeeeee888888882222222200000000
1dddddd1ddd1d1d1ff999f99999999991111c17111117111ffffffffffffff3355555555fffffffffffffaaaafffffffeeeeeeee888888882222222200000000
ddd7ddddd7dddddd999999f99ffff9991111c1111117171133fffffffffff33355555555ffffffffffffffffffff3333eeeeeeee888888882222222200000000
11111111111111119999999999999999111c11111111c111333333333333333355555555ffffffff33ffffffff333333eeeeeeee888888882222222200000000
2222222222222222bbbbbbbbcccccccc1111111111111111ff3333fffffff33fdddddddd666666668888888800000000ffffffffffffffffffffffffffffffff
2222222221112222bbbbbbbbcccccccc1111d111ddc1d11df3bb773fffff3b73dddddddd666666668888888800000000ffff55ffffff55ffffffffffffffffff
112112111ddd1221bbbbbbbbccccccccd11dd11ddddcdd1d3bbbb773ffff3bb3dddddddd666666668888888800000000ff559955ff559955ffffffffffffffff
dd1dd1ddddddd11dbbbbbbbbccccccccd1d7dd1ddd7d7dcd3bbbbbb3fffff33fdddddddd6666666688888888000000005599999955999999ffffffffffffffff
ddddddddddddddddbbbbbbbbccccccccdc7dcdcd7dd7d7d73bbbbbb3ffffffffdddddddd666666668888888800000000ff559955ff559955ffffffffffffffff
11ddddd11dddddd1bbbbbbbbccccccccdcd7dcdcd7dddd7d3bbbbbb3ffffffffdddddddd666666668888888800000000ffff55ffffff55ffffffffffffffffff
221ddd1221111d12bbbbbbbbcccccccc7d7ddddd7dddddddf3bbbb3fffffffffdddddddd666666668888888800000006ffffffffffffffffffffffffffffffff
2221112222222122bbbbbbbbccccccccd7ddddddddddddddff3333ffffffffffdddddddd666666662222222266666666f555f555f555f555ffffffffffffffff
deeeeeedd111111daaaaaaaa333333330101010101010100ffffffffffffffff111111110000000006666666666666665999599959995999ffffffffffffffff
e222222e1cccccc1aaaaaaaa333333331111111111111111ffffffffffffffff11111111006666666677767766666666f555f555f555f555ffffffffffffffff
e2e22e2e1c1cc1c1aaaaaaaa33333333017171111711c110ffffffffffffffff11111111666766777677767677666666ffffffffffffffffffffffffffffffff
e222222e1cccccc1aaaaaaaa33333333111711c1c171c111ffffffffffffffff11111111666767776677667677666666ffff55ffffff55ffffffffffffffffff
e2e22e2e1c1111c1aaaaaaaa333333330171cc1c171c1110ffffffffffffffff11111111066666666777667677666600ff559955ff559955ffffffffffffffff
e2eeee2e1c1cc1c1aaaaaaaa333333331111111111111111ffffffffffffffff111111110000666667766776666600005599999955999999ffffffffffffffff
e222222e1cccccc1aaaaaaaa333333330101010101010100ffffffffffffffff11111111000000006666666666000000ff559955ff559955ffffffffffffffff
deeeeeedd111111daaaaaaaa333333330000000000000000ffffffffffffffff11111111000000000000000000000000ffff55ffffff55ffffffffffffffffff
00000000000000008888888000011110000000000000222222222220000000000000000000000000000000000000000000000000000000000000000000000000
0000000111022000888888882201001000000000000022eee2222222220000000000000000000000000000000000000000000000000000000000000000000000
0000000101122228888888882111001000000000000022eeeeeee888822000000000000111110000000011110000000000000000000000000000000000000000
0000001100122288888818881111110000000000000002eeeeeee8822222000000000001eee100000000eee11000000000000000000555555555555000000000
0000001011122888882111111111000000000000000002eeee8822882222000000000011e2ee00000000eeee1000000000000000555565f66556665550000000
00000111112288888222111111100000000000000000022eeee22282222220000000001ee2eee0000000ee2e1100000000000055565ff6555566eee655000000
00000111122228882222211111000000000000000000000eeeeeee22eee222000000011ee2eee000000eee2ee100000000000556ee5fff66566eee5e65500000
00000111228828882221111111000000000000000000000eeeeeeeeeeee22200000001eee2eee100001ee12eee1100000005566ee55f55665ee55e655ff50000
00011111288828811111111112000000000000000000000eeeeeeeeeee8222000000118822222e1001e2e12eeee10000055566e5555655555555555556ff5000
00011111188128888111111222200000000000000000002eeeeeeeeeee82222000001e822e82ee1001e22e2222e110005556eee5566565eeee55fffffe5f5500
00011111888122288888818122200000000000000000002eeeeeeeeeee82222000001e82e882ee0000ee222822ee100055f6ee5ff66556e66e6655fffe5fff50
00011118881112222888818111120000000000000000002eeeeeeeeeee8222200001ee82e882ee0000ee82e882ee11005ff6e65f6e6eee55ee56eefffe566fff
00011228811811112288828222122200000000000000022eeeeeeeeeee2222200011e82e1282ee0000ee821e82eee1005ff56fff6e5ffe65e6556eeeee5eeee6
0001122281888221828222882212220000000000000002eeeeeeeeeeee222220001ee2e112822e0000e1821e822ee10055f56f6eee5feee5e66555effff6e5e6
0002111222222221182281882218220000000000000002eeeeeeeeeee2222220001e82e128e2220000e12e1182eee10055f5efee655f66e6e66e65555ffff5e5
0000228111111128112821882211220000000000000002eeeeeeeeeee2222220001e22e2288ee20000e12821128ee10056f5e6e555ff55ee556ffffeeeee6655
0000028881288822828821882211220000000000000022eeeeeeeeee88222220011e211ee28881000011eeee128eee105ef5eee56ff65666566e6ff566555555
000002288828111888812118211220000000000000002eeeeeeeeee88222222001e221e2ee22810000e2e2ee1e8eee105ef55556ef655656565e56f56eeee655
000002288821881188822812218220000000000000222eeeeeeee8888222220001e2e1288ee28100001ee1e8811eee105eeeeeee6f555555555e55f5556ee550
000000228122288888222812218220000000000000222eeeeeee88222222220001e81e281ee281000011e1e8881882105e56e665556eff665fff6ee556655550
00000022211828882211281881820000000022222222eeeeeee882222222200001ee128ee8e2210000e111e22e112e105e555555655e6ff556eeee5666666650
00000002281821882181228888220000000222eeeeeeeeeeee8822222222200001eee22ee8e82e0000e112e2e222ee1056555555556eeeff55e6655566555650
00000000281122882181128822200000000282eeeeeeeeeee82222222222000001ee28eee8e82e0000e112e28ee22e105556fef655555eee6555555665555500
000000002281128218882282220000002222822eeeeeeeeee82222222220000001e282e122e82e0000ee22ee888eee10066efff55555555ee555555555555500
000000000288118218822882220000002228882eeeeeeeeee22222222200000001ee8ee128e88e00008eeeee1288ee1000055555555555655556555556656000
000000000288882218221822200000002282222eeeeeeee2222222222000000001e88e12eeeee8000088eeee11288e1000056655555555565566666666655000
000000000028888888281822000000002282eeeeeeeee222222222220000000001e8eeeee888880000088888e1112e1000006555566665555555555555655000
000000000022288888881222000000002222eeeeeeee2222222220000000000001e11ee8800000000000000088e11e1000005556665555660555555555650000
0000000000022288888112200000000022222eee88882222222000000000000001e1e8880000000000000000088eee1000005666555555500556665565660000
000000000000222881112200000000000022288888222222000000000000000001ee800000000000000000000088ee1000000665555655600005566555560000
000000000000002221222000000000000002222222222200000000000000000001e88000000000000000000000088e1000000065566550000000055550000000
00000000000000002222000000000000000022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222c122200000bb004400000000888000009990000eeee00aaaaaaa400022200000888000bbbbbb0000000000000000011111111111111111111111111111111
0221c22000000bbb440000000888ff000999aa000e8888e0a4a4a4a40002220000088800b888888b000000000000000011111111111111111111111111111111
00211200000000b44000000008fff00009aaa000e88ee882aaaaaaa40022022000880880b8b88b8b000000000000000011444444444444444444444444444411
002c1200000000040000000088ff400099aa7000e8e88282a4a4a4a40220002208800088b888888b0000000000000000114444444444444444444444444444f1
00211200000888848888800088fff40099aaa700e8e88282aaaaaaa40200000208000008b8b88b8b0055555555555000114444444444444444444444444444f1
00211200008888888777880008ffffff09aaaaaae8822822a4a4a4a40220002208800088b8bbbb8b0575565675675500114444444444444444444444444444f1
0021c2000888888888777800088ff888099aa99902888220aaaaaaa40220002208800088b888888b05656656656657501144f1111111111111111111111144f1
002c120008888888888878000008880000099900002222004444444400000000000000000bbbbbb055656556656566751144f1111111111111111111111144f1
002e820008888888888888000000000000000044007777000000000000000000000000000000000057656566556566651144f1111111333311111111111144f1
0028e20008888888888888000000000000000044077777600000000000000000000000000000000005556566566566501144f11111133bbb11115111111144f1
0028820008888888888888000000000000000004777777760880880000000000000000000000000005575575666555001144f111113bbcccc1151111111144f1
0028820008888888888822000000000000000999777766768888888000000000000000000000000000555555555550001144f11111b6cccc11151111111144f1
002e8200088888888882200000000000000009a9777667768888888055550000000000000000000000000000000000001144f11113b1656511511111111144f1
0028820000888888888200000000000000009a99777677660888880066666555500000000000000000000000000000001144f1113331ccccc1111111111144f1
0228e22000088888822200000000000000099a99077776600088800066566666665555000000000000000000000000001144f1113111cc4778111111111144f1
222e82220000882222000000499000000099a9a9006666000008000066755656666656655500000000000000000000001144f11111cc1ccc11111111111144f1
1122110000044000000440009a999000999a99a900a0a0a00000000066666675666566666665550000000000000000001144f1111ce7ccecc1111111111144f1
01111000022222500bbbbb309aaa99999aaa9a990a9a989a0000000055555665666666667566666550000000000000001144f1111ee1c1c9c1111111111144f1
0122100022227725bbbb77b399aaaaaaaaa99a90a98a89800000000000000555556666675666566666500000000000001144f1111e11e19cc1111111111144f1
0111100022222775bbbbb773999999999999a9900aaaaaaa000bb00000000000005555666666756656665000000000001144f111c711ccccc1111111111144f1
0122100022222225bbbbbbb3099aaaaaaaaaa990a98aa980b0b00b0b00000000000000555556666665666650000000001144f111e1dededd51111111111144f1
0111100022222255bbbbbb3300999aaa99999900089a989a0b0000b000000000000000000005555667567565000000001144f11cceededed51111111111144f1
01221000022225500bbbb3300009999999999000a98a89a000000000000000000000000000000005556666560000000099999999999999999999999999999999
12222100005555000033330000000999990000000a0a0a0000000000000000000000000000000000005567560000000099999999999999999999999999999999
001111000008ee2066666666666666666667777777777666666666667777777766677777777776560000557660000000114555555555555555555555555554f1
01cc7c100222e200656a656a656a656a6567777777777656a656a6567777777765677777777776660000005760000000114444444444444444444444444444f1
1c0000c102ee200066666666666666666667777777777666666666660000000066600000000006a60000000566000000114222422242424444224422242424f1
1c000071002e80006a677777777777776a600000000006a6777776a6777777776a677777777776660000000066000000114242424242424444242424242424f1
1c0000c1000e820066677777777777776667777777777666777776667777777766677777777776560000000006000000114222424244244444224424244244f1
1c0000c10002e82065600000000000006567777777777656000006566666666665666666666666660000000000000000114244424242424444242424242424f1
01cccc10002e22206667777777777777666777777777766677777666656a656a66656a65656a656a0000000000000000114244422242424444224422242424f1
0011110002ee20006a677777777777776a677777777776a6777776a6666666666a666666666666660000000000000000114444444444444444444444444444f1
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100010100001010000010010001010100000101000000000101000000000101101000100100000000000000000001010101010100000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
292929292929292929292929292929297777775c5c5c5c5c5c5c5c5c5c7777774141414040414041404041404041404167666767666766676f666766676f6667786878687868786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977775c5c5c5c5c5c5c5c5c5c5c5c77776868686868686868686868686868686866676667766776776776777666677666786878787868786878686868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929775c5cf2f3f3f3f3f3f3f3f3f65c5c77686868686868686868686868686868686767766f76776f6f6f6f6f6f6f6f676f786878687868786878787878786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929775c5cf4072a2b092b0a2b0bf55c5c776868686868686868686868686868686866766f6f6f6f777776776e6f6f6f6766786878687868786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5cf2f8f7f7f7f7f7f7f7f7f9f65c5c6868686868686868686868686868686867766f7f7e7f7e7f7e7f7e7f7e7f676f787878687868786878787868787878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2c2c2c2c2c2c2c2c2c2c2c2c2c29295c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c686868686868717171686868686868686f6f6e6f6e6f6e6f6e6f6e6f6e6f6f6f786878687868786878687868786878785f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c68686868686868686868686868686868777f7e7f7e7f7e7f7e7f7e7f7e7f6f6f787878687868787878687868787878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c686868686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f786868687868786878687868786878785f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5f5f5d5d5d5d5f5f5d5d5d5d5f5f5c686868686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f786878787868787878687868786868685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5d5d5d5d5d3a6a6a3b5d5d5d5d5d5c686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f786878687868786878687868787878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5d5d5d5d3a6a6a6a6a3b5d5d5d5d5c707070686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f786878787868786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929295c5c5d5d3a6a6a6a6a6a6a3b5d5d5c5c686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f786878687878786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929775c5d3a6a6a6a6a6a6a6a6a3b5d5c77686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f786878687868786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929775c5cf8f2f3f3f3f3f3f3f6f95c7777686868686868686868686868686868684e4e4e6e6e6e6e4e4e4e4e6e6e6e4e4e786878687878786878687878786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977775c5cf8f7f7f7f7f7f7f95c5c7777404140414041404140414041404140415a5b5a474647465b5a5b464746475a5b786878687868786878687868786878685f5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929297777775c5c5c5c5c5c5c5c5c5c7777775051505150515051505150515051505156575657565756575657565756575657786878687868786878687878786878685f5f5f5f5f5f5f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
787878787878787878787878787878787777775c5c5c5c5c5c5c5c5c5c7777774444444444444444444444444444444400000000000000000000000000000000000000000000000000000000005f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6465646565646564656464646564646577775c5c5c5c5c5c5c5c5c5c5c5c7777444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
68686868686868686868686868686868775c5cf2f3f3f3f3f3f3f3f3f65c5c77787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
68686868686868686868686868686868775c5cf4072a2b092b0a2b0bf55c5c77787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5cf2f8f7f7f7f7f7f7f7f7f9f65c5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5f5f5f5f5f5f5f5f5f5f5f5f5f5f5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5f5f5d5d5d5d5f5f5d5d5d5d5f5f5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5d5d5d5d5d3a6a6a3b5d5d5d5d5d5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5d5d5d5d3a6a6a6a6a3b5d5d5d5d5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868685c5c5d5d3a6a6a6a6a6a6a3b5d5d5c5c787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
68686868686868686868686868686868775c5d3a6a6a6a6a6a6a6a6a3b5d5c77787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
68686868686868686868686868686868775c5cf8f2f3f3f3f3f3f3f6f95c7777787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444446868686868686868686844444477775c5cf8f7f7f7f7f7f7f95c5c7777444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444686868686868686868684444447777775c5c5c5c5c5c5c5c5c5c777777444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0101000001070090700107022000250002800012000120001200011000110001000011000110001200010000100000f0000f0000e000000000000000000000000000000000000000000000000000000000000000
0114000009534095340c53410530095340c5340f5341053011534115340c534155301c5341553417534155300753407534175340c5300b5340e534115340e530145341453410534175300e5340f5341053414530
011400000705307053186750700307053070531867507003070530705318675070030705307053186750700307053070531867507003070530705318675070030705307053186750705307003070531867507053
01140000105002150518540185401b5421b54218540185401d5401d5401c5421c542185401854015540155401754017540175421754217542175420000000000095400c54000000000001b5521c5521855221552
011400000915000000000000410009150001000010004100051500010000100041000515000100001000410007150001000010002100071500010000100041000215000100001000210004150001000010004100
01140000105002150518540185401b5401b54018540185402154021540205401c540205401c5401a540185401a5401a5401a5401a5401a5401a540186050700315541155410f541105411b5421c5421854221542
011400000c5340c5340f534105300c5340c5340b5340c5300e5340e5340c53415530115340e5340e5340c5300753407534175340c5300b5340e534115340e530145341453410534175300e5340f5341053414530
01140000105002150518540185401c5421c54218540185401d5421d5421c5401a54018540155421154015500175001750017540175401a5401a5401d5401d5401054014540170401a0401c5421b5421a54218542
011400000c1500c0000c000101000c1500c1000c100101000e1500c1000c100101000e1500010000100041000b1500010000100021000e150001000010004100081500010000100021000b150001000010004100
01140000105002150518540185401b5421b54218540185401d5401d5401c5421c54218540185401a5401a5401354013540135421354213542135420000000000095400c54000000000001a5421b5421c54220542
011400000705307053186750700307053070531867507003070530705318675070030705307053186750700307053070531867507003070530705318675070031867507003186050700307003070031860507053
011c00000705307053186750705307003070531867507003070530705318675070530700307053186750700307053070531867507053070030705318675070030705307053186750705307003070531867507003
011c0000071450a145070550c055070550d055070550e055071450a145070550c055070550d055070550e055071450a145070550c055070550d055070550e055071450a145070550c055070550d055070550e055
011c00001a7621a7621a76219762187621676213060000001a7021a7021a70219702187021670213000000001a7621a7621a76219762187621676213060110550e0550c0550e0550c05518702137021800000000
011c0000051450a145050550c0550505509055050550e055051450a145050550c055050550c055050550e055041450a145040550c0550405507055040550e055031450a1450305513055030551d055030550e055
011c00001876218762187621676215762117620e060000001a7021a7021a70219702187021670213000000001876218762187621676215762117620e062110520e055110550e05511055187021a0501d0501e055
011c00000705307053186750705307003070531867507003070530705318675070530700307053186750700307053070531867507053186050705318675070531867507053186750705318675070531867507053
011c0000071450a145070550c055070550d055070550e055051450a145050550c055050550c055050550e055041450a145040550c0550405507055040550e055031450a1450305513055030551d055030550e055
011c00001a7601d7621a7621976218760167621306211062130501605218052160521a050150521300218052227601f762227621f7621c7601f7621c0621f0621a0601b0621f062220621f000240622506226062
011c00003270532705327253270532705327053272532705327053270532725327053270532705327253270532705327053272532705327053270532725327053270532705327253270532705327053272532705
011000000705307053186750705307003070531867507053070030705318675070530700307053072531867507053070531867507053186050705318675070531860507053186750705318605070531867518675
011000001c1201b1201a120191201822017120161201512021120201201f1201e1201d2201c1201b1201a12024120231202212021120202201f1201e1201d120231202212021120201201f2201e1201d1201c120
011000000934009340000000944009440094400944000000023400234000000024400244002440024400000005340053400000005440054400544005440000000434004340004000444004440100000844000000
0110000000000000001c4421c34218442183421c4421c3421b4421b34215442153421a4421a3421844218342154421534218442180001d4421d3420000000000154421534218442000021c4421c3420000000000
0110000000000000002844228342244422434228442283422744227342214422134226442263422444224342214422134224442180002b4422b34200000000001f4421f34223442000022b4422b3422c4422c342
0110000000000000001c4421c34218442183421c4421c3421b4421b34215442153421a4421a3421844218342154421534218442180001d4421d3420000000000154421534218442000021f4421f3420000000000
011000000000000000284422834224442243422844228342274422734221442213422644226342244422434221442213422444218000354423534200000000001f4421f342234420000234442343422c4022c302
010e00002163723636216372463523637216342463723633216372463323637216322463723633216372463423637216352463723634216372463323637216342463723635216372463623634216332463223631
011000001605016030160201601016050160301602016050160501603016020160101905019030190201805018050180301802016050160501603016020160501605016030160201601016010000000000000000
011000001105011030110201101012050120301202012010110501103011020110101205012030120201201011050110301102011010120501203012020120101105011030110201101011010110101101011010
01100000130501305013050130500e0500e0500e0500e050130501305013050130500e0500e0500e0500e050130501305013050130500e0500e0500e0500e0501305013050130501305000000000000000000000
011e00000705307003186050700318675070031860507053070530700318605070031867507003072030705307053070031860507003186750700318605070530705307003186050700318675070531860507053
011e0000121320e735121320e735121320e735121320e735111320a735111320a73511132097351013209735121320e735121320e735121320e735121320e735111320a735111320a735111320c735101320c735
011e00002d2322d4222d2222d4222d2122d4122d2122d4122d2122d4122d2122d412150001500028222284222d2322d4222d2222d4222d2122d4122d2122d4122d2122d4122d2122d41215000150002422224422
010c00001f6501f6401f6301f6501d6401b6301a650186401f6501f6401f6301f6501d6401b6301a6501864007053070030705307053306750705300000306750705300000306750705300000306753067530675
010c0000154001550015000120001100011000000000000000000000000000000000000000000000000000000c2300c34012450122301134011450162301634015450152301b3401b4501a2301a3401a45018670
010c00000707307003306750700330675070730000030675070730707330675070033067507073070033067507073070033067507003070733067507003306750707307073306750700330675306753067530675
010c00000000000342003420034200302003020030200302000000034200342003420030200302003020030200000033420334203342003020030200302003020000003342033420334200302063420634206302
010c000013250134400c2300c55013240134300c2500c54016230164500f2400f53013250134400c2300c5501624016430122501254018230184501224012530192501944016230165500a2400a4300b2500b540
010c000013250134400c2300c55013240134300c2500c54016230164500f2400f53013250134400c2300c550192401943016250165400f2300f45016240165301c2501c440192301955013240144300a2500b540
010c000016240164400f2400f54016240164400f2400f5401924019440162401654016240164400f2400f540192501945016250165500f2500f45016250165501c2501c450192501955013250144500a2500b550
010c000016240164400f2400f54016240164400f2400f5401924019440162401654016240164400f2400f540192501945016250165500f2500f45016250165501c2501c45019250195502b2502c4502e2502f550
010c00001b2401a440182301853018220184200f2000f5001b2401a440182301853018220184200f2000f500202401f4401b2301b5301b2201b4200f20016500202501f4501b2401354014240164401725018550
010c0000242501f4401b23018550242401f4301b25018540232301f4501b24017530232501f4401a23017550202401f4301b2501454014230134500f240145301825017440162301555014240134300f2500e540
010c000030675070531f600306751d600306750705318600306751f6001f600306751d6001b600306751860030675070531f600306751d600306750705330605306751f6001f600306051d6001b6003060530605
010c0000182202b4401822027540182202b4401802027040182202b4401822027540182202b44018020270401d2202a4401e2202a5401e220294401b020270401b2202544022220255401b220294401e2202e540
010c0000242501f430242501b530242501f430240501b030242501f430242501b530242501f430240501b030292501e4302a2501e5302a2501d430270501b03027250194302e25019530272501d4302a25022530
010c00001b2421a446182321853618222184260f2020f5001b2421a446182321853618222184260f2000f500202421f4461b2321b5361b2221b4260f20016500202521f4561b2421354614242164461725218556
010700000c15200152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000754307406000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 0b0c4d44
00 0b0c0d44
00 0b0e0f44
02 10111213
01 14154344
00 14151644
00 14151617
00 14151619
00 1415161a
02 14151618
07 1b424344
00 1c1d4344
01 1f204344
03 1f202148
00 22234344
01 24252644
00 24252627
00 24252628
00 24252629
00 24252a6a
00 24252a2a
00 24252a2f
00 2c252b2b
00 24252d6d
00 24252d2d
00 24252d2e
02 2c252d2e
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 24252644
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

