#!/bin/bash

# On wall power
if [[ "$NOTIFYTYPE" = "ONLINE" ]]
then
    curl -m 2 localhost:1880/ups?msg=ONLINE
    sudo shutdown -c
fi

# On battery
if [[ "$NOTIFYTYPE" = "ONBATT" ]]
then
    curl -m 2 localhost:1880/ups?msg=ONBATT
    sudo shutdown -P 2
fi

# Low battery
if [[ "$NOTIFYTYPE" = "LOWBATT" ]]
then
    curl -m 2 localhost:1880/ups?msg=LOWBATT
    sudo shutdown now
fi

# On shutdown command
if [[ "$NOTIFYTYPE" = "SHUTDOWN" ]]
then
    curl -m 2 localhost:1880/ups?msg=SHUTDOWN
    sudo shutdown now
fi

# Shutting down
if [[ "$NOTIFYTYPE" = "FSD" ]]
then
    curl -m 2 localhost:1880/ups?msg=FSD
    echo "FSD"
fi

# COM disconnect
if [[ "$NOTIFYTYPE" = "COMMBAD" ]]
then
    curl -m 2 localhost:1880/ups?msg=COMMBAD
    echo "COMMBAD"
fi

# COM connected
if [[ "$NOTIFYTYPE" = "COMMOK" ]]
then
    curl -m 2 localhost:1880/ups?msg=COMMOK
    echo "COMMOK"
fi

# Battery need replace
if [[ "$NOTIFYTYPE" = "REPLBATT" ]]
then
    curl -m 2 localhost:1880/ups?msg=REPLBATT
    echo "REPLBATT"
fi

# No COM connction
if [[ "$NOTIFYTYPE" = "NOCOMM" ]]
then
    curl -m 2 localhost:1880/ups?msg=NOCOMM
    echo "NOCOMM"
fi

# (Client mode only) No UPS server
if [[ "$NOTIFYTYPE" = "NOPARENT" ]]
then
    curl -m 2 localhost:1880/ups?msg=NOPARENT
    echo "NOPARENT"
fi
