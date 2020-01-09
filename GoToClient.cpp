#include <yarp/os/Network.h>
#include <yarp/os/RpcClient.h>

#include <GoTo.h>

#include <iostream>


int main(int argc, char *argv[])
{
    yarp::os::Network yarp;
    yarp::os::RpcClient client_port;

    client_port.open("/goToClient");
    if (!yarp.connect(client_port.getName(), "/textGoToServer"))
    {
        std::cout << "Error! Could not connect to server /textGoToServer\n";
        return 1;
    }

    GoTo goTo;
    goTo.yarp().attachAsClient(client_port);
// ---------------------

//     bool ret = goTo.stepTo(3.4, 5.3, 2.1);

// ---------------------

    return 0;
}
