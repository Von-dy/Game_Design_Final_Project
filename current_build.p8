pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
function set_pos(o,newx,newy)
 o.x=newx
 o.y=newy
end

--change map
function set_area(x,y)
 for i=0,15 do
  for j=0,15 do
   mset(i,j,mget(i+x,j+y))
  end
 end
end

function print_quote(q,width,startx,starty,col)
 local length=#q/width
 --every row
 for i=0,length do
  print(sub(q,i*width,(i+1)*width-1),startx,i*8+starty,col)
 end
end

function make_attack(fun,t1,t2,t3,t4)
 local a={
  fun=fun,
  t1=t1,
  t2=t2,
  t3=t3,
  t4=t4
 }
 add(boss.attacks,a)
end

function _init()
 music(-1)
 sfx(-1)
 quotes={"a virus is a small infectious agent that replicates only inside the living cells of other organisms. viruses can infect all types of life forms, from animals and plants to microorganisms, including bacteria and archaea","the heart is a muscular organ in most animals, which pumps blood through the blood vessels of the circulatory system. blood provides the body with oxygen and nutrients, as well as assists in the removal of metabolic wastes. in humans, the heart is located between the lungs, in the middle compartment of the chest","the brain is an organ that serves as the center of the nervous system in all vertebrate and most invertebrate animals. the brain is located in the head, usually close to the sensory organs for senses such as vision. the brain is the most complex organ in a vertebrate's body. in a human, the cerebral cortex contains approximately 15-33 billion neurons, each connected by synapses to several thousand other neurons.","the lungs are the primary organs of the respiratory system in humans and many other animals including a few fish and some snails. in mammals and most other vertebrates, two lungs are located near the backbone on either side of the heart. their function in the respiratory system is to extract oxygen from the atmosphere and transfer it into the bloodstream, and to release carbon dioxide from the bloodstream into the atmosphere, in a process of gas exchange.","the stomach is a muscular, hollow organ in the gastrointestinal tract of humans and many other animals, including several invertebrates. the stomach has a dilated structure and functions as a vital digestive organ. in the digestive system the stomach is involved in the second phase of digestion, following mastication (chewing). ","there is nothing so patient, in this world or any other, as a virus searching for a host","it's in the misery of some unnamed slum that the next killer virus will emerge.","viruses have no morality, no sense of good and evil, the deserving or the undeserving.... aids is not the swift sword with which the lord punishes the evil practitioners of male homosexuality and intravenous drug use. it is simply an opportunistic virus that does what it has to do to stay alive.","the fact that, with respect to size, the viruses overlapped with the organisms of the biologist at one extreme and with the molecules of the chemist at the other extreme only served to heighten the mystery regarding the nature of viruses. then too, it became obvious that a sharp line dividing living from non-living things could not be drawn and this fact served to add fuel for discussion of the age-old question of ?what is life?'","when there are too many deer in the forest or too many cats in the barn, nature restores the balance by the introduction of a communicable disease or virus.","the average adult heart beats 72 times a minute; 100,000 times a day; 3,600,000 times a year; and 2.5 billion times during a lifetime.","every day, the heart creates enough energy to drive a truck 20 miles. in a lifetime, that is equivalent to driving to the moon and back.","the stomach serves as a first line of defense for your immune system. it contains hydrochloric acid, which helps to kill off bacteria and viruses that may enter with the food you eat."}
 set_area(16,0)
 lbx,lby,z,c,going_to=0,0,0,0,0 --beat speed,count
 --game object
 boss_list={"entrance","heart","stomach","lungs","brain"}
 game={
   --0=pmenu, 1=travel, 2=boss, 3=game over, 4=main menu, 5=transition
   state=4,
   frame_counter=0,
   playerct=1,
   screenshake=0,
   camx=0,
   camy=0,
   b_remaining={2} --for testing
 }
 --player list
 players = {}
 --hitscan list
 hitboxes = {}
 --particles
 particles = {}
 boss=generic_boss(0,0,0,0,100,60,0)
end

