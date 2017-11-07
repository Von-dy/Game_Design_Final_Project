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
 makeplayer(0)
 makeplayer(1)
 boss=generic_boss()
end

--update60

function _update60()
 game.frame_counter+=1
 if game.frame_counter>=60 then game.frame_counter=0 end
 if game.state==0 then update_menu() end
 if game.state==2 then update_game() end
end

--draw

function _draw()
 cls()
 if game.state==0 then draw_menu() else
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
end
