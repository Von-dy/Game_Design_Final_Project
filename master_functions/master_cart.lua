
function _init()
 music(-1)
 sfx(-1)
 z,c=0,0 --beat speed,count
 
 --game object
 game={
   --0=menu, 1=travel, 2=boss, 3=game over
   state=0,
   frame_counter=0
 }
 --player list
 players = {}
 --hitscan list
 hitboxes = {}
 boss=generic_boss()
 makeplayer(0)
 makeplayer(1)
end

--generic boss class
function generic_boss()
 boss={
  state=0,
  hp=0,
  x=138,
  y=60,
  id=0,
  hboxes={}
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
end

--create the heart boss
function heart_boss()
 boss.ct=time()
 boss.bullets={}
 boss.name,boss.state,boss.hp,boss.id="heart",0,1,1
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
 boss.name,boss.state,boss.hp,boss.id="stomach",0,100,2

end

--makes the valves for the heart boss
function make_valve(n)
 lx,ly=86,28
 if n==2 then lx=110 ly=28 end
 if n==3 then lx=86 ly=100 end
 if n==4 then lx=110 ly=100 end
 valve={
 id=n,
 hp=50,
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
    if v.hp<50 then s=1 boss.ct=time() end
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
 boss.state=s
end

--rain clots of blood on one side of screen
function clot_attack(side)
 --generate where bullets will spawn
 for i=0,64,8 do
  tile={x=i,y=8}
  if side==1 then tile.x+=64 end
  t=rnd(5)
  if t<=3.5 then add(boss.bullets,make_bullet(tile,3,21)) end
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

function mini_heart()
 local y=flr(rnd(104))+8
 tile={x=128, y=y}
 add(boss.bullets,make_bullet(tile,10,20))
end

--for a valve, shoot a
--burst of bullets out
function valve_burst(v)
 v.sprite=16
 --make 8 bullets, 4 diagonals 4 straight
 for i=0,7 do
  add(boss.bullets,make_bullet(v,i,21))
 end
end

function move_bullets()
 for b in all(boss.bullets) do
  --save tokens
  d,x,y,hbox,dia,spd,good=b.d,b.x,b.y,b.hbox,b.dia,b.spd,true
  hx,hy=hbox.x,hbox.y
  
  --bullet collision with player
    for p in all(players) do
   if p.state~=3 and hcollide(hx,hbox.w,hy,hbox.h,p.x,p.w,p.y,p.h) then p.hp-=1 del(boss.bullets,b) good=false p.hitcooldown=120 end
  end
  
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

function col_collision(p,c)
 for i=p.x+3,p.x+6 do
  for j=p.y+3,p.y+6 do
   if pget(i,j)==c then p.hp-=1 end
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
   --0=grounded, 1=airborne, 2=crouch, 3=dodge
   state=0,
   last_action=0,
   n=slot,
   sprite=206,
   x=64,
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
   --attacking cooldown
   ac=0,
   --dodge duration
   dodge=0,
   --dodge cooldown
   dcl=60,
   hp=3,
   invulnerable=false,
   hitcooldown=0
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
 if name then hitboxes[name]=hbox add(hitboxes,hbox)
 else return hbox
 end
end

function hcollide(x1,w1,y1,h1,x2,w2,y2,h2)
 return (x2>x1+w1 or x2+w2<x1 or y2>y1+h1 or y2+h2<y1) == false
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
  if player.a==0 and player.ac<1 then
   makehitbox(x,y,10,3,"player")
   player.a=1
   player.ac=40
  end
 end
 --extend hitbox
 if player.a==1 and hitboxes["player"] then
  --track position
  hitboxes["player"].y=y+2
  --attack right
  if player.d==1 then
   hitboxes["player"].x=x+2
   if hitboxes["player"].w<50 then
    hitboxes["player"].w+=3
    player.sprite=203
   else
    player.a=2
   end
  --attack left
  else
   hitboxes["player"].x=x-(hitboxes["player"].w-4)
   if hitboxes["player"].w<50 then
    hitboxes["player"].w+=3
    hitboxes["player"].x-=3
    player.sprite=202
   else
    player.a=2
   end
  end
  --if hit boss valve
  boss_interaction(boss.id,player)
 --retract hitbox
 elseif player.a==2 and hitboxes["player"] then
  hitboxes["player"].y=y+2
  if player.d==1 then
   hitboxes["player"].x=x+2
   if hitboxes["player"].w>0 then
    hitboxes["player"].w-=3
   else
    --finish attack
    del(hitboxes,hitboxes["player"])
    player.a=0
   end
  else
   hitboxes["player"].x=x-(hitboxes["player"].w-8)
   if hitboxes["player"].w>0 then
    hitboxes["player"].w-=3
   else
    --finish attack
    del(hitboxes,hitboxes["player"])
    player.a=0
   end
  end
 end
 --attack cooldown
 if player.ac>0 then
  player.ac-=1
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
  player.invulnerable=true
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
  player.invulnerable=false
 end

 --post-hit invunerability cooldown
 if player.hitcooldown>0 then
  player.invulnerable=true
  player.hitcooldown-=1
 else
  player.invulnerable=false
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
  dx-=0.1
 elseif dx < 0 then
  dx+=0.1
 end
 if dx > -0.06 and dx < 0.06 then
  dx=0
 end

 --horizontal movement
 if not (solid(x+dx,y+dy) or solid(x+7+dx,y+dy) or solid(x+7+dx,y+6.5+dy) or solid(x+dx,y+6.5+dy)) then
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
 if solid(x,y+7) or solid(x+7,y+7) then
  y-=0.1
 end
 --update vars
 if not (x<0 or x>122) then
  player.x=x
 end
 player.y=y
 player.dx=dx
 player.dy=dy
end

function boss_interaction(id,player)
 if id==1 then
   for v in all(boss.valves) do
    vhb=v.hbox
    local hbp=hitboxes["player"]
    if hcollide(hbp.x,hbp.w,hbp.y,hbp.h, vhb.x,vhb.w,vhb.y,vhb.h) then
     player.a=2
     v.hp-=2
    end
   end
  end
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
 end
end

function boss_logic(id)
 s=boss.state
 if boss.id==1 then 
  hb_logic(s)
  heart_beat()
 end
 if boss.id==2 then
  --stomach_logic(s)
 end
 --if phase change
 if s~=boss.state then music_player(boss,boss.state) end
end

function _update60()
 game.frame_counter+=1
 if game.frame_counter>=60 then game.frame_counter=0 end
 if game.state==0 then update_menu() end
 if game.state==2 then update_game() end
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

function _draw()
 cls()
 if game.state==0 then draw_menu() end

end

function draw_menu()
 --menu background
 --map(0,0,0,0,16,16)
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
 if game.state==0 then 
  if p.n==0 then x=8 else x=68 end
  if p.curr_choice==0 then p.syringe.p_col=2 p.syringe.s_col=8 end
  if p.curr_choice==1 then p.syringe.p_col=1 p.syringe.s_col=12 end
  if p.curr_choice==2 then p.syringe.p_col=3 p.syringe.s_col=11 end
  if p.curr_choice==3 then p.syringe.p_col=4 p.syringe.s_col=9 end
 else
  x=p.x
  y=p.y
 end
 spr(7, x, y, 5, 1)
 
 if p.curr_choice==0 then p.syringe.p_col=2 p.syringe.s_col=8 end
 if p.curr_choice==1 then p.syringe.p_col=1 p.syringe.s_col=12 end
 if p.curr_choice==2 then p.syringe.p_col=3 p.syringe.s_col=11 end
 if p.curr_choice==3 then p.syringe.p_col=4 p.syringe.s_col=9 end
 
 rectfill(x+9, y+1, x+41, y+6, p.syringe.p_col)
 rectfill(x+42, y+2, x+42, y+5, p.syringe.p_col)
 rectfill(x+43, y+3, x+43, y+4, p.syringe.p_col)

 if game.frame_counter<30 then 
  if game.frame_counter%12==0 then p.syringe.circ_1+=.5 end
  if game.frame_counter%15==0 then p.syringe.circ_2+=.5 end
  if game.frame_counter%14==0 then p.syringe.circ_3+=.5 end
  if game.frame_counter%13==0 then p.syringe.circ_4+=.5 end
  if p.syringe.circ_1==3 then p.syringe.circ_1=0 end
  if p.syringe.circ_2==3 then p.syringe.circ_2=0 end
  if p.syringe.circ_3==3 then p.syringe.circ_3=0 end
  if p.syringe.circ_4==3 then p.syringe.circ_4=0 end
 end
 if game.frame_counter<30 then
  circfill(x+10, y+5-p.syringe.circ_1, 1, p.syringe.s_col)
  circ(x+19, y+5-p.syringe.circ_2, 1, p.syringe.s_col)
  circfill(x+29, y+5-p.syringe.circ_3, 1, p.syringe.s_col)
  circ(x+38, y+5-p.syringe.circ_4, 1, p.syringe.s_col)
 else
  circ(x+11, y+5-p.syringe.circ_1, 1, p.syringe.s_col)
  circfill(x+20, y+5-p.syringe.circ_2, 1, p.syringe.s_col)
  circ(x+28, y+5-p.syringe.circ_3, 1, p.syringe.s_col)
  circfill(x+37, y+5-p.syringe.circ_4, 1, p.syringe.s_col) 
 end 
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
 draw_eyes(boss.state, 88, 56, 4, 12, 2, 8)
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

 function draw_valves()
  sspr(80, 0, 8, 8, 108, 8, 8, 38)
  sspr(80, 8, 8, 8, 108, 74, 8, 38)
  sspr(80, 0, 8, 8, 84, 8, 8, 38)
  sspr(80, 8, 8, 8, 84, 74, 8, 38)
 end
