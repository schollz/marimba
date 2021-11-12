local Instrument={}

function Instrument:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.id=o.id or 1
  o.root=o.root or 48
  o.parts={}
  o.seq={}
  o.scale={}
  o.note_last=nil
  local next_note={0,2,2,1,1,1,2,2,1,2,2,1,1,1,2,2,1}
  for i=1,17 do 
    if i==1 then 
        table.insert(o.scale,o.root)
    else
        table.insert(o.scale,o.scale[i-1]+next_note[i])
    end
  end
  return o
end

function Instrument:add(part)
    table.insert(self.parts,part)
    self:refresh()
end

function Instrument:set(i,part)
    self.parts[i]=part
    self:refresh()
end

function Instrument:get_sequence()
    local t={}
    for _, part in ipairs(self.parts) do
        local notes=part:get_notes()
        table.insert(t,notes[1])
    end
    return t
end

function Instrument:refresh()
    local t={}
    for parti, part in ipairs(self.parts) do
        for _, v in ipairs(part:seq()) do
            v.part=parti
            table.insert(t,v)
        end
    end
    self.seq=t
end


function Instrument:emit(beat)
    if #self.seq==0 then 
        do return end 
    end
    local i=((beat-1)%#self.seq)+1
    if self.seq[i]==nil then 
        do return end 
    end
    if self.seq[i].r=="-" then 
        do return end 
    end
    local velocity=30
    if self.seq[i].r=="x" then 
        velocity=90
    end
    velocity=velocity+math.random(-15,15)
    local keys=self.seq[i].n
    self.part_last=self.seq[i].part
    for _, k in ipairs(self.seq[i].n) do
        local note=self.scale[k]
        engine.play(self.id,note,velocity)
        if self.note_last==nil then 
            self.note_last={k}
        else
            table.insert(self.note_last,k)
        end
    end
end

return Instrument
