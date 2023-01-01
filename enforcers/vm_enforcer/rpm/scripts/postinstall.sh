#!/bin/bash

is_bin_in_path() {
  builtin type -P "${1}" &> /dev/null
}

is_root() {
  if [ "${EUID}" -ne 0 ]; then
    error_message "This util need to run as root"
  fi
}

error_message() {
  echo "Error: ${1}"
  exit 1
}

warning_message() {
  echo "Warning: $1"
}

load_config_from_env() {
  CONFIG_FILE="/etc/conf/aquavmenforcer.json"
  if [ ! -f ${CONFIG_FILE} ]; then
    echo "Info: Config File not found, Setting Default Configuration!"
    GATEWAY_ENDPOINT=""
    AQUA_TOKEN=""
    AQUA_TLS_VERIFY=false
    AQUA_ROOT_CA=""
    AQUA_PUBLIC_KEY=""
    AQUA_PRIVATE_KEY=""
  else
    echo "Info: Config File found, loading configuration"
    AQUA_CONFIG=$(cat ${CONFIG_FILE})
    GATEWAY_ENDPOINT=$(echo ${AQUA_CONFIG} | jq '.AQUA_GATEWAY // empty' | sed -e 's/^"//' -e 's/"$//')
    AQUA_TOKEN=$(echo ${AQUA_CONFIG} | jq '.AQUA_TOKEN // empty' | sed -e 's/^"//' -e 's/"$//')
    AQUA_TLS_VERIFY=$(echo ${AQUA_CONFIG} | jq '.AQUA_TLS_VERIFY // empty' | sed -e 's/^"//' -e 's/"$//')
    echo $AQUA_TLS_VERIFY "---------------------"

    AQUA_ROOT_CA_PATH=$(echo ${AQUA_CONFIG} | jq '.AQUA_ROOT_CA // empty' | sed -e 's/^"//' -e 's/"$//')
    AQUA_PUBLIC_KEY_PATH=$(echo ${AQUA_CONFIG} | jq '.AQUA_PUBLIC_KEY // empty' | sed -e 's/^"//' -e 's/"$//')
    AQUA_PRIVATE_KEY_PATH=$(echo ${AQUA_CONFIG} | jq '.AQUA_PRIVATE_KEY // empty' | sed -e 's/^"//' -e 's/"$//')
    CPU_LIMIT=$(echo ${AQUA_CONFIG} | jq '.AQUA_CPU_LIMIT // empty' | sed -e 's/^"//' -e 's/"$//')
    MEMORY_LIMIT=$(echo ${AQUA_CONFIG} | jq '.AQUA_MEMORY_LIMIT // empty' | sed -e 's/^"//' -e 's/"$//')
    if ([ -z "${AQUA_PUBLIC_KEY_PATH}" ] && [ -n "${AQUA_PRIVATE_KEY_PATH}" ]) || ([ -n "${AQUA_PUBLIC_KEY_PATH}" ] && [ -z "${AQUA_PRIVATE_KEY_PATH}" ]); then
      echo "AQUA_PUBLIC_KEY AQUA_PRIVATE_KEY values are missing from ${AQUA_CONFIG}, incase of self-signed certificates AQUA_ROOT_CA is required"
      exit 1
    fi
    if [ -n "${AQUA_PUBLIC_KEY_PATH}" ] && [ -n "${AQUA_PRIVATE_KEY_PATH}" ]; then
      if [ -n "${AQUA_ROOT_CA_PATH}" ] && [ -e "${AQUA_ROOT_CA_PATH}" ]; then
        ROOT_CA_FILENAME=$(basename "$AQUA_ROOT_CA_PATH")
        AQUA_ROOT_CA="/opt/aquasec/ssl/$ROOT_CA_FILENAME"
      fi  
      PUBLIC_KEY_FILENAME=$(basename "$AQUA_PUBLIC_KEY_PATH")
      PRIVATE_KEY_FILENAME=$(basename "$AQUA_PRIVATE_KEY_PATH")
      AQUA_PUBLIC_KEY="/opt/aquasec/ssl/$PUBLIC_KEY_FILENAME"
      AQUA_PRIVATE_KEY="/opt/aquasec/ssl/$PRIVATE_KEY_FILENAME"
    fi      
    if [ -z "${AQUA_TLS_VERIFY}" ]; then
      echo "Info: AQUA_TLS_VERIFY var is missing, Setting it to 'false'"
      AQUA_TLS_VERIFY=false
      AQUA_ROOT_CA=""
      AQUA_PUBLIC_KEY=""
      AQUA_PRIVATE_KEY=""
    fi
    if [ -z "${AQUA_PUBLIC_KEY_PATH}" ] && [ -z "${AQUA_PRIVATE_KEY_PATH}" ]; then
      echo "Info: AQUA_ROOT_CA, AQUA_PUBLIC_KEY, AQUA_PRIVATE_KEY  var is missing, Setting it to blank "
      AQUA_ROOT_CA=""
      AQUA_PUBLIC_KEY=""
      AQUA_PRIVATE_KEY=""
    fi    
    if [ -z "${GATEWAY_ENDPOINT}" ] || [ -z "${AQUA_TOKEN}" ]; then
      echo "Error: Requires \$GATEWAY_ENDPOINT && \$AQUA_TOKEN to be exposed an ENV variables."
      exit 1
    fi
     if [ -n "${MEMORY_LIMIT}" ]; then
      AQUA_MEMORY_LIMIT=$(echo `echo "1024*1024*1024*${MEMORY_LIMIT}" | bc -l` | cut -d. -f1)
    fi
    if [ -n "${CPU_LIMIT}" ]; then
      AQUA_QUOTA_CPU_LIMIT=$(echo `echo 100000*${CPU_LIMIT} | bc -l` | cut -d. -f1)
    fi
fi
}

