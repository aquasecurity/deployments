#!/usr/bin/env bash

ENFORCER_SERVICE_FILE_NAME="aqua-enforcer.service"
ENFORCER_SERVICE_NAME="aqua-enforcer"
error_message(){
    echo "Error: ${1}"
    exit 1
}

stop_service() {
  sudo systemctl stop ${ENFORCER_SERVICE_NAME}
  echo "Info: VM Enforcer service was successfully stop."
}

remove_service() {
    rm -f /etc/systemd/system/${ENFORCER_SERVICE_FILE_NAME}
    systemctl daemon-reload
    systemctl reset-failed
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer service was successfully removed."
    else
        error_message "Unable to remove the service. please check the logs."
    fi
}

remove_dirs() {
    rm -rf /opt/aquasec
    rm -rf /opt/aqua-runc
    rm -rf /tmp/aqua
    if [ $? -eq 0 ]; then
        echo "Info: VM Enforcer dirs were successfully removed."
    else
        error_message "Unable to remove folders. please check the logs."
    fi

}
stop_service
remove_service
remove_dirs