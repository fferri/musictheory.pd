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

local mt = require 'musictheory'

local interval_split = pd.Class:new():register('interval.split')

function interval_split:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    assert(#atoms <= 0, 'too many args')
    return true
end

function interval_split:in_1_reload()
    self:dofilex(self._scriptname)
end

function interval_split:in_1_symbol(x)
    local interval = mt.Interval(x)
    local l = {}
    for _, x in ipairs(interval:split()) do
        table.insert(l, tostring(x))
    end
    self:outlet(1, "list", l)
end
