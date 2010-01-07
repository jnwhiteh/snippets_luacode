-- lib.lua
module(...,package.seeall)

-- unlike a full reduce() function, this applies a binary function in turn to each pair of values
-- in a table.  In the simplest case, if it just returns a boolean value, then pairs that match are
-- replaced by the first value. So partial_reduce(t,eq) is the same as unique(t)
-- If the function in addition returns a value, then that will be used as the output value.
function partial_reduce (t,fun)
    local i,j,n = 1,2,#t
    local res = {t[1]}
    while j <= n do
        local reduce,value = fun(res[i],t[j])
        if reduce then
            if value then res[i] = value end
        else
            i = i + 1
            res[i] = t[j]
        end
        j = j + 1
    end
    return res
end

--- given a string and a set of ranges [start,end]
-- create an annotated string with the text within the ranges enclosed in markup
-- @param s the text
-- @param ranges a list of {start,end} pairs (as returned e.g. by string.find)
-- @param start_anot start of markup (e.g. '<b>')
-- @param end_anot end of markup (e.g. '</b>')
function annotate (s,ranges,start_anot,end_anot)
    local res = {}
    local append = table.insert
    for i = 1,#ranges do
        local r,last = ranges[i],ranges[i-1]
        if i == 1 then
            if r[1] > 1 then
                append(res,s:sub(1,r[1]-1))
            end
        else
            append(res,s:sub(last[2]+1,r[1]-1))
        end
        append(res,start_anot)
        append(res,s:sub(r[1],r[2]))
        append(res,end_anot)
        if i == #ranges then
            append(res,s:sub(r[2]+1))
        end
    end
    return table.concat(res)
end

--- given some text and a range, extract the immediate context of the range.
-- This is done using a naive method that counts the number of delimiter characters to the left
-- and the right of the given range.
-- @param s the text
-- @param range a pair {start,end}
-- @param delim the delimiter to count in both directions
-- @param ndelim number of delimiters to count
-- @return extended range {start,end}
function extract_context (s,range,delim,ndelim)
    local i1,i2 = range[1],range[2]
    local n = 0
    local function match (i)
        return s:sub(i,i):match (delim)
    end
    while i1 > 1 and n < ndelim do
        if match (i1) then n = n + 1 end
        i1 = i1 - 1
    end
    if i1 > 1 then i1 = i1 + 1 end
    n = 0
    while i2 < #s and n < ndelim do
        if match (i2) then n = n + 1 end
        i2 = i2 + 1
    end
    if i2 < #s then i2 = i2 -  1 end
    return Range{i1,i2}
end

local RangeMT = {}
RangeMT.__index = RangeMT

function Range (r)
    return setmetatable(r,RangeMT)
end

function  RangeMT.overlaps (r1,r2)
    return r1[2] >= r2[1]
end

function RangeMT.shift (r,x)
    return Range{r[1]+x,r[2]+x}
end

function RangeMT.width (r)
    return r[2] - r[1] + 1
end

function RangeMT.upper_lower (r)
    return r[1],r[2]
end
