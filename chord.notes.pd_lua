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

arg = {}
mt = require 'musictheory'

local chord_notes = pd.Class:new():register('chord.notes')

function chord_notes:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    self.octave = 4
    if #atoms >= 1 then
        self:in_2_float(atoms[1])
    end
    assert(#atoms <= 1, 'too many args')
    return true
end

function chord_notes:in_1_reload()
    self:dofilex(self._scriptname)
end

function chord_notes:in_1_symbol(x)
    local chord = mt.Chord(x)
    local l = {}
    for i, p in ipairs(chord:notes(self.octave)) do
        table.insert(l, tostring(p))
    end
    self:outlet(1, "list", l)
end

function chord_notes:in_2_float(x)
    self.octave = math.floor(x + 0.5)
    assert(math.abs(self.octave - x) < 1e-5, 'octave must be integer')
end
