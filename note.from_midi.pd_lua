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

local note_from_midi = pd.Class:new():register('note.from_midi')

function note_from_midi:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    self.allowed_accidentals = -1
    if #atoms >= 1 then
        self.allowed_accidentals = {}
        for i, x in ipairs(atoms) do
            x = math.floor(x + 0.5)
            table.insert(self.allowed_accidentals, x)
        end
    end
    return true
end

function note_from_midi:in_1_reload()
    self:dofilex(self._scriptname)
end

function note_from_midi:in_1_float(x)
    x = math.floor(x + 0.5)
    local notes = mt.Note:from_midi_note(x, self.allowed_accidentals)
    local l = {}
    for i, x in ipairs(notes) do
        table.insert(l, tostring(x))
    end
    self:outlet(1, "list", l)
end
