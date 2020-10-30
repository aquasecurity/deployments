#!/usr/bin/env bash

is_bin_in_path(){
  builtin type -P "$1" &> /dev/null
}

is_root(){
	if [ "$EUID" -ne 0 ]; then
	  error_message "This util need to run as root"
	fi
}

error_message(){
  echo "Error: $1"
  exit 1
}

prerequisites_check(){
	is_root
	
	if [ -z "$ENFORCER_VERSION" ] || [ -z "$AQUA_USERNAME" ] || [ -z "$AQUA_PWD" ] || [ -z "$GATEWAY_ENDPOINT" ];then
		usage
		exit 1
	fi	
	
	if is_bin_in_path runc; then
		RUNC_LOCATION=$(which runc)
	elif is_bin_in_path docker-runc;then 
		RUNC_LOCATION=$(which docker-runc)
	elif is_bin_in_path docker-runc-current;then
		RUNC_LOCATION=$(which docker-runc-current)
	else
		error_message "runc is not installed on this host"
	fi
	RUNC_VERSION=$($RUNC_LOCATION -v | grep runc | awk '{print $3}')

	is_bin_in_path docker && error_message "docker is installed on this host"
	is_bin_in_path crio && error_message "crio is installed on this host"
	is_bin_in_path containerd && error_message "containerd is installed on this host"
	
	
	is_bin_in_path systemd || error_message "systemd is not installed on this host"
	SYSTEMD_VERION=$(systemd --version| grep systemd|awk '{print $2}')

	is_bin_in_path curl || error_message "curl is not installed on this host"
	is_bin_in_path awk || error_message "awk is not installed on this host"
	is_bin_in_path jq || error_message "jq is not installed on this host"
	is_bin_in_path tar || error_message "tar is not installed on this host"
}

is_flag_value_valid(){
	[ -z "$2" ] && error_message "Value is missing. please set $1 [value]"
	flags=( "-v" "--version" "-u" "--aqua-username" "-p" "--aqua-password" "-t" "--token" "-g" "--gateway" "-f" "--tar-file" "-c" "--config-file" "-i" "--install-path")
	for flag in "${flags[@]}";do
		   if [ "${flag}" == "$2" ];then
				error_message "Value is missing. please set $1 [value]"
			fi
	done
}

get_templates(){
	curl -s -o ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME} https://raw.githubusercontent.com/aquasecurity/deployments/master/automation/aquactl/host/enforcer/aqua-enforcer.template.service
	curl -s -o ${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD} https://raw.githubusercontent.com/aquasecurity/deployments/master/automation/aquactl/host/enforcer/aqua-enforcer.template.old.service
	curl -s -o ${RUN_SCRIPT_TEMPLATE_FILE_NAME} https://raw.githubusercontent.com/aquasecurity/deployments/master/automation/aquactl/host/enforcer/run.template.sh
}

get_app(){

	ENFORCER_RUNC_TAR_FILE_NAME="aqua-host-enforcer.${ENFORCER_VERSION}.tar"  
	ENFORCER_RUNC_TAR_FILE_URL="https://download.aquasec.com/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_TAR_FILE_NAME}"    
	ENFORCER_RUNC_CONFIG_URL="https://download.aquasec.com/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_CONFIG_TEMPLATE}"
	ENFORCER_RUNC_TAR_FILE_URL_DEV="https://download.aquasec.com/internal/host-enforcer/${ENFORCER_VERSION}/${ENFORCER_RUNC_TAR_FILE_NAME}"
	ENFORCER_RUNC_CONFIG_URL_DEV="https://download.aquasec.com/internal/host-enforcer/${ENFORCER_VERSION}/aqua-enforcer-runc-config.json"
	ENFORCER_RUNC_OLD_CONFIG_URL_DEV="https://download.aquasec.com/internal/host-enforcer/${ENFORCER_VERSION}/aqua-enforcer-v1.0.0-rc2-runc-config.json"

	if ! curl --output /dev/null --silent --head --fail -u ${AQUA_USERNAME}:${AQUA_PWD} ${ENFORCER_RUNC_TAR_FILE_URL}; then
	  error_message "Unable to download package. please check credentials or the version"
	fi
	
	echo "Info: Downloading enforcer filesystem version ${ENFORCER_VERSION}."
	curl -u ${AQUA_USERNAME}:${AQUA_PWD} -s -o ${ENFORCER_RUNC_TAR_FILE_NAME} ${ENFORCER_RUNC_TAR_FILE_URL}
	echo "Info: Downloading enforcer config file template ${ENFORCER_RUNC_CONFIG_TEMPLATE}."
	curl -u ${AQUA_USERNAME}:${AQUA_PWD} -s -o ${ENFORCER_RUNC_CONFIG_TEMPLATE} ${ENFORCER_RUNC_CONFIG_URL}
}


edit_templates(){
	echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME} file."
	jq ".process.env = [\"PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\",\"HOSTNAME=$(hostname)\",\"TERM=xterm\",\"AQUA_PRODUCT_PATH=${INSTALL_PATH}/aquasec\",\"AQUA_INSTALL_PATH=${INSTALL_PATH}/aquasec\",\"AQUA_MODE=SERVICE\",\"RESTART_CONTAINERS=no\",\"AQUA_LOGICAL_NAME=Default\",\"AQUA_SERVER=${GATEWAY_ENDPOINT}\",\"AQUA_TOKEN=${TOKEN}\",\"LD_LIBRARY_PATH=/opt/aquasec\",\"AQUA_ENFORCER_TYPE=host\"]" ${ENFORCER_RUNC_CONFIG_TEMPLATE} > ${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}
	
	echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${RUN_SCRIPT_TEMPLATE_FILE_NAME} > ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}
	
	echo "Info: Creating ${ENFORCER_SERVICE_SYSTEMD_FILE_PATH} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${SYSTEMD_TEMPLATE_TO_USE} > ${ENFORCER_SERVICE_SYSTEMD_FILE_PATH}

}

