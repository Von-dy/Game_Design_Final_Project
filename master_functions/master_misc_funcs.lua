-- Collision Detection, Timers, Trackers, Math, Reusable Misc

function solid(x,y)
 val=mget(x/8,y/8)
 return fget(val,0)
end

function heart_beat()
 z+=.045+(.02*boss.state)
 if z>1 then z=0 end
 if cos(z)==1 then 
  c+=1 
  if c==3 then 
   c=0 
  else
   if boss.state==0 then
    sfx(0)
   end
  end
 end
end
