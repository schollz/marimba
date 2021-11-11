local Part={}

local mallet_strokes={
    -- single strokes
    "x",
    "x-",
    "x--",
    "x---",
    "x----",
    "x-----",
    "x------",
    "x-------",
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

function Part:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.swing = o.swing or 50 
  o.enabled = o.enabled==nil and true or o.enabled 
  o.sequence = {}
  return o
end

function Part:set_sequence(note,stroke,i)
    local current_sequence={note=note,stroke=1}
    if i~=nil then 
        if self.sequence[i]~nil then 
            current_sequence=self.sequence[i]
        end
    end
    current_sequence.note=note 
    current_sequence.stroke=stroke 
    if i~=nil then 
        self.sequence[i]=current_sequence
    end
end

return Part
