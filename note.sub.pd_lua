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

local note_sub = pd.Class:new():register('note.sub')

function note_sub:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    self.interval = mt.Interval('P1')
    if #atoms >= 1 then
        self.interval = mt.Interval(atoms[1])
    end
    assert(#atoms <= 1, 'too many args')
    return true
end

function note_sub:in_1_reload()
    self:dofilex(self._scriptname)
end

function note_sub:in_1_symbol(x)
    local note = mt.Note(x)
    note = note - self.interval
    self:outlet(1, "symbol", {tostring(note)})
end

function note_sub:in_2_symbol(x)
    self.interval = mt.Interval(x)
end
