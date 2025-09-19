--[[
Copyright (C) 2025 Federico Ferri

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see https://www.gnu.org/licenses/.
--]]

local class = require 'middleclass'

local OrderedList = class 'OrderedList'

function OrderedList:initialize(cmp)
    self._cmp = cmp or function(a, b) return a < b end
    self._data = {}
end

local function binary_search(data, cmp, value)
    local low, high = 1, #data
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if cmp(value, data[mid]) then
            high = mid - 1
        else
            low = mid + 1
        end
    end
    return low
end

function OrderedList:add(value)
    local idx = binary_search(self._data, self._cmp, value)
    table.insert(self._data, idx, value)
    return idx
end

function OrderedList:remove(value, limit, cb)
    return self:remove_if(function(x) return x == value end, limit, cb)
end

function OrderedList:remove_if(cmp, limit, cb)
    local n = 0
    for i = #self._data, 1, -1 do
        local v = self._data[i]
        if cmp(v) then
            if type(cb) == 'function' then
                cb(v)
            end
            table.remove(self._data, i)
            n = n + 1
            if limit and n >= limit then
                return n
            end
        end
    end
    return n
end

function OrderedList:get_if(cmp)
    local ret = {}
    for i, v in ipairs(self._data) do
        if cmp(v) then
            table.insert(ret, v)
        end
    end
    return ret
end

function OrderedList:get(index)
    return self._data[index]
end

function OrderedList:size()
    return #self._data
end

function OrderedList:to_table()
    local t = {}
    for i, v in ipairs(self._data) do t[i] = v end
    return t
end

local function test()
    local json = require 'dkjson'
    require 'busted.runner'()
    describe('TestsForOrderedList', function()
        it('basic_add_remove', function()
            local l = OrderedList()
            l:add(34)
            l:add(3)
            l:add(100)
            l:add(4)
            l:add(100)

            assert.equal(json.encode(l:to_table()), json.encode{3,4,34,100,100})

            l:remove(100, 1)

            assert.equal(json.encode(l:to_table()), json.encode{3,4,34,100})

            l:remove(4)
            l:remove(100)

            assert.equal(json.encode(l:to_table()), json.encode{3,34})
        end)
    end)
end

if arg[1] == 'test' then
    arg = {}
    test()
else
    return {
        OrderedList = OrderedList,
        test = test,
    }
end
