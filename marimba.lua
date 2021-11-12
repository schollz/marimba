-- marimba v0.0.1
-- ?
--
-- llllllll.co/t/?
--
--
--
--    ▼ instructions below ▼
--
-- ?

Lattice = require("lattice")
Part=include("marimba/lib/part")
Instrument=include("marimba/lib/instrument")

engine.name="Marimba"
local shift=false
part_num=1
par_num=1
mallet_strokes={
    -- single strokes
    "x",
    "x-",
    "x--",
    "x---",
    "x----",
    "x-----",
    "x------",
    "x-------",
    -- multiple strokes 
    "xx-",
    "x-x",
    "x-xx-xx-",
    "xx-xx-x-",
    -- roll strokes "x" = accent
    "xo",
    "xxo",
    "xox",
    "xoxo",
    "xxox",
    "xxoxxo",
    "xoxoxo",
    "xoxxoxxo",
    "xxoxxoxo",
    "xoxoxoxo",
}

function init()
  -- initialize the marimba
  marimbas={}
  marimbas[1]=Instrument:new({root=36})
  marimbas[1]:add(Part:new{stroke=16,note=9,count=0,interval=2})
--   marimbas[1]:add(Part:new{stroke=16,note=9,count=2,interval=3})
--   marimbas[1]:add(Part:new{stroke=2,note=10})
--   marimbas[1]:add(Part:new{stroke=1,note=12,count=4})
--   marimbas[1]:add(Part:new{stroke=11,note=11,count=1})
--   marimbas[1]:add(Part:new{stroke=12,note=12,count=2})
  marimbas[1]:refresh()

  -- initialize the lattice
  lattice = Lattice:new()
  patterns={}
  for i=1,#marimbas do 
    patterns[i]=lattice:new_pattern{
        division=1/16,
        action=function(t)
            local beat=t/24+1
            marimbas[1]:emit(beat)
        end,
    }
  end
  lattice:hard_restart()

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/10
  timer.count=-1
  timer.event=update_screen
  timer:start()
end

function update_screen()
  redraw()
end

function key(k,z)
  if k==1 then
    shift=z==1
  end
  if z==0 then 
    do return end 
  end
  if shift then
    if k==1 then
    elseif k==2 then
    elseif k==3 then
    end
  else
    if k==1 then
    elseif k==2 then
        lattice:stop()
    elseif k==3 then
        lattice:hard_restart()
    end
  end
end

