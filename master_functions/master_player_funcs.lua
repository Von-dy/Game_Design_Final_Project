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