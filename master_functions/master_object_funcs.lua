--Constructors and Functions used to make objects

function generic_boss()
 boss={
  state=0,
  hp=0,
  x=138,
  y=60,
  id=0
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
 boss.sprite=17
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
 lx=96
 ly=22
 if n==2 then lx=120 ly=22 end
 if n==3 then lx=96 ly=100 end
 if n==4 then lx=120 ly=100 end
 valve={
 id=n,
 hp=50,
 x=lx,
 y=ly,
 sprite=16,
 bullets={}
 }
 return valve
end

--make a bullet for some owner in some direction
function make_bullet(o,d)
 b={
 x=o.x,
 y=o.y,
 d=d,
 sprite=21,
 spd=1
 }
 return b
end

--make a bullet that moves diagonally
function make_diagonal_bullet(o,diag)
 b={
 x=o.x,
 y=o.y,
 dia=diag,
 sprite=17,
 spd=1
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
 hitboxes[name]=hbox
 add(hitboxes,hbox)
end