function enc(k,d)
  if shift then
    if k==1 then
    elseif k==2 then
    else
    end
  else
    if k==1 then
      par_num=par_num+d 
      if par_num < 1 then 
          par_num=par_num+3
      end
      if par_num > 3 then 
          par_num=((par_num-1)%3)+1
      end
    elseif k==2 then
        if par_num==1 then 
        elseif par_num==2 then 
            marimbas[1].parts[part_num].note=util.wrap(marimbas[1].parts[part_num].note+d,1,17)
            marimbas[1]:refresh()
        elseif par_num==3 then 
            marimbas[1].parts[part_num].stroke=util.clamp(marimbas[1].parts[part_num].stroke+d,1,#mallet_strokes)
            marimbas[1]:refresh()
        end
    elseif k==3 then 
        if par_num==1 then 
            local pnum=util.clamp(part_num+d,1,#marimbas[1].parts+1)
            if pnum==#marimbas[1].parts+1 then 
                local p=marimbas[1].parts[pnum-1]
                marimbas[1]:add(Part:new{count=0,note=p.note,interval=p.interval,stroke=p.stroke})
            end
            part_num=pnum
        elseif par_num==2 then 
            marimbas[1].parts[part_num].interval=util.clamp(marimbas[1].parts[part_num].interval+d,0,12)
            marimbas[1]:refresh()
        elseif par_num==3 then 
            marimbas[1].parts[part_num].count=util.clamp(marimbas[1].parts[part_num].count+d,0,16)
            marimbas[1]:refresh()
        end
    end
  end
end

function redraw()
  screen.clear()
  draw_marimba()
  draw_part()
  screen.update()
end

function draw_part()
    if marimbas[1].parts[part_num]==nil then 
        do return end 
    end
    screen.level(par_num==1 and 15 or 5)
    screen.move(5,5)
    screen.text("instrument 1")
    screen.level(par_num==2 and 15 or 5)
    screen.move(5,14)
    screen.text("note: "..marimbas[1].parts[part_num].note)  
    screen.level(par_num==3 and 15 or 5)
    screen.move(5,23)
    screen.text(""..marimbas[1].parts[part_num]:get_stroke())  
    local note_names=""
    for _, note in ipairs(marimbas[1].parts[part_num]:get_notes()) do 
      note_names=note_names..note.." "
    end
    screen.level(par_num==1 and 15 or 5)
    screen.move(126,5)
    screen.text_right("part "..part_num)
    screen.level(par_num==2 and 15 or 5)
    screen.move(126,14)
    screen.text_right("interval: "..marimbas[1].parts[part_num].interval)  
    screen.level(par_num==3 and 15 or 5)
    screen.move(126,23)
    screen.text_right("x"..marimbas[1].parts[part_num].count)
    screen.move(126,64)
    if marimbas[1].part_last~=nil then 
        screen.text_right(marimbas[1].part_last)
    end
end

function draw_marimba()
    local height=32
    local width=6
    local x=2
    local ymid=34
    local top_positions={}
    local bot_positions={}
    for i=1,17 do
        local y=math.floor(ymid-height/2)
        screen.rect(x,y,width,height)
        screen.level(5)
        screen.fill()
        if marimbas[1].note_last~=nil then 
            if i==marimbas[1].note_last[1] or i==marimbas[1].note_last[2] then 
                screen.rect(x,y,width,height)
                screen.level(15)
                screen.fill()
            end
        end
        if par_num==2 then 
            if marimbas[1].parts[part_num].note==i
                or marimbas[1].parts[part_num].note+marimbas[1].parts[part_num].interval==i then 
                screen.rect(x,y,width,height)
                screen.level(15)
                screen.stroke()
            end
        end
        table.insert(top_positions,{x+width/2,y})
        table.insert(bot_positions,{x+width/2,y+height})
        height=height-1
        x=x+8
    end
    
    draw_curve(top_positions[4],top_positions[9],30)
    draw_curve(bot_positions[9],bot_positions[3],20)
    draw_curve(bot_positions[9],bot_positions[3],30)
    draw_curve(bot_positions[9],bot_positions[3],35)
    -- draw line from 4 to 8
    marimbas[1].note_last=nil
end

function draw_curve(p1,p2,d)
    local p=perpendicular_points(p1,p2,d)
    screen.move(p1[1],p1[2])
    screen.curve((p[1]+p1[1])/2,(p[2]+p1[2])/2,(p[1]+p2[1])/2,(p[2]+p2[2])/2,p2[1],p2[2])
    screen.stroke()
end
-- https://math.stackexchange.com/a/995675
function perpendicular_points(p1,p2,d)
  local p3={{0,0},{0,0}}
  for i=1,2 do
    p3[1][i]=(p1[i]+p2[i])/2
    p3[2][i]=(p1[i]+p2[i])/2
  end
  local factor=d/math.sqrt((p2[2]-p1[2])^2+(p2[1]-p1[1])^2)
  local i=1
  p3[i][1]=p3[i][1]+factor*(p1[2]-p2[2])
  p3[i][2]=p3[i][2]+factor*(p2[1]-p1[1])
  i=2
  factor=factor*-1
  p3[i][1]=p3[i][1]+factor*(p1[2]-p2[2])
  p3[i][2]=p3[i][2]+factor*(p2[1]-p1[1])
  return p3[2],p3[1]
end


function rerun()
  norns.script.load("code/marimba/marimba.lua")
end