function init_overworld()
 going_to=1
 set_area(32,16)
 music(16)
 for p in all(players) do
  if p.hp>0 then set_pos(p,8,104) end
 end
 --set game state to overworld
 game.state=1
 if game.prev_boss then game.prev_boss=boss.id else game.prev_boss=0 end
 if #game.b_remaining!=0 then
  --game.next_boss=2
  game.next_boss=game.b_remaining[flr(rnd(#game.b_remaining))+1]
  del(game.b_remaining, game.next_boss)
 else
  game.next_boss=4 --if all bosses done, run next_boss
 end
end

--generic boss class
function generic_boss(bx,by,s,h,x,y,id)
 lbx,lby=bx,by
 boss={
  state=s,
  hp=h,
  x=x,
  y=y,
  id=id,
  hboxes={},
  attacks={},
  bullets={},
  hitcooldown=0,
  ct=time(),
  dt=time()
 }
 return boss
end

--determines what boss
--is being fought based on id (n)
function make_boss()
 game.state=2
 local n=game.next_boss
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
 for p in all(players) do
  p.scores[boss.id]=scoreboard()
 end
end

--create the heart boss
function heart_boss()
 boss=generic_boss(256,0,0,1,100,60,1)
 boss.av={}
 boss.valves={}
 for i=1,4 do
  v=make_valve(i)
  add(boss.valves,v)
 end
 for p in all(players) do
  set_pos(p,8,104)
 end
 make_attack(clot_attack,10,0,5,0)
 make_attack(vb,10,7,10,8)
 make_attack(valve_burst,10,0,10,0)
 make_attack(mini_heart,999,0,6,0)
end

function stomach()
 boss=generic_boss(384,0,0,60,95,70,2)
 boss.healthbox=makehitbox(76,40,44,44)
 boss.enzymes={}
 boss.hurtboxes={}
 for p in all(players) do
  set_pos(p,10,90)
 end
 make_attack(wave,10,0,10,0)
 make_attack(spawn_food,8,0,4,0)
 make_attack(spawn_enzyme,11,0,6,0)
end

function lungs()
 boss=generic_boss(0,128,0,100,100,60,3)
 for p in all(players) do
  set_pos(p,14,104)
 end
 boss.d,boss.blow=3,0
 boss.bullets={}
 boss.hboxes= {}
 lhb,rhb,mhb=makehitbox(30,40,28,56),makehitbox(69,40,28,56),makehitbox(56,8,16,65)
 add(boss.hboxes,lhb)
 add(boss.hboxes,rhb)
 add(boss.hboxes,mhb)
 lby=128
 make_attack(change_direction,10,0,10,0)
 make_attack(spawn_debris,3,0,2,0)
 make_attack(safespace,999,0,15,6)
 make_attack(hurt_space,999,0,15,0)
end

--makes the valves for the heart boss
function make_valve(n)
 lx,ly,vsx,vsy=86,8,0,96
 if n==2 then lx=106 ly=8 vsx,vsy=0,96 end
 if n==3 then lx=86 ly=74 vsx,vsy=0,104 end
 if n==4 then lx=106 ly=74 vsx,vsy=0,104 end
 valve={
 id=n,
 hp=20,
 x=lx,
 y=ly,
-- sprite=16,
 bullets={},
 hbox=makehitbox(lx,ly,8,38),
 sx=vsx,
 sy=vsy
 }
 return valve
end

--make a bullet for some owner in some direction
function make_bullet(o,d,sp,w,h,offx,offy)
 local sp=sp or 48
 local w=w or 4
 local h=h or 4
 local offx=offx or 2
 local offy=offy or 2
 b={
 x=o.x,
 y=o.y,
 d=d,
 sprite=sp,
 spd=1,
 hbox=makehitbox(o.x+offx,o.y+offy,w,h)
 }
 return b
end

function stomach_logic(s)
 if boss.hp==60 then s=0
 elseif boss.hp>30 then s=1
 elseif boss.hp<=30 then s=2 end

 for w in all(boss.hurtboxes) do
  if w.h<=0 then del(boss.hboxes,w)
  elseif time()-w.spawn_time<2 then w.h=2
  elseif time()-w.spawn_time<5 then w.h+=.5 w.y-=.5
  elseif time()-w.spawn_time>5 then w.h-=.4 w.y+=.4
  end
 end
 boss.state=s

end

--determining what the heart boss does based on state
function hb_logic(s)

 --if all valves destroyed
 if #boss.valves==0 then
  boss.hp=0
  --init_overworld() --added for overworld
 end

 --check valve hp
 for v in all(boss.valves) do
  if v.hp<20 then s=1 end
  if v.hp<=0 then del(boss.valves,v) game.screenshake=40 end
 end

 if #boss.valves<3 then s=2 end

 boss.state=s
end

--lungs logic
function lungs_logic(s)
 if boss.hp==100 then s=0 end

 if boss.hp<100 then s=1 end

 if boss.hp<=66 then s=2 end

 for b in all(boss.bullets) do
  b.d=boss.d
 end

 blow(boss.d)
 boss.state=s
end

function hurt_space()
 if boss.safe_space then
  local ss=boss.safe_space
  for p in all(players) do
   if p.hitcooldown==0 and not (p.state==3 or hcollide(p,ss)) then
     game.screenshake=5
     p.hp-=1
     p.hitcooldown=100
   end
  end
  boss.safe_space=nil
  --for par in all(particles) do
--   if par.sp==56 then del(particles,par) end
 -- end
 end
end

function change_direction()
 local direction=flr(rnd(4))
 while direction==boss.d do
  direction=flr(rnd(4))
 end
 boss.d=direction
end

function safespace()
 local id=flr(rnd(4))
 local safe_space=makehitbox(8,66,16,14)
 if id==1 then
  safe_space=makehitbox(36,98,16,14)
 end
 if id==2 then
  safe_space=makehitbox(92,98,16,14)
 end
 if id==3 then
  safe_space=makehitbox(104,66,16,14)
 end
 --safe_space={x1=x1,x2=x2,y1=y1,y2=y2}
 boss.safe_space=safe_space
end

--[[function make_ss(x1,x2,y1,y2)
 safe_space={x=x1,x2=x2,y1=y1,y2=y2,h=y2-y1,w=x2-x1}
 return safe_space
end]]

function spawn_debris()
 local tile={x=0,y=rnd(56)+48}
 if boss.d==0 then tile.x=128 end
 local c=make_bullet(tile,boss.d)
 c.spd=.2
 add(boss.bullets,c)
end

function blow(d)
 for p in all(players) do
  if p.state~=3 then
   --left
   if d==0 then
    if p.x>1 and not solid(p.x+1,p.y) then p.x-=.3 end
   end
   --right
   if d==1 then
    if p.x<119 and not solid(p.x-1,p.y) then p.x+=.3 end
   end
   --center
   if d==2 then
    if p.x>=64 and not solid(p.x-1,p.y) then p.x-=.3
    elseif not solid(p.x+1,p.y) then p.x+=.3 end
   end
  end
 end
end

function wave()
 --which pit to spawn from
 local side=flr(rnd(2))
 local x=32
 local y=120
 if side==1 then x=96 end
 local w=makehitbox(x,y,8,1)
 w.spawn_time=time()
 add(boss.hurtboxes,w)
end

function spawn_food()
 local t=players[1]
 if t.hp==0 then t=players[2] end
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

function spawn_enzyme()
 local i=flr(rnd(2))+20
 local sp=199
 if i==21 then sp=200 end
 local tile={x=112,y=16}
 local e=make_bullet(tile,i,sp,6,6,1,0)
 e.spawn=time()
 e.state=0
 e.isgrabbable=true
 add(boss.bullets,e)
end

--rain clots of blood on one side of screen
function clot_attack()
 --generate where bullets will spawn
 local side=flr(rnd(2))
 for i=0,64,8 do
  tile={x=i,y=8}
  if side==1 then tile.x+=64 end
  t=rnd(5)
  if t<=3.5 then add(boss.bullets,make_bullet(tile,3)) end
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
  if id==v.id then boss.av=v end
 end
end

--shoot a mini heart across the screen
function mini_heart()
 for i=0,3 do
  local y=flr(rnd(104))+8
  tile={x=128, y=y}
  add(boss.bullets,make_bullet(tile,10,23))
 end
end

--for a valve, shoot a
--burst of bullets out
function valve_burst()
 local v=boss.av
 --make 8 bullets, 4 diagonals 4 straight
 for i=0,7 do
  if v.x then
   local b=make_bullet(v,i)
   local seed=flr(rnd(32))
   b.y+=seed
   b.hbox.y+=seed
   add(boss.bullets,b)
  end
 end
 del(boss,boss.av)
end

function move_items()
 for p in all(players) do
  if p.item then
	  local i=p.item
	  if i.x<0 or i.x>128 then i=nil
	  elseif i.isgrabbable==true then 
	   i.x,i.y,i.hbox.x,i.hbox.y=p.x,p.y,p.x,p.y
	  elseif i.isgrabbable==false then
	   local ispd=-1
	   if i.d==1 then ispd=1 end
	   i.x+=ispd
	   i.hbox.x+=ispd 
	  end
	  p.item=i
	 end
 end
end

function move_bullets()
 for b in all(boss.bullets) do
  --save tokens
  d,x,y,hbox,dia,spd,good=b.d,b.x,b.y,b.hbox,b.dia,b.spd,true
  hx,hy=hbox.x,hbox.y

  --bullet collision with player
  for p in all(players) do
   if p.hitcooldown==0 and p.state~=3 and hcollide(hbox,p) then
    p.hp-=1
    del(boss.bullets,b)
    good=false
    p.hitcooldown=120
    p.scores[boss.id].hitstaken+=1
    game.screenshake=8
   end
   if attackcollide(p,hbox) and b.isgrabbable==true then
    p.item=b
    del(boss.bullets,b)
   end
  end

  --don't touch safe space
  if boss.safe_space then 
   if hcollide(boss.safe_space,hbox) then del(boss.bullets,b) end
  end

  --if no collide with player
  if good then
   --delete bullets
   if x>128 or x<0 or y>128 or y<0 or solid(hbox.x,hbox.y) or solid(hbox.x+hbox.w, hbox.y+hbox.h) then del(boss.bullets,b)
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

   --enzymes
   if d==20 then
    if b.state==0 then
     x-=1
     hx-=1
     for p in all(players) do
      if x<p.x+6 and x>p.x-6 then b.state=1 end
     end
    --if same axis as a player, attack
    elseif b.state==1 then y+=1 hy+=1 end
   end

   if d==21 then
    --move along vertically
    if b.state==0 then
     y+=1
     hy+=1
     for p in all(players) do
      if y<p.y+6 and y>p.y-6 then b.state=1 end
     end
    --if on same axis as player
    elseif b.state==1 then x-=1 hx-=1 end
   end

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

function makehitbox(x,y,w,h)
 local hbox = {
  x=x,
  y=y,
  w=w,
  h=h
 }
 return hbox
end

--hurt collision
function hcollide(o1,o2)
 local x1=o1.x
 local w1=o1.w
 local y1=o1.y
 local h1=o1.h
 local w2=o2.w
 local x2=o2.x
 local y2=o2.y
 local h2=o2.h
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
  h=3
  --crawl (feel free to delete, just set dx=0)
  if dx~=0 then
   dx-=(dx/8)
  end
 else
  h=7
 end

 --attack
 if btn(4,n) then
  --start attack if not attacking
  if a==0 and ac<1 and not player.item then
   player.hitbox=makehitbox(x,y,10,3)
   hbox,a,ac,player.last_action=player.hitbox,1,40,4
  end
  if player.item and player.last_action==0 and player.item.isgrabbable==true then
   player.item.isgrabbable=false
   player.item.d=player.d
  end
 else 
  player.last_action=0
 end

 --extend hitbox
 if player.a==1 then
  --track position
  hbox.y=y+2
  --attack right
  if d==1 then
   --sfx(0)
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

 --interact
 if btnp(5,n) then
  if game.state~=1 then
   --dodge
   if dcl==0 then
    dflag=1
    state=3
    dcl=100
   end
  else
   if dflag==0 then dflag=1 else dflag=0 end
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
  if player.hitcooldown==0 then player.hp-=1 player.hitcooldown=120 game.screenshake=8 end
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
   vhb=v.hbox
   if attackcollide(player,vhb) then v.hp-=1 end
  end
 end
 --stomach interaction
 if id==2 then
  if attackcollide(player,boss.healthbox) then boss.hp-=1 end
  if player.hitcooldown==0 and fget(mget(player.x/8,player.y/8),4) then player.hp-=1 player.hitcooldown=60 end
  for wave in all(boss.hurtboxes) do
   if player.hitcooldown==0 and hcollide(player,wave) then player.hp-=1 player.hitcooldown=60 end
  end
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
 if hbp.x and boss.hitcooldown==0 and hcollide(hbp,hb) then
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
 --no music in first phase
 if state==0 then music(-1) end
 --explosion sounds
 if state==3 then music(14) end

 --heart boss
 if boss.id==1 then
  if state==1 then music(0) end
 end

 --stomach
 if boss.id==2 then
  if state==1 then music(4) end
 end

 --lungs
 if boss.id==3 then
  if state==1 then music(8) end
 end
end

function boss_logic(id)
 if boss.ct%30==0 then boss.ct=time() end
 local boss_timer=time()-boss.ct+1
 local t=players[1]

 local s=boss.state
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

 --do attacks
 for a in all(boss.attacks) do
  --what boss phase
  if boss.state==1 then
   if boss_timer%a.t1==a.t2 then
    a.fun()
   end
  end
  if boss.state==2 then
   if boss_timer%a.t3==a.t4 then
    a.fun()
   end
  end
 end
 move_bullets()
 move_items()
 --if phase change
 if s~=boss.state then
  if s==0 then game.screenshake=60 end
  music_player(boss,boss.state)
 end
 if boss.hitcooldown>0 then
  boss.hitcooldown-=1
 end
 --check if boss is dead
 if boss.hp<1 then
  boss.dt=time()
  game.state=6
  music_player(boss,3)
 end
end

function _update60()
 game.frame_counter+=1
 if game.frame_counter>=60 then game.frame_counter=0 end
 if game.state==0 then update_menu() end
 if game.state==1 then update_overworld() end
 if game.state==2 then update_game() end
 if game.state==3 then update_gameover() end
 if game.state==4 then update_mainmenu() end
 if game.state==5 then update_transition() end
 if game.state==6 then update_bossdeath() end
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
 if ready_count==#players then init_transition(0) end
 --init_overworld() end
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

function update_overworld()
 local count=0
 for p in all(players) do
  text=nil
  groundmovement(p)
  update_player_sprite(p)
  --player can interact with shop
  if p.x>48 and p.x<72 then 
   if btn(5,p.id) then
    text="it would be sick if i had a minigame for you, enjoy some health instead"
    for p in all(players) do
     if p.hp==0 then p.hp=3 set_pos(p,8,60) else p.hp=3 end
    end
   end
  end
  --player can interact next boss
  if p.x>88 and p.x<120 then
   if btn(5,p.id) then count+=1 end
   if count==#players then init_transition(1) end
  end
 end
end

function update_game()
 count=0
 for p in all(players) do
   if p.hp<=0 then
    count+=1
    if p.hitbox then del(p.hitbox) end
   end
   if game.playerct==1 then
    if count>0 then music(15) game.state=3 end
   else
    if count==2 then music(15) game.state=3 end
   end
   if p.hp>0 then
    groundmovement(p)
    boss_interaction(boss.id,p)
    update_player_sprite(p)
   else p.x=-20 end
  end
  --determine what boss you are fighting
  --if boss.id==0 then make_boss(3) end
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

function update_bossdeath()
 tick=time()
 if tick-boss.dt>6 then
  init_transition(0)
 end
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==2 then sfx(0) end if c==3 then c=0 end end
end

function _draw()
 cls()
 map(0,0,0,0,16,16)
 cameffects()
 if game.state==0 then draw_menu() end
 if game.state==2 or game.state==1 then draw_game() end
 if game.state==3 then draw_gameover() end
 if game.state==4 then draw_mainmenu() end
 if game.state==5 then draw_transition() end
 if game.state==6 then draw_game() draw_explosions() end
 --print(game.state,0,0,9)
end

function init_transition(d)
 music(-1)
 going_to=d
 game.state=5
 boss.ct=time()
 set_area(64,0)
 random_quote=quotes[flr(rnd(#quotes))+1]
end

function update_transition()
 if btnp(5) and time()-boss.ct>1 then
  if going_to==0 then init_overworld()
  else make_boss()
  end
 end
end

function draw_transition()
 print_quote(random_quote,30,0,1,9)
 print("press x to continue",48,120,7)
end

function draw_mainmenu()
 --title
 print("viral",54,30,3)
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

function draw_overworld()
 local prev=game.prev_boss
 local next=game.next_boss
 --draw left door
 circ(16, 98, 12, 2)
 circfill(16,98,11,8)
 --draw right door
 circ(110, 98, 12, 2)
 circfill(110,98,11,8)

 --spr of sign planks
 if text then print_quote(text,20,35,35,7) end

 --prints for signs
 print(boss_list[prev+1], 3, 72, 11)
 print(boss_list[next+1], 99, 72, 11)

 --print instructions for game, only on first entrance of overworld
--if no previous boss, then do these
  if game.prev_boss==0 and not text then
    print("controls:",40,20,7)
    print("player 1",2,28,7)
    print("arrows to move",2,36,7)
    print("z to attack",2,44,7)
    print("x to dodge",2,52,7)
  end
--if two players then do these too
  if p.n==1 and not text then
    print("player 2",62,28,7)
    print("esdf to move",62,36,7)
    print("lshift to attack",62,44,7)
    print("a to dodge",62,52,7)
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
  print("controls:", x+5, y+27)
  print("arrow keys", x+5, y+38)
  print("z=attack", x+5, y+46)
  print("x=dodge", x+5, y+54)

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
  print("controls:", x+5, y+27)
  print("e,s,d,f", x+5, y+38)
  print("lshift=attack", x+5, y+46)
  print("a=dodge", x+5, y+54)
 end

  --code for controller layout
  --print("d-pad=cycle", x+5, y+1)
  --print("x=lock", x+5, y+9)
  --print("controls:", x+5, y+22)
  --print("d-pad=move", x+5, y+30)
  --print("x=attack", x+5, y+38)
  --print("o=dodge", x+5, y+46)

 --changes start screen design to menu screen design
 for n=0, 128 do
  spr(89,n,56)
  pal(15,6,0)
 end
end

function draw_game()
 if game.state~=1 then draw_boss() end
 if game.state==1 then draw_overworld() end
 draw_players()
 draw_hud(boss.id)
 --[[if players[1].hbox then
  print(players[1].hbox.x,0,0,2)
 end]]
end

function draw_players()
 --debug stuff
 --print(players[1].scores[boss.id].timer,5,2)
 --print(players[1].x,20,2,7)
 --print(players[1].y,80,2)
 for p in all(players) do
  local p_cc=p.curr_choice
  local p_hb=p.hitbox
  local pcol=0
  local scol=0
  if p.item then spr(p.item.sprite,p.item.x,p.item.y) end 
  
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
    if game.state!=1 then
      rectfill(0,4,128,6,8)
      rectfill(0,4,(hpleft/80)*128,6,3)
      rect(0, 3, 128, 7, 0)
    end
 --end heart boss drawing
 end
 --stomach boss
 if id==2 then
   if game.state!=1 then
     rectfill(0,4,128,6,8)
     rectfill(0,4,(boss.hp)/60*128,6,3)
     rect(0, 3, 128, 7, 0)
   end
 end
 for p in all(players) do
  tempx= -8
  if p.n==1 then tempx=96 end
  if p.hp>0 then
   for h=1,p.hp do
     if p.curr_choice==0 then spr(24,tempx+h*8,119) end
     if p.curr_choice==1 then spr(25,tempx+h*8,119) end
     if p.curr_choice==2 then spr(32,tempx+h*8,119) end
     if p.curr_choice==3 then spr(40,tempx+h*8,119) end
   end
  end
 end
 --lung boss
 if id==3 then
   if game.state!=1 then
     rectfill(0,4,128,6,8)
     rectfill(0,4,(boss.hp/100)*128,6,3)
     rect(0, 3, 128, 7, 0)
  end
 end
 --print(#boss.attacks,100,60)
end

function draw_boss()
 if boss.id==1 then draw_heart() end
 if boss.id==2 then draw_stomach()
  draw_food()
  for w in all(boss.hurtboxes) do
   sspr(72, 24, 8, 8, w.x, w.y, w.w, w.h)
   --rectfill(w.x,w.y,w.x+w.w,w.y+w.h,9)
   --spr(57, w.x, w.y)
  end
 end
 if boss.id==3 then
  draw_lungs()
  draw_smoke(boss.safe_space)
  if boss.safe_space then
   ss=boss.safe_space
   --rect(ss.x,ss.y,ss.x+ss.w,ss.y+ss.h,3)
   sspr(0,120,8,8,ss.x-4,ss.y-4,24,24)
  end
 end
 draw_bullets()
 --if boss.id==4 then draw_brain() end
end

function draw_food()
 --apple
 sspr(8,96,16,16,0,112,24,16)
 --plum
 sspr(8,112,8,8,112,112,16,16)
 --banana
 sspr(24,104,16,16,56,112,24,16,false,true)
end

function draw_heart()
 for valve in all(boss.valves) do
  sw=8
  if valve==boss.av then sw=10 end
  sspr(valve.sx,valve.sy,8,8,valve.x,valve.y,sw,38)
 end
 sspr(0, 64, 32, 32, 76,40, 44+c%2, 44+c%2)
 draw_eyes(boss.state, 88, 56, 4, 12, 2, 8)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
end

function draw_stomach()
 sspr(32, 64, 32, 32, 76, 40, 44, 44)
 sspr(8, 120, 8, 8, 93, 0, 10, 40)
 sspr(8, 120, 8, 8, 80, 80, 10, 35, false, true)
 draw_eyes(boss.state, 92, 56, 4, 12, 3, 11)
 draw_lips(boss.state, 91, 72, 16, 1, 5)
end

function draw_lungs()
--rib cage
for i=16, 64, 14 do
 local s_down=i/8
 sspr(56, 109, 33, 15, 64, i, 72-s_down, 22-s_down/2)
 sspr(56, 109, 33, 15, -8+s_down, i, 72-s_down, 22-s_down/2, true)
end
--mid cage
for i=72, 128, 9 do
 sspr(80,100, 16, 8, 56, i)
end

 --trachea
 sspr(0, 112, 6, 8, 56, 8, 16, 64)
 --left lung
 sspr(65, 66, 13, 28, 31, 40, 26, 56)
 --right lung
 sspr(82, 66, 13, 28, 71, 40, 26, 56)
 draw_eyes(boss.state, 48, 56, 6, 31, 14, 8)
 --mood, x, y, length, primary_col, secondary_col
 draw_lips(boss.state, 53, 68, 21, 1, 14)
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

function draw_explosions()
 game.screenshake=5
 for i=0,15 do
  x,y,s=rnd(128),rnd(128),rnd(8)
  sspr(56,24,8,8,x,y,8*s,8*s)
 end
end

function draw_smoke(safe)
 --make cloud
 if game.frame_counter%15==0 and safe~=nil then
  validx=false
  while not validx do
   rx=rnd(116)
   if rx<safe.x-10 or rx>safe.x+safe.w then validx=true end
  end
  cloud={
   sp=56,
   x=rx,
   y=120,
   s=rnd(2)+1
  }
  add(particles,cloud)
 end
 --draw clouds
 for c in all(particles) do
  if c.sp==56 then
   sspr(64,24,8,8,c.x,c.y,8*c.s,8*c.s)
   --ascend
   c.y-=1
  end
 end
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
__gfx__
000000000000b30000003b0000000000000b33b0000b33b000003b00000077000777777777777777777777777770000000000000000000000000000000000000
0000000000b33b0000b33b00000000000b333bb00b333bb000b33b00000770007000000000000000000000000070000000000000000000000000000000000000
007007000333b3b00b3b333000000000b3733733b37337330b3b3330000770007000000000000000000000000007000000000000000000000000000000000000
0007700037373330033373730000000003b333b003b333b0337337b3000777777000000000000000000000000000700000000000000000000000000000000000
0007700003b333b00b333b3000b33b0000333b0000333b000b333b30000777777000000000000000000000000000555500000000000000000000000000000000
007007000033b300003b33000bb333b00030030000300300003b3300000770007000000000000000000000000007000000000000000000000000000000000000
0000000033b3b3b00b3b3b333373373300b0030000b00300b33b3b3b000770007000000000000000000000000070000000000000000000000000000000000000
00000000b0303030030303030b3b3b3000b00b0000b00b0030300303000770007777777777777777777777777700000000000000000000000000000000000000
00076000000820000002800000000000008228000082280000028000000000000666666006666660000000000007700077777777777777777777777777000000
00677600008228000082280000000000082228800822288000822800000000000066660000666600000000000007700070000000000000000000000000700000
06767770022282800828222000000000827227228272272208282220088088000622226006cccc60000000000007700070000000000000000000000000070000
778778672727222002227272000000000282228002822280227227828ee8ee800622226006cccc60000000000007777770000000000000000000000000007000
067776700282228008222820008228000022280000222800082228208eeeee800622226006cccc60000000000007777770000000000000000000000000005555
0076770000228200002822000882228000200200002002000028220008eee8000622226006cccc60000000000007700070000000000000000000000000070000
67767676228282800828282222722722008002000080020082282828008e800000622600006cc600000000000007700070000000000000000000000000700000
70700707802020200202020208282820008008000080080020200202000800000006600000066000000000000007700077777777777777777777777777000000
06666660000490000009400000000000004994000049940000094000000000000666666000000000000000000000000000000000000000000000000000000000
00666600004994000049940000000000049994400499944000499400000000000066660000000000000000000000000000000000000000000000000000000000
06bbbb600999494004949990000000004979979949799799049499900bbbbb000699996000000000000000000000000000000000000000000000000000000000
06bbbb60979799900999797900000000094999400949994099799749003333b00699996000000000000000000000000000000000000000000000000000000000
06bbbb60094999400499949000499400009994000099940004999490003333b00699996000000000000000000000000000000000000000000000000000000000
06bbbb600099490000949900044999400090090000900900009499000bbbbb000699996000000000000000000000000000000000000000000000000000000000
006bb600994949400494949999799799004009000040090049949494000000000069960000000000000000000000000000000000000000000000000000000000
00066000409090900909090904949490004004000040040090900909000000000006600000000000000000000000000000000000000000000000000000000000
00000000000c10000001c0000000000000c11c0000c11c000001c000055000500550550566666666000000000000000000000000000000000000000000000000
0007700000c11c0000c11c00000000000c111cc00c111cc000c11c00577505755555055069993336000000000000000000000000000000000000000000000000
00f7f7000111c1c00c1c111000000000c1711711c17117110c1c111057a957a70505555569aa3996000000000000000000000000000000000000000000000000
077fff7017171110011171710000000001c111c001c111c0117117c155799a750555505069393936000000000000000000000000000000000000000000000000
07fff77001c111c00c111c1000c11c0000111c0000111c000c111c10057797505550555563333336000000000000000000000000000000000000000000000000
007f7f000011c100001c11000cc111c00010010000100100001c1100575aa57005055550693a3a36000000000000000000000000000000000000000000000000
0007700011c1c1c00c1c1c111171171100c0010000c00100c11c1c1c557575505555050569a33996000000000000000000000000000000000000000000000000
00000000c0101010010101010c1c1c1000c00c0000c00c0010100101055057550505550069999396000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee99999999999999991111111c111111c13ffffffffffff333ffffffffff3333ff7777777766666666fffff33feeeeffeeffffffff99999999
222222222222272299ffff99f9999ff9111111c111171c1133333fffff333333fffafffffbfa773f7777777766666666fffabf73eeeefeeeffffffff99999999
e22722ee222222229999fff99fffff99117111c111717111a3333333333333aaf9fffaffb9fff7737777777766666666f9ffbaf3feefffefffffffff99999999
22222222222eee22999999ff9999999917171117111c1111aaaaa333333aaaaaffffffffbffffff37777777766666666fffffbbfefeeeeeeffffffff99999999
22e22222222222229999999ff9999ff9117111717111c111aaaaaaaaaaaaaaaffff9ffffbff9fff37777777766666666fff9ffffeffeeeeeffffffff99999999
222272eee2272222999999ff9fffff99111c111711171cc1fffffaaaafffffffffff9fffbfff9ff37777777766666666ffff9ffffeeeeeffffffffff99999999
22222222222222229999fff9999999991111c1111171c11cffffffffffff3333faffff9ffbffff3f7777777766666666faffff9feeefeeeeffffffff99999999
eeeeeeeeeeeeeeee9999999999999999c11117111117111133ffffffff333333afffffffafbbbbff7777777766666666afffffffeeffeeeeffffffff99999999
1111111111111111999999999ff999991c11717111111111333333333333333355555555ffffffff3ffffffffffff33300000000000000000000000000000000
ddddddddd7dddddd9999999999fff999117117111171cc11333333333333333355555555ffffffff33333fffff33333300000000000000000000000000000000
d7dd1dddddd11dd19999fff99999999917171111171c11c1aaa333333333aaaa55555555ffffffffa3333333333333aa00000000000000000000000000000000
ddddd11dddddd7dd999f99f9999ff9ff1171117111711111aaaaaa333aaaaaaa5555555577777777aaaaa333333aaaaa00000000000000000000000000000000
d111dddd11dd1ddd99f99f999999fff911111c1711111111fffaaaaaaaaaafff5555555577777777aaaaaaaaaaaaaaaf00000000000000000000000000000000
1dddddd1ddd1d1d1ff999f99999999991111c17111117111ffffffffffffff3355555555fffffffffffffaaaafffffff00000000000000000000000000000000
ddd7ddddd7dddddd999999f99ffff9991111c1111117171133fffffffffff33355555555ffffffffffffffffffff333300000000000000000000000000000000
11111111111111119999999999999999111c11111111c111333333333333333355555555ffffffff33ffffffff33333300000000000000000000000000000000
222222222222222200000000000000001111111111111111ff3333fffffff33fdddddddd000000000000000000000000ffffffffffffffffffffffffffffffff
222222222111222200000000000000001111d111ddc1d11df3bb773fffff3b73dddddddd000000000000000000000000ffff55ffffff55ffffffffffffffffff
112112111ddd12210000000000000000d11dd11ddddcdd1d3bbbb773ffff3bb3dddddddd000000000000000000000000ff559955ff559955ffffffffffffffff
dd1dd1ddddddd11d0000000000000000d1d7dd1ddd7d7dcd3bbbbbb3fffff33fdddddddd0000000000000000000000005599999955999999ffffffffffffffff
dddddddddddddddd0000000000000000dc7dcdcd7dd7d7d73bbbbbb3ffffffffdddddddd000000000000000000000000ff559955ff559955ffffffffffffffff
11ddddd11dddddd10000000000000000dcd7dcdcd7dddd7d3bbbbbb3ffffffffdddddddd000000000000000000000000ffff55ffffff55ffffffffffffffffff
221ddd1221111d1200000000000000007d7ddddd7dddddddf3bbbb3fffffffffdddddddd000000000000000000000006ffffffffffffffffffffffffffffffff
22211122222221220000000000000000d7ddddddddddddddff3333ffffffffffdddddddd000000000000000066666666f555f555f555f555ffffffffffffffff
deeeeeedd111111d0000000000000000d1d1d1d1d1d1d1ddffffffffffffffff111111110000000006666666666666665999599959995999ffffffffffffffff
e222222e1cccccc100000000000000001111111111111111ffffffffffffffff11111111006666666677767766666666f555f555f555f555ffffffffffffffff
e2e22e2e1c1cc1c10000000000000000d17171111711c11dffffffffffffffff11111111666766777677767677666666ffffffffffffffffffffffffffffffff
e222222e1cccccc10000000000000000111711c1c171c111ffffffffffffffff11111111666767776677667677666666ffff55ffffff55ffffffffffffffffff
e2e22e2e1c1111c10000000000000000d171cc1c171c111dffffffffffffffff11111111066666666777667677666600ff559955ff559955ffffffffffffffff
e2eeee2e1c1cc1c100000000000000001111111111111111ffffffffffffffff111111110000666667766776666600005599999955999999ffffffffffffffff
e222222e1cccccc10000000000000000d1d1d1d1d1d1d1ddffffffffffffffff11111111000000006666666666000000ff559955ff559955ffffffffffffffff
deeeeeedd111111d0000000000000000ddddddddddddddddffffffffffffffff11111111000000000000000000000000ffff55ffffff55ffffffffffffffffff
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
000000228122288888222812218220000000000000222eeeeeee88222222220001e81e281ee281000011e1e8881882105e56e665556eff665fff6ee556655600
00000022211828882211281881820000000022222222eeeeeee882222222200001ee128ee8e2210000e111e22e112e105e555555655e6ff556eeee5665000000
00000002281821882181228888220000000222eeeeeeeeeeee8822222222200001eee22ee8e82e0000e112e2e222ee1056555555556eeeff55e6655555000000
00000000281122882181128822200000000282eeeeeeeeeee82222222222000001ee28eee8e82e0000e112e28ee22e105556fef655555eee6555555555000000
000000002281128218882282220000002222822eeeeeeeeee82222222220000001e282e122e82e0000ee22ee888eee10066efff55555555ee555555500000000
000000000288118218822882220000002228882eeeeeeeeee22222222200000001ee8ee128e88e00008eeeee1288ee1000055555555555655000000000000000
000000000288882218221822200000002282222eeeeeeee2222222222000000001e88e12eeeee8000088eeee11288e1000056655555555565000000000000000
000000000028888888281822000000002282eeeeeeeee222222222220000000001e8eeeee888880000088888e1112e1000006555566665550000000000000000
000000000022288888881222000000002222eeeeeeee2222222220000000000001e11ee8800000000000000088e11e1000005556665555660000000000000000
0000000000022288888112200000000022222eee88882222222000000000000001e1e8880000000000000000088eee1000005666555555500000000000000000
000000000000222881112200000000000022288888222222000000000000000001ee800000000000000000000088ee1000000665555655600000000000000000
000000000000002221222000000000000002222222222200000000000000000001e88000000000000000000000088e1000000065566550000000000000000000
00000000000000002222000000000000000022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
222c122200000bb004400000000888000009990000eeee0000ffff0000022200000888000bbbbbb0000000000000000011111111111111111111111111111111
0221c22000000bbb440000000888ff000999aa000e8888e00f22ff400002220000088800b888888b000000000000000011111111111111111111111111111111
00211200000000b44000000008fff00009aaa000e88ee882ff2ff2f40022022000880880b8b88b8b000000000000000011444444444444444444444444444411
002c1200000000040000000088ff400099aa7000e8e88282ffff42f40220002208800088b888888b0000000000000000114444444444444444444444444444f1
00211200000888848888800088fff40099aaa700e8e88282f2f44ff40200000208000008b8b88b8b0055555555555000114444444444444444444444444444f1
00211200008888888777880008ffffff09aaaaaae8822822fff22f440220002208800088b8bbbb8b0575565675675500114444444444444444444444444444f1
0021c2000888888888777800088ff888099aa999028882200f22f4400220002208800088b888888b05656656656657501144f1111111111111111111111144f1
002c120008888888888878000008880000099900002222000044440000000000000000000bbbbbb055656556656566751144f1111111111111111111111144f1
002e820008888888888888000000000000000044007777000066660000000000000000000000000057656566556566651144f1111111333311111111111144f1
0028e200088888888888880000000000000000440777776006dddd6000000000000000000000000005556566566566501144f11111133bbb11115111111144f1
0028820008888888888888000000000000000004777777766ddd6d6d00000000000000000000000005575575666555001144f111113bbcccc1151111111144f1
0028820008888888888822000000000000000999777766766dd66d6d00000000000000000000000000555555555550001144f11111b6cccc11151111111144f1
002e8200088888888882200000000000000009a9777667766dd6dd6d55550000000000000000000000000000000000001144f11113b1656511511111111144f1
0028820000888888888200000000000000009a9977767766666666dd66666555500000000000000000000000000000001144f1113331ccccc1111111111144f1
0228e22000088888822200000000000000099a990777766006666dd066566666665555000000000000000000000000001144f1113111cc4778111111111144f1
222e82220000882222000000499000000099a9a90066660000dddd0066755656666656655500000000000000000000001144f11111cc1ccc11111111111144f1
1122110000044000000440009a999000999a99a90066660000ffff0066666675666566666665550000000000000000001144f1111ce7ccecc1111111111144f1
01111000022222500bbbbb309aaa99999aaa9a99066776660feeefe055555665666666667566666550000000000000001144f1111ee1c1c9c1111111111144f1
0122100022227725bbbb77b399aaaaaaaaa99a9066727775feeffffe00000555556666675666566666500000000000001144f1111e11e19cc1111111111144f1
0111100022222775bbbbb773999999999999a99062772275feffeefe00000000005555666666756656665000000000001144f111c711ccccc1111111111144f1
0122100022222225bbbbbbb3099aaaaaaaaaa99067772275fefeeffe00000000000000555556666665666650000000001144f111e1dededd51111111111144f1
0111100022222255bbbbbb3300999aaa9999990066727775fffeffee00000000000000000005555667567565000000001144f11cceededed51111111111144f1
01221000022225500bbbb3300009999999999000066775550ffffee0000000000000000000000005556666560000000099999999999999999999999999999999
12222100005555000033330000000999990000000055550000eeee00000000000000000000000000005567560000000099999999999999999999999999999999
001111000008ee2000000000000000000000000000000000000000000000000000000000000000000000557660000000114555555555555555555555555554f1
01cc7c100222e20000000000000000000000000000000000000000000000000000000000000000000000005760000000114444444444444444444444444444f1
1c0000c102ee200000000000000000000000000000000000000000000000000000000000000000000000000566000000114222422242424444224422242424f1
1c000071002e800000000000000000000000000000000000000000000000000000000000000000000000000066000000114242424242424444242424242424f1
1c0000c1000e820000000000000000000000000000000000000000000000000000000000000000000000000006000000114222424244244444224424244244f1
1c0000c10002e82000000000000000000000000000000000000000000000000000000000000000000000000000000000114244424242424444242424242424f1
01cccc10002e222000000000000000000000000000000000000000000000000000000000000000000000000000000000114244422242424444224422242424f1
0011110002ee200000000000000000000000000000000000000000000000000000000000000000000000000000000000114444444444444444444444444444f1
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
29292929292929292929292929292929595959595959595959595959595959594141414040414041404041404041404167666767666766676f666766676f666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868686667666776677677677677766667766600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868686767766f76776f6f6f6f6f6f6f6f676f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929777777777777777777777777777777776868686868686868686868686868686866766f6f6f6f777776776e6f6f6f676600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
29292929292929292929292929292929777777777777777777777777777777776868686868686868686868686868686867766f7f7e7f7e7f7e7f7e7f7e7f676f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868717171686868686868686f6f6e6f6e6f6e6f6e6f6e6f6e6f6f6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
292929292929292929292929292929297777777777777777777777777777777768686868686868686868686868686868777f7e7f7e7f7e7f7e7f7e7f7e7f6f6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777707070686868686868686868686868686e6f6e6f6e6f6e6f6e6f6e6f6e6f6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868687e7f7e7f7e7f7e7f7e7f7e7f7e7f7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777686868686868686868686868686868684e4e4e6e6e6e6e4e4e4e4e6e6e6e4e4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292977777777777777777777777777777777404140404041414041414041404140415a5b5a474647465b5a5b464746475a5b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2929292929292929292929292929292959595959595959595959595959595959505150505051515051515051505150515657565756575657565756575657565700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
787878787878787878787878787878784a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
646564656564656465646464656464654a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878787878787878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
687475686868686868686868687475684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878cccdcecf7878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878dcdddedf7878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878ecedeeef7878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686868686868686868686868686868684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a787878787878fcfdfeff7878787878780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686844444544456868444544454568684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
686854545554556868545554555568684a4a4a4a4a4a4a4a4a4a4a4a4a4a4a4a444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 1b424344
00 1c1d4344
01 1f204344
03 1f202148
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