systemd_type(){
	SYSTEMD_IS_OLD=false
	SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME}
	if [ $SYSTEMD_VERION -lt 236 ];then
		SYSTEMD_IS_OLD=true
		SYSTEMD_TEMPLATE_TO_USE=${ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD}
	fi
}

untar(){
	echo "Info: Unpacking enforcer filesystem to ${ENFORCER_RUNC_FS_DIRECTORY}."
	tar -xf ${ENFORCER_RUNC_TAR_FILE_NAME} -C ${ENFORCER_RUNC_FS_DIRECTORY}
}

runc_type(){
	ENFORCER_RUNC_CONFIG_TEMPLATE="aqua-enforcer-runc-config.json"
	if [[ $RUNC_VERSION == "1.0.0-rc1" ]] \
    || [[ $RUNC_VERSION == "1.0.0-rc2" ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc2-* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc2_* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc2+* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc2.* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc1-* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc1_* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc1+* ]] \
    || [[ $RUNC_VERSION == 1.0.0-rc1.* ]];then
		ENFORCER_RUNC_CONFIG_TEMPLATE="aqua-enforcer-v1.0.0-rc2-runc-config.json"
	fi
}

start_service(){
    echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
	systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
    echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
	systemctl start ${ENFORCER_SERVICE_FILE_NAME}
    if [ $? -eq 0 ];then
        echo "Info: VM Enforcer was successfully deployed and started."
    else
        error_message "Unable to start service. please check the logs."
    fi
}

craete_folder(){
	mkdir ${INSTALL_PATH}/aquasec
	mkdir ${INSTALL_PATH}/aquasec/audit
	mkdir ${INSTALL_PATH}/aquasec/tmp	
	mkdir ${INSTALL_PATH}/aquasec/data
	touch ${INSTALL_PATH}/aquasec/tmp/aqua-enforcer.log
	mkdir -p ${ENFORCER_RUNC_FS_DIRECTORY}
}

usage(){
cat << EOF

Usage:
  sudo ./vm-enforcer-deployer.sh [flags]

Flags:
  -u, --aqua-username string   Aqua username
  -p, --aqua-password string   Aqua password
  -g, --gateway string         Aqua Gateway address
  -t, --token string           Aqua Enforcer token
  -v, --version string         Aqua Enforcer version

EOF
}


# Main
# -----------

INSTALL_PATH="/opt"
ENFORCER_RUNC_DIRECTORY="${INSTALL_PATH}/aqua-runc"
ENFORCER_RUNC_FS_DIRECTORY="${ENFORCER_RUNC_DIRECTORY}/aqua-enforcer"
SYSTEMD_FOLDER="/etc/systemd/system"
ENFORCER_SERVICE_FILE_NAME="aqua-enforcer.service"
ENFORCER_SERVICE_TEMPLATE_FILE_NAME="aqua-enforcer.template.service"
ENFORCER_SERVICE_TEMPLATE_FILE_NAME_OLD="aqua-enforcer.template.old.service"
RUN_SCRIPT_FILE_NAME="run.sh"
RUN_SCRIPT_TEMPLATE_FILE_NAME="run.template.sh"
ENFORCER_SERVICE_SYSTEMD_FILE_PATH="${SYSTEMD_FOLDER}/${ENFORCER_SERVICE_FILE_NAME}"
ENFORCER_RUNC_CONFIG_FILE_NAME="config.json"

for arg in "$@";do
    case $arg in
        -v|--version)
		is_flag_value_valid "-v|--version" "$2"
        ENFORCER_VERSION="$2"
        shift 
        shift 
        ;;
        -u|--aqua-username)
		is_flag_value_valid "-u|--aqua-username" "$2"
        AQUA_USERNAME="$2"
        shift 
        shift 
        ;;
        -p|--aqua-password)
		is_flag_value_valid "-p|--aqua-password" "$2"
        AQUA_PWD="$2"
        shift 
        shift 
        ;;
        -t|--token)
		is_flag_value_valid "-t|--token" "$2"
        TOKEN="$2"
        shift 
        shift 
        ;;
        -g|--gateway)
		is_flag_value_valid "-g|--gateway" "$2"
        GATEWAY_ENDPOINT="$2"
        shift 
        shift 
        ;;
        -f|--tar-file)
		is_flag_value_valid "-f|--tar-file" "$2"
        TAR_FILE="$2"
        shift 
        shift 
        ;;
        -c|--config-file)
		is_flag_value_valid "-c|--config-file" "$2"
        CONFIG_FILE="$2"
        shift 
        shift 
        ;;
        -i|--install-path)
		is_flag_value_valid "-i|--install-path" "$2"
        INSTALL_PATH="$2"
        shift 
        shift 
        ;;
        --custom-envs)
        CUSTOM_ENVS="$2"
        shift 
        shift 
        ;;			
    esac
done

prerequisites_check
systemd_type
runc_type
craete_folder
get_templates
get_app
edit_templates
untar
start_service