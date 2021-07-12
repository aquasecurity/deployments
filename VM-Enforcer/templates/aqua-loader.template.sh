#!/usr/bin/env bash

error_message(){
    echo "Error: ${1}"
    exit 1
}


load_aqua_rpm_config() {
	CONFIG_FILE="/etc/conf/aquavmenforcer.json"
    if [ ! -f ${CONFIG_FILE} ]; then
        echo "Config File not found, Setting Default Configuration!"
        GATEWAY_ENDPOINT=""
        AQUA_TOKEN=""
    else
        AQUA_CONFIG=$(cat ${CONFIG_FILE})
        GATEWAY_ENDPOINT=$(echo ${AQUA_CONFIG} | jq .AQUA_GATEWAY | sed -e 's/^"//' -e 's/"$//')
        AQUA_TOKEN=$(echo ${AQUA_CONFIG}| jq .AQUA_TOKEN | sed -e 's/^"//' -e 's/"$//')
        if [ -z "${GATEWAY_ENDPOINT}" ] || [ -z "${AQUA_TOKEN}" ]; then
            echo "Requires \$GATEWAY_ENDPOINT && \$AQUA_TOKEN to be exposed an ENV variables."
            exit 1
        fi
    fi
}


load_config_values() {
	if [ ! -f {{ .Values.LoaderEnvPath }} ]; then
		error_message "Environment Config file not found"
	fi
	source {{ .Values.LoaderEnvPath }}
	if [ "${ENV}" == "rpm" ]; then
		load_aqua_rpm_config
	fi
}


edit_templates_rpm(){
	echo "Info: Creating ${ENFORCER_RUNC_CONFIG_FILE_NAME} file."
	sed "s|HOSTNAME=.*\"|HOSTNAME=$(hostname)\"|;
		s|AQUA_PRODUCT_PATH=.*\"|AQUA_PRODUCT_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_INSTALL_PATH=.*\"|AQUA_INSTALL_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_SERVER=.*\"|AQUA_SERVER=${GATEWAY_ENDPOINT}\"|;
		s|AQUA_TOKEN=.*\"|AQUA_TOKEN=${AQUA_TOKEN}\"|;
		s|LD_LIBRARY_PATH=.*\"|LD_LIBRARY_PATH=/opt/aquasec\",\"AQUA_ENFORCER_TYPE=host\"|" ${TEMPLATE_DIR}/${ENFORCER_RUNC_CONFIG_TEMPLATE} > ${RUNC_TMP_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}

	echo "Info: Creating ${RUN_SCRIPT_FILE_NAME} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${TEMPLATE_DIR}/${RUN_SCRIPT_TEMPLATE_FILE_NAME} > ${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${RUNC_TMP_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}

	echo "Info: Creating ${ENFORCER_SERVICE_FILE_NAME} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${TEMPLATE_DIR}/${SYSTEMD_TEMPLATE_TO_USE} > ${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME}

}


edit_templates_sh(){
	echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME} file."

	sed "s|HOSTNAME=.*\"|HOSTNAME=$(hostname)\"|;
		s|AQUA_PRODUCT_PATH=.*\"|AQUA_PRODUCT_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_INSTALL_PATH=.*\"|AQUA_INSTALL_PATH=${INSTALL_PATH}/aquasec\"|;
		s|AQUA_SERVER=.*\"|AQUA_SERVER=${GATEWAY_ENDPOINT}\"|;
		s|AQUA_TOKEN=.*\"|AQUA_TOKEN=${AQUA_TOKEN}\"|;
		s|LD_LIBRARY_PATH=.*\"|LD_LIBRARY_PATH=/opt/aquasec\",\"AQUA_ENFORCER_TYPE=host\"|" ${WORKING_DIR}/${ENFORCER_RUNC_CONFIG_TEMPLATE} > ${ENFORCER_RUNC_DIRECTORY}/${ENFORCER_RUNC_CONFIG_FILE_NAME}


	echo "Info: Creating ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_" ${WORKING_DIR}/${RUN_SCRIPT_TEMPLATE_FILE_NAME} > ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME} && chmod +x ${ENFORCER_RUNC_DIRECTORY}/${RUN_SCRIPT_FILE_NAME}

	echo "Info: Creating ${ENFORCER_SERVICE_FILE_NAME_PATH} file."
	sed "s_{{ .Values.RuncPath }}_${RUNC_LOCATION}_;s_{{ .Values.WorkingDirectory }}_${ENFORCER_RUNC_DIRECTORY}_" ${WORKING_DIR}/${SYSTEMD_TEMPLATE_TO_USE} > ${ENFORCER_SERVICE_FILE_NAME_PATH}

}


