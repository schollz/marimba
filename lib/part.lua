local Part={}

function Part:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.swing = o.swing or 50 
  o.enabled = o.enabled==nil and true or o.enabled 
  o.stroke = o.stroke or 1
  o.note = o.note or 9
  o.count = o.count or 1
  o.interval = o.interval or 0
  o.s=nil
  return o
end

function Part:dump()
    local t={}
    local to_dump={"swing","enabled","stroke","note","count","interval"}
    for _, k in ipairs(to_dump) do 
        t[k]=self[k]
    end    
    return json.encode(t)
end

function Part:load(s)
    local d=json.decode(s)
    if d==nil then 
        do return end 
    end
    for k,v in pairs(d) do
        self[k]=v
    end
end

function Part:get_stroke()
    return mallet_strokes[self.stroke]
end

function Part:get_count()
    return self.count
end

function Part:get_notes()
    local t
    t={self.note}
    if self.interval>0 then 
        table.insert(t,self.note+self.interval)
    end
    return t
end

function Part:seq()
    local t={}
    for i=1,self.count do 
        local stroke=mallet_strokes[self.stroke]
        for j=1, #stroke do
            local c = stroke:sub(j,j)
            local notes={}
            table.insert(notes,self.note)
            if self.interval > 0 and self.note+self.interval <= 17 then 
                table.insert(notes,self.note+self.interval)
            end
            table.insert(t,{n=notes,r=c})
        end
    end
    return t
end



return Part
