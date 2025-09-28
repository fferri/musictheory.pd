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

local note_natural = pd.Class:new():register('note.natural')

function note_natural:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    assert(#atoms <= 0, 'too many args')
    return true
end

function note_natural:in_1_reload()
    self:dofilex(self._scriptname)
end

function note_natural:in_1_symbol(x)
    local note = mt.Note(x)
    note = mt.Note(note.pitch_class:natural(), note.octave)
    self:outlet(1, "symbol", {tostring(note)})
end
