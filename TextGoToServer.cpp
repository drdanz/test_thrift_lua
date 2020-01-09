// copyright

#include <yarp/os/Network.h>
#include <yarp/os/RpcServer.h>

#include <GoTo.h>

#include <iostream>

GoToStatus status = NOT_STARTED;

class TextGoToServer : public GoTo
{
    void goTo() override
    {
        std::cout << "goTo called\n";
        status = RUNNING;
    }

    GoToStatus getStatus() override
    {
        std::cout << "getStatus called\n";
        return status;
    }

};

int main()
{
    yarp::os::Network yarp;
    TextGoToServer textGoToServer;
    yarp::os::RpcServer port;
    textGoToServer.yarp().attachAsServer(port);
    if (!port.open("/textGoToServer")) { return 1; }
    while (true) {
        printf("Server running happily\n");
        yarp::os::Time::delay(10);
        if (status == RUNNING) {
            status = SUCCESS;
        }
    }
    port.close();
    return 0;
}
