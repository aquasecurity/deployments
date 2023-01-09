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

remove_selinux_module() {
    semodule -l | grep aquavme
    if [ $? -eq 0 ]; then
        echo "Info: Removing SElinux policy module."
        semodule -r aquavme
    else
        echo "Info: SElinux policy module not found"
    fi
}

remove_selinux_module_fedora() {
    semodule -l | grep aquavme
    if [ $? -eq 0 ]; then
        echo "Info: Removing SElinux policy module."
        semodule -r fcos_aquavme
    else
        echo "Info: SElinux policy module not found"
    fi
}

is_it_rhel() {
  cat /etc/*release | grep PLATFORM_ID | grep "platform:el8\|platform:el9" &>/dev/null

  if [ $? -eq 0 ]; then
    echo "Info: This is RHEL 8\9 system. Going to disable SELinux policy module if exists"
    remove_selinux_module
  fi
}

is_it_fedora() {
  cat /etc/*release | grep PLATFORM_ID | grep "platform:f3" &>/dev/null

  if [ $? -eq 0 ]; then
    echo "Info: This is a Fedora system. Going to disable SELinux policy module if exists"
    remove_selinux_module_fedora
  fi
}


stop_service
remove_service
remove_dirs
is_it_rhel
is_it_fedora