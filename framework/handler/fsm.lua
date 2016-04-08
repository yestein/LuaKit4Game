--=======================================================================
-- File Name    : fsm
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 29/03/2016 15:14:58
-- Description  : description
-- Modify       :
--=======================================================================
local FSM = {}

function FSM:Init()
    self.machine_data = {}
    self:SetDataByKey("state", "start")
end

function FSM:Uninit()
    self.machine_data = nil
end

FSM.import_function = {
    AddRule = function(self, start_state, event, new_state)
        local rule_list = self:GetRuleList(start_state)
        rule_list[event] = new_state
    end,
    GetRuleList = function(self, state)
        local machine_data = self.machine_data
        if not machine_data[state] then
            machine_data[state] = {}
        end
        return machine_data[state]
    end,
    GetFSMState = function(self)
        return self:GetDataByKey("state")
    end,
    SendFSMEvent = function(self, event)
        local state = self:GetFSMState()
        local rule_list = self:GetRuleList(state)
        local new_state = rule_list[event]
        if not new_state then
            return
        end
        self:SetDataByKey("state", new_state)
        if self.FireEvent then
            if self.GetId then
                self:FireEvent("STATE_CHANGE", self:GetId(), state, new_state)
            else
                self:FireEvent("STATE_CHANGE", state, new_state)
            end
        end
    end,
}

return FSM
