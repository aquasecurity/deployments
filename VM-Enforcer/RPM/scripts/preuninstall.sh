#!/usr/bin/env bash

ENFORCER_SERVICE_FILE_NAME="aqua-enforcer.service"
ENFORCER_LOADER_SERVICE_FILENAME="aqua-loader.service"

stop_service() {
    systemctl stop ${ENFORCER_SERVICE_FILE_NAME}
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer service stopped."
    else
        error_message "Unable to stop the service. please check the logs."
    fi
    systemctl disable ${ENFORCER_SERVICE_FILE_NAME}
    systemctl stop ${ENFORCER_LOADER_SERVICE_FILENAME}
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer Loader service disabled."
    else
        error_message "Unable to disable the loader service. please check the logs."
    fi
    systemctl disable ${ENFORCER_LOADER_SERVICE_FILENAME}
}

action="$1"

case "$action" in
"0" | "remove")
    stop_service
    ;;
"1" | "upgrade")
    ### pass
    ;;
esac