edit_templates() {
    if [ "${ENV}" == "rpm" ]; then
        edit_templates_rpm
    else
        edit_templates_sh
    fi
}


cp_files_rpm() {
	cp --remove-destination -r ${RUNC_TMP_DIRECTORY}/. ${ENFORCER_RUNC_DIRECTORY}/
    cp --remove-destination ${SYSTEMD_TMP_DIR}/${ENFORCER_SERVICE_FILE_NAME} ${ENFORCER_SERVICE_FILE_NAME_PATH}
	cp --remove-destination -r ${RUNC_FS_TMP_DIRECTORY}/. ${ENFORCER_RUNC_FS_DIRECTORY}/
}


remove_existing_service() {
	systemctl --all --type service | grep -q "${ENFORCER_SERVICE_FILE_NAME}" 2>/dev/null
	if  [ $? -eq 0 ]; then
		echo "Info: Found existing ${ENFORCER_SERVICE_FILE_NAME}."
		systemctl stop ${ENFORCER_SERVICE_FILE_NAME}
		systemctl disable ${ENFORCER_SERVICE_FILE_NAME}
		rm -f /etc/systemd/system/${ENFORCER_SERVICE_FILE_NAME}
		rm -f /usr/lib/systemd/system/${ENFORCER_SERVICE_FILE_NAME}
		rm -f /etc/init.d/${ENFORCER_SERVICE_FILE_NAME}
		rm -f /var/log/aquasec.log && touch /var/log/aquasec.log
		systemctl daemon-reload
		systemctl reset-failed
		if [ $? -eq 0 ]; then
			echo "Info: Removed previous aqua enforcer service."
		else
			error_message "Unable to remove previous enforcer service. please check the logs."
		fi
	fi
}


start_service() {
	systemctl daemon-reload
	if [ "${ENV}" == "rpm" ]; then
		echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
		systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
		echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
		systemctl start ${ENFORCER_SERVICE_FILE_NAME}
		if [ $? -eq 0 ]; then
			echo "Info: VM Enforcer is successfully deployed and started."
		else
			error_message "Unable to start enforcer service. please check the logs."
		fi
	else
		systemctl --all --type service | grep -q "${ENFORCER_SERVICE_FILE_NAME}" 2>/dev/null
		if  [ $? -eq 0 ]; then
			echo "Info: Found existing ${ENFORCER_SERVICE_FILE_NAME}."
			systemctl stop ${ENFORCER_SERVICE_FILE_NAME}
			rm -f /var/log/aquasec.log && touch /var/log/aquasec.log
			systemctl start ${ENFORCER_SERVICE_FILE_NAME}
			if [ $? -eq 0 ]; then
				echo "Info: VM Enforcer service is successfully re-deployed and started."
			else
				error_message "Unable to re-start enforcer service. please check the logs."
			fi
		else
			echo "Info: Enabling the ${ENFORCER_SERVICE_FILE_NAME} service."
			systemctl enable ${ENFORCER_SERVICE_FILE_NAME}
			echo "Info: Starting the ${ENFORCER_SERVICE_FILE_NAME} service."
			systemctl start ${ENFORCER_SERVICE_FILE_NAME}
			if [ $? -eq 0 ]; then
				echo "Info: VM Enforcer is successfully deployed and started."
			else
				error_message "Unable to start enforcer service. please check the logs."
			fi
		fi
	fi

}


main() {
	load_config_values
	edit_templates
	if [ "${ENV}" == "rpm" ]; then
		remove_existing_service
        cp_files_rpm
    fi
	start_service
}


main "$@"