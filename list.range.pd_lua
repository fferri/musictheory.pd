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

local list_range = pd.Class:new():register('list.range')

function list_range:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    assert(#atoms <= 2, 'too many args')
    self.start, self.end_ = 1, 0
    if #atoms >= 1 then
        self:in_2_list(atoms)
    end
    return true
end

function list_range:in_1_reload()
    self:dofilex(self._scriptname)
end

function list_range:in_1_bang()
    local l = {}
    for i = self.start, self.end_ do table.insert(l, i) end
    self:outlet(1, 'list', l)
end

function list_range:in_1_float(x)
    self:in_2_float(x)
    self:in_1_bang()
end

function list_range:in_1_list(atoms)
    self:in_2_list(atoms)
    self:in_1_bang()
end

function list_range:in_2_float(x)
    self.start, self.end_ = 1, x
end

function list_range:in_2_list(atoms)
    assert(#atoms >= 1, 'not enough args')
    assert(#atoms <= 2, 'too many args')
    assert(type(atoms[1]) == 'number', 'float expected')
    if atoms[2] then
        assert(type(atoms[2]) == 'number', 'float expected')
        self.start, self.end_ = atoms[1], atoms[2]
    else
        self.start, self.end_ = 1, atoms[1]
    end
end
