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

local chord_identify = pd.Class:new():register('chord.identify')

function chord_identify:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    assert(#atoms <= 0, 'too many args')
    return true
end

function chord_identify:in_1_reload()
    self:dofilex(self._scriptname)
end

function chord_identify:in_1_list(x)
    local notes = {}
    for _, xi in ipairs(x) do
        table.insert(notes, mt.Note(xi))
    end
    local l = {}
    for _, chord in ipairs(mt.Chord:identify_from_notes(notes)) do
        table.insert(l, tostring(chord))
    end
    self:outlet(1, 'list', l)
end
