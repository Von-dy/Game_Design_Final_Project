--Primary Functions for Pico8

--init

function _init()
 z=0 --beat speed
 c=0 --beat count
 tunes=0

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

--update60

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

--draw

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
  for i=0, h.w-1 do
   local col=flr(rnd(3))
   if col>1 then pset(h.x+i, 2*sin(i/h.w)+h.y+2, 3) else pset(h.x+i, 2*sin(i/h.w)+h.y+2, 11) end
  end
 end
 for b in all(boss.bullets) do
  spr(b.sprite,b.x,b.y)
 end
end
