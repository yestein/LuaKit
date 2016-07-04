--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/12/15 10:28:34
-- Description  : description
-- Modify       :
--=======================================================================

local Util = require("lib.util")
local assert = require("lib.assert")

if not LuaEvent then
    LuaEvent = {
        global_event_list = {}
    }
end

local Event = LuaEvent

function Event:Init()

end

function Event:Uninit()

end

function Event:Debug()
    Util.ShowTB(self.global_event_list)
end

function Event:RegistHook(hook_function)
    self.hook_function = hook_function
end

function Event:UnRegistHook()
    self.event_black_list = nil
    self.hook_function = nil
end

function Event:RegistEvent(event_type, function_call_back, parent)
    if not event_type or not function_call_back then
        assert(false, "RegistEvent Error EventType[%s] CallBack[%s]", tostring(event_type), tostring(function_call_back))
        return
    end
    if not self.global_event_list[event_type] then
        self.global_event_list[event_type] = {}
    end
    local call_back_list = self.global_event_list[event_type]
    local register_id = #call_back_list + 1
    call_back_list[register_id] = {function_call_back, parent}
    return register_id
end

function Event:UnRegistEvent(event_type, register_id)
    if not event_type or not register_id then
        assert(false)
        return
    end
    if not self.global_event_list[event_type] then
        return 0
    end
    local call_back_list = self.global_event_list[event_type]
    if not call_back_list[register_id] then
        return 0
    end
    call_back_list[register_id] = nil
    return 1
end

function Event:FireEvent(trigger, event_type, ...)
    if self.hook_function then
        Util.SafeCall(self.hook_function, event_type, ...)
    end
    self:CallBack(self.global_event_list[event_type],
        function()
            return trigger, event_type
        end, ...)
end

function Event:CallBack(event_list, env_func, ...)
    if not event_list then
        return
    end
    local event_list_copy = Util.CopyTB1(event_list)
    for register_id, callback in pairs(event_list_copy) do
        if event_list[register_id] then
            local func = callback[1]
            local class_self = callback[2]
            if class_self then
                if class_self.SetRuntimeInfo then
                    class_self:SetRuntimeInfo(env_func)
                end
                Util.SafeCall(func, class_self, ...)
                if class_self.SetRuntimeInfo then
                    class_self:SetRuntimeInfo(nil)
                end
            else
                Util.SafeCall(func, env_func, ...)
            end
        end
    end
end

--Unit Test
if arg and arg[1] == "event" then

end

return Event
