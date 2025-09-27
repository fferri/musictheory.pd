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
ol = require 'orderedlist'

local note_sequence = pd.Class:new():register('note.sequence')

local function note_to_list(note_info)
    local visited = {}
    local function get(k) visited[k] = true; return note_info[k] end
    local l = {get 'note', get 'time', get 'duration' or 1}
    for k, v in pairs(note_info) do
        if not visited[k] then
            table.insert(l, k)
            table.insert(l, get(k))
        end
    end
    return l
end

function note_sequence:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 2
    self.seq = mt.NoteSequence()
    self.seq:add_listener(function(event, note_info)
        local l = note_to_list(note_info)
        table.insert(l, 1, event)
        self:outlet(2, 'list', l)
    end)
    assert(#atoms <= 0, 'too many args')
    return true
end

function note_sequence:in_1_reload()
    self:dofilex(self._scriptname)
end

function note_sequence:in_1_add(atoms, notify)
    assert(#atoms >= 3, 'not enough args')
    assert(((#atoms - 3) % 2) == 0, 'keyword arguments must be even')
    local note, time, duration = atoms[1], atoms[2], atoms[3]
    local info = {}
    for i = 4, #atoms, 2 do
        info[atoms[i]] = atoms[i + 1]
    end
    self.seq:set_note(time, note, info, {notify = notify})
end

function note_sequence:in_1_remove(atoms, notify)
    assert(#atoms == 2, 'invalid number of args')
    local note, time = atoms[1], atoms[2]
    self.seq:clear_note(time, note, {notify = notify})
end

function note_sequence:in_1_change(atoms, notify)
    assert(#atoms > 2, 'not enough args')
    assert(((#atoms - 2) % 2) == 0, 'keyword arguments must be even')
    local note, time = atoms[1], atoms[2]
    local info = {}
    for i = 3, #atoms, 2 do
        info[atoms[i]] = atoms[i + 1]
    end
    local new_time, new_note
    new_time = info.time
    new_note = info.note
    info.time = nil
    info.note = nil
    self.seq:set_note(time, note, info, {notify = notify})
    if new_time or new_note then
        self.seq:move_note(time, note, new_time or time, new_note or note, {notify = notify})
    end
end

function note_sequence:in_1_get(atoms)
    assert(#atoms == 2, 'invalid number of args')
    local start = atoms[1]
    local duration = atoms[2] or 0
    assert(type(start) == 'number', 'invalid type for start time')
    assert(type(duration) == 'number', 'invalid type for duration')
    local notes_in_range = self.seq:get_notes_in_range(start, start + duration)
    for _, note_info in ipairs(notes_in_range) do
        self:outlet(1, 'list', note_to_list(note_info))
    end
end

function note_sequence:in_1_play(atoms)
    assert(#atoms == 1, 'invalid number of args')
    local start = atoms[1]
    assert(type(start) == 'number', 'invalid type for start time')
    local notes_in_range = self.seq:get_notes_starting_at(start)
    for _, note_info in ipairs(notes_in_range) do
        self:outlet(1, 'list', note_to_list(note_info))
    end
end

function note_sequence:in_1_clear(atoms)
    assert(#atoms == 0, 'invalid number of args')
    self.seq:clear()
end

function note_sequence:in_1_dump(atoms)
    assert(#atoms == 0, 'invalid number of args')
    pd.post('--------------------------------------------------')
    for _, note_info in ipairs(self.seq:get_notes()) do
        pd.post('' .. note_info.time .. ' ' .. tostring(note_info.note) .. ' ' .. note_info.duration)
    end
    pd.post('--------------------------------------------------')
end

function note_sequence:in_2_list(atoms)
    local cmd = table.remove(atoms, 1)
    if cmd == 'add' then
        self:in_1_add(atoms, false)
    elseif cmd == 'remove' then
        self:in_1_remove(atoms, false)
    elseif cmd == 'change' then
        self:in_1_change(atoms, false)
    else
        error('invalid command: ' .. cmd)
    end
end
