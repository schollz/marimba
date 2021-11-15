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

if not string.find(package.cpath,"/home/we/dust/code/o-o-o/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/o-o-o/lib/?.so"
end
json=require("cjson")

Lattice = require("lattice")
Part=include("marimba/lib/part")
Instrument=include("marimba/lib/instrument")


engine.name="Marimba"
local shift=false
par_num=4
note_selected=1
sel_instrument=1
sel_part=1
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
  -- initialize the marimba menu
  -- local marimba_instruments={
  --   {name="soprano",root=60},
  --   {name="tenor",root=48},
  --   {name="baritone",root=36},
  --   {name="bass",root=24},
  -- }
  -- for _, ins in ipairs(marimba_instruments) do 
  --   params:add_group(ins.name,1)
  --   params:add()
  -- end
  -- params:add_group()

  -- initialize the marimba
  marimbas={}
  marimbas[sel_instrument]=Instrument:new({id=1,root=36,name="tenor"})
  marimbas[sel_instrument]:add(Part:new{stroke=16,note=9,count=1,interval=0})
  -- marimbas[sel_instrument]:add(Part:new{stroke=16,note=12,count=1,interval=0})
  -- marimbas[sel_instrument]:add(Part:new{stroke=16,note=7,count=1,interval=0})
  -- marimbas[sel_instrument]:add(Part:new{stroke=16,note=8,count=1,interval=0})
  -- marimbas[sel_instrument]:add(Part:new{stroke=16,note=9,count=1,interval=0})
  -- marimbas[sel_instrument]:add(Part:new{stroke=16,note=3,count=1,interval=0})
--   marimbas[sel_instrument]:add(Part:new{stroke=16,note=9,count=2,interval=3})
--   marimbas[sel_instrument]:add(Part:new{stroke=2,note=10})
--   marimbas[sel_instrument]:add(Part:new{stroke=1,note=12,count=4})
--   marimbas[sel_instrument]:add(Part:new{stroke=11,note=11,count=1})
--   marimbas[sel_instrument]:add(Part:new{stroke=12,note=12,count=2})
  marimbas[sel_instrument]:refresh()

  marimbas[2]=Instrument:new({id=2,root=24,name="soprano"})
  marimbas[2]:add(Part:new{stroke=15,note=9,count=1,interval=0})
  marimbas[2]:add(Part:new{stroke=14,note=6,count=2,interval=0})
  marimbas[2]:refresh()
  
  -- initialize the lattice
  lattice = Lattice:new()
  patterns={}
  for i=1,#marimbas do 
    patterns[i]=lattice:new_pattern{
        division=1/16,
        action=function(t)
            local beat=t/24+1
            marimbas[i]:emit(beat)
        end,
    }
  end
  -- lattice:hard_restart()

  -- initialize metro for updating screen
  timer=metro.init()
  timer.time=1/10
  timer.count=-1
  timer.event=update_screen
  timer:start()

  -- add callbacks for reading/writing files
  params.action_write=function(filename,name)
    local t={} 
    for i,v in ipairs(marimbas) do
        table.insert(t,v:dump())
    end
    local file=io.open(filename..".json","w+")
    io.output(file)
    io.write(json.encode(t))
    io.close(file)
  end
  params.action_read=function(filename)
    local f=io.open(filename..".json","rb")
    local content=f:read("*all")
    f:close()
    local d=json.decode(content)
    if d==nil then
        do return end 
    end 
    marimbas={}
    for i,v in ipairs(d) do 
        local ins=Instrument:new()
        ins:load(v)
        ins:refresh()
        table.insert(marimbas,ins)
    end 
  end
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
        lattice:stop()
    elseif k==3 then
        lattice:hard_restart()
    end
  else
    if k==1 then
    elseif k==2 then
        change_part(-1)
    elseif k==3 then
        change_part(1)
    end
  end
end

function change_part(d)
    local pnum=util.clamp(sel_part+d,1,#marimbas[sel_instrument].parts+1)
    if pnum==#marimbas[sel_instrument].parts+1 then 
        if marimbas[sel_instrument].parts[sel_part].count>0 then
            local p=marimbas[sel_instrument].parts[pnum-1]
            marimbas[sel_instrument]:add(Part:new{count=0,note=p.note,interval=p.interval,stroke=p.stroke})
        else
            pnum=pnum-1
        end
    end
    sel_part=pnum
end

function enc(k,d)
  if shift then
    if k==1 then
    elseif k==2 then
        marimbas[sel_instrument].parts[sel_part].stroke=util.clamp(marimbas[sel_instrument].parts[sel_part].stroke+d,1,#mallet_strokes)
        marimbas[sel_instrument]:refresh()
    elseif k==3 then 
        marimbas[sel_instrument].parts[sel_part].interval=util.clamp(marimbas[sel_instrument].parts[sel_part].interval+d,0,12)
        marimbas[sel_instrument]:refresh()
    end
  else
    if k==1 then
        sel_instrument=util.wrap(sel_instrument+d,1,#marimbas)
        sel_part=1
    elseif k==2 then
        marimbas[sel_instrument].parts[sel_part].count=util.clamp(marimbas[sel_instrument].parts[sel_part].count+d,0,16)
        marimbas[sel_instrument]:refresh()
    elseif k==3 then 
        marimbas[sel_instrument].parts[sel_part].note=util.wrap(marimbas[sel_instrument].parts[sel_part].note+d,1,17)
        marimbas[sel_instrument]:refresh()
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
    if marimbas[sel_instrument].parts[sel_part]==nil then 
        do return end 
    end
    screen.level(par_num==1 and 15 or 5)
    screen.move(5,5)
    screen.text("instrument "..sel_instrument)
    screen.level(par_num==2 and 15 or 5)
    screen.move(5,14)
    screen.text("note: "..marimbas[sel_instrument].parts[sel_part].note)  
    screen.level(par_num==3 and 15 or 5)
    screen.move(5,23)
    screen.text(""..marimbas[sel_instrument].parts[sel_part]:get_stroke())  
    local note_names=""
    for _, note in ipairs(marimbas[sel_instrument].parts[sel_part]:get_notes()) do 
      note_names=note_names..note.." "
    end
    screen.level(par_num==1 and 15 or 5)
    screen.move(126,5)
    screen.text_right("part "..sel_part)
    screen.level(par_num==2 and 15 or 5)
    screen.move(126,14)
    screen.text_right("interval: "..marimbas[sel_instrument].parts[sel_part].interval)  
    screen.level(par_num==3 and 15 or 5)
    screen.move(126,23)
    screen.text_right("x"..marimbas[sel_instrument].parts[sel_part].count)
    screen.move(126,64)
    if marimbas[sel_instrument].part_last~=nil then 
        screen.text_right(marimbas[sel_instrument].part_last)
    end
end

function draw_marimba()
    local height=32
    local width=6
    local x=2
    local ymid=42
    local top_positions={}
    local bot_positions={}
    for i=1,17 do
        local y=math.floor(ymid-height/2)
        screen.rect(x,y,width,height)
        screen.level(5)
        screen.fill()
        if marimbas[sel_instrument].note_last~=nil then 
            if i==marimbas[sel_instrument].note_last[1] or i==marimbas[sel_instrument].note_last[2] then 
                screen.rect(x,y,width,height)
                screen.level(15)
                screen.fill()
            end
        end
        if marimbas[sel_instrument].parts[sel_part].note==i
            or marimbas[sel_instrument].parts[sel_part].note+marimbas[sel_instrument].parts[sel_part].interval==i then 
            screen.rect(x,y,width,height)
            screen.level(15)
            screen.stroke()
        end
        table.insert(top_positions,{x+width/2,y+height})
        table.insert(bot_positions,{x+width/2,y})
        height=height-1
        x=x+8
    end
    
    local seq=marimbas[sel_instrument]:get_sequence()
    local top_num=10
    local bot_num=10
    local level=15
    for i,p in ipairs(seq) do
        if i>1 then 
            local p1=p
            local p2=seq[i-1]
            if p2>p1 then 
                draw_curve(top_positions[p1],top_positions[p2],top_num,level)
                top_num=top_num+10
                level=level-1
            elseif p1<p2 then 
                draw_curve(bot_positions[p1],bot_positions[p2],bot_num,level)
                bot_num=bot_num+10
                level=level-1
            end

        end
    end

    -- draw line from 4 to 8
    marimbas[sel_instrument].note_last=nil
end

function draw_curve(p1,p2,d,l)
    screen.level(l or 15)
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
