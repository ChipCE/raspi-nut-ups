#!/bin/bash

# On wall power
if [[ "$NOTIFYTYPE" = "ONLINE" ]]
then
    sudo shutdown -c
fi

# On battery
if [[ "$NOTIFYTYPE" = "ONBATT" ]]
then
    sudo shutdown -P 2
fi

# Low battery
if [[ "$NOTIFYTYPE" = "LOWBATT" ]]
then
    sudo shutdown now
fi

# On shutdown command
if [[ "$NOTIFYTYPE" = "SHUTDOWN" ]]
then
    sudo shutdown now
fi

# Shutting down
if [[ "$NOTIFYTYPE" = "FSD" ]]
then
    echo "FSD"
fi

# COM disconnect
if [[ "$NOTIFYTYPE" = "COMMBAD" ]]
then
    echo "COMMBAD"
fi

# COM connected
if [[ "$NOTIFYTYPE" = "COMMOK" ]]
then
    echo "COMMOK"
fi

# Battery need replace
if [[ "$NOTIFYTYPE" = "REPLBATT" ]]
then
    echo "REPLBATT"
fi

# No COM connction
if [[ "$NOTIFYTYPE" = "NOCOMM" ]]
then
    echo "NOCOMM"
fi

# (Client mode only) No UPS server
if [[ "$NOTIFYTYPE" = "NOPARENT" ]]
then
    echo "NOPARENT"
fi