is_it_rhel() {
  cat /etc/*release | grep PLATFORM_ID | grep "platform:el8\|platform:el9" &>/dev/null
  if [ $? -eq 0 ]; then
    echo "Info: This is RHEL 8\9 system. Going to apply SELinux policy module"
    SELINUX_POLICY_MODULE="aquavme"
    SELINUX_POLICY_MODULE_FILE="${SELINUX_POLICY_MODULE}.pp"
    ## Install
    if [[ ${1} == "1" ]]; then
      SELINUX_POLICY_MODULE_PATH="/usr/share/selinux/targeted/${SELINUX_POLICY_MODULE_FILE}"
      /usr/sbin/semodule -s targeted -X 300 -i ${SELINUX_POLICY_MODULE_PATH} &>/dev/null || :
      echo "Installed policy module ${SELINUX_POLICY_MODULE}"
    ## Upgrade
    else
      /usr/sbin/semodule -l | grep ${SELINUX_POLICY_MODULE} &>/dev/null
      if [ $? -eq 0 ]; then
        echo "Info: Selinux Policy ${SELINUX_POLICY_MODULE} found on upgrade."
      else
        error_message "Unable to find ${SELINUX_POLICY_MODULE} upgrade, aborting installation."
      fi
    fi
  fi
}

prerequisites_check() {
  load_config_from_env

  is_it_rhel "$@"

  is_root

  if is_bin_in_path runc; then
    echo "Info: runc"
    RUNC_LOCATION=$(which runc)
  elif is_bin_in_path docker-runc; then
    echo "Info: docker-runc"
    RUNC_LOCATION=$(which docker-runc)
  elif is_bin_in_path docker-runc-current; then
    echo "Info: docker-runc-current"
    RUNC_LOCATION=$(which docker-runc-current)
  else
    error_message "runc is not installed on this host"
  fi
  RUNC_VERSION=$(${RUNC_LOCATION} -v | grep runc | awk '{print $3}')
  echo "Info: Detected RunC Version ${RUNC_VERSION}"

  is_bin_in_path docker && warning_message "docker is installed on this host"
  is_bin_in_path crio && warning_message "crio is installed on this host"
  is_bin_in_path containerd && warning_message "containerd is installed on this host"

  is_bin_in_path systemd-run || error_message "systemd is not installed on this host"
  SYSTEMD_VERSION=$(systemd-run --version | grep systemd | awk '{print $2}')
  echo "Info: Detected Systemd Version ${SYSTEMD_VERSION}"

  is_bin_in_path awk || error_message "awk is not installed on this host"
  is_bin_in_path tar || error_message "tar is not installed on this host"
}

edit_templates_rpm() {
  echo "Info: Creating ${ENFORCER_RUNC_CONFIG_FILE_NAME} file."
  sed "s|HOSTNAME=.*\"|HOSTNAME=$(hostname)\"|;
		s|AQUA_PRODUCT_PATH=.*\"|AQUA_PRODUCT_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_INSTALL_PATH=.*\"|AQUA_INSTALL_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_SERVER=.*\"|AQUA_SERVER=${GATEWAY_ENDPOINT}\"|;
		s|AQUA_TOKEN=.*\"|AQUA_TOKEN=${AQUA_TOKEN}\"|;    
		s|LD_LIBRARY_PATH=.*\"|LD_LIBRARY_PATH=/opt/aquasec\"|;
  	s|AQUA_TLS_VERIFY=.*\"|AQUA_TLS_VERIFY=${AQUA_TLS_VERIFY}\"|;
    s|AQUA_ROOT_CA=.*\"|AQUA_ROOT_CA=${AQUA_ROOT_CA}\"|;
    s|AQUA_PUBLIC_KEY=.*\"|AQUA_PUBLIC_KEY=${AQUA_PUBLIC_KEY}\"|;
    s|AQUA_PRIVATE_KEY=.*\"|AQUA_PRIVATE_KEY=${AQUA_PRIVATE_KEY}\"|;
    s|\"limit\"\:.*|\"limit\"\: ${AQUA_MEMORY_LIMIT}|;
    s|AQUA_QUOTA_CPU_LIMIT=.*|AQUA_QUOTA_CPU_LIMIT=${AQUA_QUOTA_CPU_LIMIT}\",\"AQUA_ENFORCER_TYPE=host\"|" ${TEMPLATE_DIR}/${ENFORCER_RUNC_CONFIG_TEMPLATE} >${RUNC_TMP_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}

  echo "Info: Creating ${RUN_SCRIPT_FILE_NAME} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${TEMPLATE_DIR}/${RUN_SCRIPT_TEMPLATE_FILE_NAME} >${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}

  echo "Info: Creating ${ENFORCER_SERVICE_FILE_NAME} file."
  sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${TEMPLATE_DIR}/${SYSTEMD_TEMPLATE_TO_USE} >${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME}

}

systemd_type() {
  SYSTEMD_IS_OLD=false

  SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME}
  if [ "${SYSTEMD_VERSION}" -lt "236" ]; then
    SYSTEMD_IS_OLD=true
    SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD}
  fi
}

untar() {
  ENFORCER_RUNC_TAR_FILE_NAME="aqua-host-enforcer.tar"
  echo "Info: Unpacking enforcer filesystem to ${RUNC_FS_TMP_DIRECTORY}."
  tar -xf ${TMP_DIR}/${ENFORCER_RUNC_TAR_FILE_NAME} -C ${RUNC_FS_TMP_DIRECTORY}
}

runc_type() {
  ENFORCER_RUNC_CONFIG_TEMPLATE="aqua-enforcer-runc-config.json"
  if [[ ${RUNC_VERSION} == "1.0.0-rc1" ]] ||
    [[ ${RUNC_VERSION} == "1.0.0-rc2" ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2-* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2_* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2+* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc2.* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1-* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1_* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1+* ]] ||
    [[ ${RUNC_VERSION} == 1.0.0-rc1.* ]]; then
    ENFORCER_RUNC_CONFIG_TEMPLATE="aqua-enforcer-v1.0.0-rc2-runc-config.json"
  fi
}

setup_rpm_env() {
  INSTALL_PATH="/opt"
  TMP_DIR="/tmp/aqua"
  TEMPLATE_DIR="${TMP_DIR}/templates"
  SYSTEMD_TMP_DIR="${TMP_DIR}/systemd"
  RUNC_TMP_DIRECTORY="${TMP_DIR}/runc"
  RUNC_FS_TMP_DIRECTORY="${TMP_DIR}/fs"
  ENFORCER_RUNC_DIRECTORY="${INSTALL_PATH}/aqua-runc"
  ENFORCER_RUNC_FS_DIRECTORY="${ENFORCER_RUNC_DIRECTORY}/aqua-enforcer"
  SYSTEMD_FOLDER="/etc/systemd/system"
  ENFORCER_SERVICE_FILE_NAME="aqua-enforcer.service"
  ENFORCER_SERVICE_TEMPLATE_FILE_NAME="aqua-enforcer.template.service"
  ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD="aqua-enforcer.template.old.service"
  RUN_SCRIPT_FILE_NAME="run.sh"
  RUN_SCRIPT_TEMPLATE_FILE_NAME="run.template.sh"
  ENFORCER_SERVICE_FILE_NAME_PATH="${SYSTEMD_FOLDER}/${ENFORCER_SERVICE_FILE_NAME}"
  ENFORCER_RUNC_CONFIG_FILE_NAME="config.json"
  ENFORCER_SELINUX_POLICY_FILE_NAME="aquavme.pp"
  AQUA_QUOTA_CPU_LIMIT=200000
  AQUA_MEMORY_LIMIT=2791728742
}

cp_files_rpm() {
  cp --remove-destination -r ${RUNC_TMP_DIRECTORY}/. ${ENFORCER_RUNC_DIRECTORY}/
  cp --remove-destination ${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME} ${ENFORCER_SERVICE_FILE_NAME_PATH}
  cp --remove-destination -r ${RUNC_FS_TMP_DIRECTORY}/. ${ENFORCER_RUNC_FS_DIRECTORY}/
}

create_folder_rpm() {
  mkdir ${INSTALL_PATH}/aquasec 2>/dev/null
  mkdir ${INSTALL_PATH}/aquasec/audit 2>/dev/null
  mkdir ${INSTALL_PATH}/aquasec/tmp 2>/dev/null
  mkdir ${INSTALL_PATH}/aquasec/data 2>/dev/null
  mkdir ${INSTALL_PATH}/aquasec/ssl 2>/dev/null
  if [ -n "${AQUA_ROOT_CA_PATH}" ] && [ -e "${AQUA_ROOT_CA_PATH}" ]; then
    cp ${AQUA_ROOT_CA_PATH} /opt/aquasec/ssl
  fi  
  if [ -n "${AQUA_PUBLIC_KEY_PATH}" ] && [ -n "${AQUA_PRIVATE_KEY_PATH}" ]; then
    cp ${AQUA_PUBLIC_KEY_PATH} /opt/aquasec/ssl
    cp ${AQUA_PRIVATE_KEY_PATH} /opt/aquasec/ssl
  fi 
  rm -f /opt/aquasec/tmp/aquasec.log && touch /opt/aquasec/tmp/aquasec.log
  mkdir -p ${ENFORCER_RUNC_FS_DIRECTORY} 2>/dev/null
  mkdir -p ${TEMPLATE_DIR}
  mkdir -p ${RUNC_TMP_DIRECTORY}
  mkdir -p ${RUNC_FS_TMP_DIRECTORY}
  mkdir -p ${SYSTEMD_TMP_DIR}
}

start_service() {
  echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
  echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
  systemctl start ${ENFORCER_SERVICE_FILE_NAME}
  if [ $? -eq 0 ]; then
    echo "Info: VM Enforcer was successfully deployed and started."
  else
    error_message "Unable to start service. please check the logs."
  fi
}

init_common() {
  setup_rpm_env
  prerequisites_check "$@"
  systemd_type
  runc_type
  create_folder_rpm
}

init_rpm() {
  # is_upgrade
  if [ "${1}" == "-u" ]; then
    systemctl stop ${ENFORCER_SERVICE_FILE_NAME} >/dev/null 2>&1
    cp_files_rpm
    systemctl start ${ENFORCER_SERVICE_FILE_NAME} >/dev/null 2>&1
    return
  fi

  # is_install
  cp_files_rpm
  start_service
}

main() {
  init_common "$@"
  edit_templates_rpm
  untar

  init_rpm "$@"
}

bootstrap_args_rpm() {
  action="$1"

  case "$action" in
  "1" | "install")
    main "$@"
    ;;
  "2" | "upgrade")
    main -u
    ;;
  esac
}

execute_by_env() {
  if [ ! -z "${1}" ]; then
    if [ -z "${1##*[!0-9]*}" ]; then
      echo "Error: Invalid Input, Terminating installation."
      exit
    fi
  fi
  echo "Info: Starting Aqua VM Enforcer RPM installation."
  bootstrap_args_rpm "$@"
}

execute_by_env "$@"
