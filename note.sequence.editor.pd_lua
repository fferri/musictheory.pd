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

--[[
This require several lua rocks:
 - middleclass (as usual)
 - dkjson
 - http
 - lanes
]]--

arg = {}
mt = require 'musictheory'

local class = require 'middleclass'
local json = require 'dkjson'
local cqueues = require 'cqueues'
local socket = require 'cqueues.socket'
local http_server = require 'http.server'
local websocket = require 'http.websocket'

local note_sequence_editor = pd.Class:new():register('note.sequence.editor')

local ui_program = '/Users/me/Dev/qt_pd_websocket_client/build/Qt_6_9_2_for_macOS-Debug/appqt_pd_websocket_client.app/Contents/MacOS/appqt_pd_websocket_client'
local ui_port = 9001

function note_sequence_editor:initialize(sel, atoms)
    self.inlets = 1
    self.outlets = 1
    assert(#atoms <= 0, 'too many args')

    self.cq = cqueues.new()
    self.cq:wrap(function()
        local myserver = http_server.listen {
            host = '127.0.0.1',
            port = 9001,
            onstream = function(myserver, stream)
                local req_headers = assert(stream:get_headers())
                local method = req_headers:get(':method')
                if method == 'GET' and req_headers:get('upgrade') == 'websocket' then
                    -- do the WebSocket handshake
                    self.ws = assert(websocket.new_from_stream(stream, req_headers))
                    assert(self.ws:accept())
                    pd.post('WebSocket connected!')

                    while true do
                        local msg, opcode = self.ws:receive()
                        if not msg then break end
                        msg = json.decode(msg)
                        self:outlet(1, 'list', msg)
                    end
                else
                    -- not a WebSocket request
                    local res_headers = http_headers.new()
                    res_headers:append(':status', '400')
                    assert(stream:write_headers(res_headers, true))
                end
            end,
            onerror = function(myserver, context, op, err, errno)
                local msg = string.format('%s on %s failed: %s', op, context, err)
                self:error(msg)
            end,
        }
        assert(myserver:loop())
    end)

    return true
end

function note_sequence_editor:postinitialize()
    self.postinit = pd.Clock:new():register(self, 'postpostinit_task')
    self.postinit:delay(0)
end

function note_sequence_editor:postpostinit_task()
    self.initialized = true
    self.clock = pd.Clock:new():register(self, 'tick')
    self.clock:delay(20)
end

function note_sequence_editor:finalize()
    self.clock:destruct()
end

function note_sequence_editor:tick()
    if not self.initialized then return end

    assert(self.cq:step(0))  -- run one iteration, non-blocking if nothing is ready
    self.clock:delay(20)
end

function note_sequence_editor:in_1_reload()
    self:dofilex(self._scriptname)
end

local function run_async(prog, arg)
    local is_windows = package.config:sub(1,1) == '\\'

    -- ensure arg is a string (in case you pass a number)
    local arg_str = tostring(arg or "")

    local cmd = prog .. " " .. arg_str

    if is_windows then
        os.execute('start "" ' .. cmd)
    else
        os.execute(cmd .. ' &')
    end
end

function note_sequence_editor:in_1_open()
    if self.spawned_ui then
        local ok, v = pcall(self.ws.send, self.ws, json.encode{'raise'})
        if not ok then
            if string.match(v, " send_frame: Broken pipe$") then
                -- ui has quit? respawn
                self.spawned_ui = false
                self:in_1_open()
            else
                error(v)
            end
        end
        assert(v)
    else
        run_async(ui_program, ui_port)
        self.spawned_ui = true
    end
end

function note_sequence_editor:in_1_list(atoms)
    assert(self.ws:send(json.encode(atoms)))
end
