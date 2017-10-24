--Decision making and attack logic for bosses

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
