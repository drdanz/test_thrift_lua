#!/usr/bin/lua5.2

require('yarp')
require('GoTo')

yarp.Network()

p = yarp.RpcClient()
p:open("/luaClient")

yarp.Network.connect(p:getName(), "/textGoToServer")

gt = GoTo.GoTo()
gt:yarp():attachAsClient(p)

print(gt:help())
print(gt:help("goTo"))
print(gt:help("getStatus"))
print(gt:help("help"))

result = gt:getStatus()
gt:goTo()
