-- Collision Detection, Timers, Trackers, Math, Reusable Misc

function solid(x,y)
 return fget(mget(x/8,y/8),0)
end

function hcollide(x1,w1,y1,h1,x2,w2,y2,h2)
 return (x2>x1+w1 or x2+w2<x1 or y2>y1+h1 or y2+h2<y1) == false
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then c+=1 if c==3 then c=0 sfx(0,1) end end
end

function music_player(boss,state)
 --heart boss
 if boss.id==1 then
  --no music
  if state==0 then music(-1) end
  --start at track 0
  if state==1 then music(0) end
 end
end

