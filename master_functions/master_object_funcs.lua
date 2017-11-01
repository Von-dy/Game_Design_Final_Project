--Constructors and Functions used to make objects

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
end

--create the heart boss
function heart_boss()
 boss.ct=time()
 boss.bullets={}
 boss.name="heart"
 boss.state=0
 boss.hp=1
 boss.id=1
 boss.av={}
 boss.valves={}
 for i=1,4 do
  v=make_valve(i)
  add(boss.valves,v)
 end
end

--makes the valves for the heart boss
function make_valve(n)
 lx=86
 ly=28
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

function makehitbox(x,y,w,h,name)
 hbox = {
  x=x,
  y=y,
  w=w,
  h=h
 }
 if name!=nil then hitboxes[name]=hbox add(hitboxes,hbox)
 else return hbox
 end
end

