--
-- Authors: Daniele E. Domenichelli
-- Version: 0.0.1
-- A Test for Behaviour Trees
--

require('yarp')
require('GoTo')

yarp.Network()
--p = yarp.RpcClient()
--p:open("/luaClient")

--yarp.Network.connect(p:getName(), "/textGoToServer")

--gt = GoTo.GoTo()
--gt:yarp():attachAsClient(p)

--print(gt:help())
--print(gt:help("goTo"))
--print(gt:help("getStatus"))
--print(gt:help("help"))

return rfsm.state {

    initial = rfsm.conn {},
    done = rfsm.state {},
    fail = rfsm.state {},

    bt_node = rfsm.state {

        --goto
        ['goto'] = rfsm.state{
            doo = function()
                print("Calling RPC goto()")
          --      gt:goTo()
                rfsm.send_events(fsm, "e_true")
            end,
        },
        --end of goto

        --getState
        getState = rfsm.state{
            doo = function()
                print("Calling RPC getState()")
--			    result = gt:getStatus()
--				if (result == RUNNING) then
--                		rfsm.send_events(fsm, "e_running")
--				elseif (result == SUCCESS) then
--                		rfsm.send_events(fsm, "e_success")
--				end
            end,
        },
        --end of getState

        rfsm.trans{ src = 'initial', tgt = 'goto', pn = 0 },
        rfsm.trans{ src = 'goto', tgt = 'getState', pn = 0, events = {'e_true'} },
        rfsm.trans{ src = 'getState', tgt = 'getState', pn = 0, events={ 'e_running' } },
    },

    --Transitions
    rfsm.trans{ src = 'initial', tgt = 'bt_node', pn = 0 },
    rfsm.trans{ src = 'bt_node', tgt = 'done', pn = 0, events = {"e_success"} },
    rfsm.trans{ src = 'bt_node', tgt = 'fail', pn = 0, events = {"e_abort"} },
}
