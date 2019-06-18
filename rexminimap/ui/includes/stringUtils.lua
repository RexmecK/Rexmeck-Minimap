
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end


function compactHexString(color)
    local compact = true
    local hexTable = {}
    for i,v in ipairs(color) do
        local hex = string.format("%2.2x", math.max(math.min(math.floor(v), 255), 0))
        if hex:sub(1,1) ~= hex:sub(2,2) then
            compact = false
        end
        table.insert(hexTable, hex)
    end
    if compact then
       local hexTable2 = {}
       for i,v in ipairs(hexTable) do
            table.insert(hexTable2, v:sub(1,1))
       end
       hexTable = hexTable2
    end
    return table.concat(hexTable)
end

function removeFile(path)
    if path:sub(path:len(), path:len()) == "/" then return path end
    local fields = path:split("/")
    local p = "/"
    for i=1,#fields - 1 do
        p = p..fields[i].."/"
    end
    return p
end