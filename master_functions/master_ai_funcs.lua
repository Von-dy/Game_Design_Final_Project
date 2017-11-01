--Decision making and attack logic for bosses

--determining what the heart boss does based on state
function hb_logic(s)
 timer=time()-boss.ct
 --check valve hp
 for v in all(boss.valves) do
  if v.hp<=0 then del(boss.valves,v) end
 end
 --if state 0 do nothing until attacked
 if s==0 then
  for v in all(boss.valves) do
   if v.hp<50 then s=1 end
  end
 end
 
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
  if timer%10==0 and boss.av.x then
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
  if timer%5==0 and boss.av.x then
   valve_burst(boss.av)
  end
         
  --determine side player is on
  --left(0) right(1)
  if t.x<=60 then side=0 else side=1 end
  --every 5 seconds do a clot attack
  if timer%5==0 then
   clot_attack(side)
  end

  --every 6 seconds do a mini heart
  if timer%6==0 then
   mini_heart()
  end    
 
 --move whatever bullets have been shot
 move_bullets()
 --update boss state
 boss.state=s
end

--makes a mini heart that travels across the screen
function mini_heart()
 local y=flr(rnd(104))+8
 tile={x=128, y=y}
 add(boss.bullets,make_bullet(tile,10,20))
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

--for a valve, shoot a
--burst of bullets out
function valve_burst(v)
 v.sprite=16
 --make 8 bullets, 4 diagonals 4 straight
 for i=0,7 do
  b=make_bullet(v,i)
  add(boss.bullets,b)
 end
end

function move_bullets()
 for b in all(boss.bullets) do
  --save tokens
  d=b.d
  x=b.x
  y=b.y
  hbox=b.hbox
  hx=hbox.x
  hy=hbox.y
  dia=b.dia
  spd=b.spd
  good=true

  --bullet collision with player
  for p in all(players) do
   if hcollide(hx,hbox.w,hy,hbox.h,p.x,p.w,p.y,p.h) then p.hp-=1 del(boss.bullets,b) good=false end
  end

  if good then
   --delete bullets out of bounds
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
