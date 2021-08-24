#!/bin/sh

# Prepares VM golden image for deployment of VM enforcer
# Preparation is done as follows:
# 1. perform cleanup of previously installed VM enforcer (stop and remove data).
# 2. create special GOLDEN_IMAGE file to control VM enforcer to be deployed into image.

AQUA_ROOT_DIR=
SILENT_MODE=0
DEBUG_MODE=0

display_usage()
{
	echo "Aqua Security Golden Image Preparation script"
	echo "Usage: $(basename $0) [ --silent | --help ]"

	exit 0
}

check_permissions()
{
	[ $(id -u) != 0 ] && echo "ROOT privileges are required to run this script." && exit 1
}

parse_command_line()
{
	while [ $# -gt 0 ]; do
		case "$1" in
			--silent ) SILENT_MODE=1 ;;
			--debug  ) DEBUG_MODE=1 ;;
			--help   ) display_usage ;;
		esac
		shift
	done
}

display_prompt()
{
	echo
	echo -n "The Aqua Golden Image preparation script will perform irreversible cleanup actions on the VM Enforcer. Proceed? [Y/N]: "
	read user_input
	[ "$user_input" != "y" ] && exit 0
}

dbg()
{
	[ "$DEBUG_MODE" = 1 ] && echo $1
}

detect_install_dir()
{
	dbg "[debug]: detecting VM enforcer installation directory"
	if [ -f /etc/aquasec ]; then
		# Try reading installation directory path from the configuration file.
		dbg "[debug]: trying to read installation path from file /etc/aquasec"
		AQUA_ROOT_DIR=$(cat /etc/aquasec)
	fi
	if [ ! -d "$AQUA_ROOT_DIR" ]; then
		dbg "[debug]: trying /opt/aquasec as installation path"
		AQUA_ROOT_DIR=/opt/aquasec 
	fi
	if [ ! -d "$AQUA_ROOT_DIR" ]; then
		dbg "[debug]: trying /var/lib/aquasec as installation path"
		AQUA_ROOT_DIR=/var/lib/aquasec
	fi
	if [ ! -d "$AQUA_ROOT_DIR" ]; then
		# Try reading installation directory path from the environment variable.
		dbg "[debug]: trying to read installation path from AQUA_INSTALL_PATH environment variable"
		AQUA_ROOT_DIR=$(printenv AQUA_INSTALL_DIR)
	fi
	if [ ! -d "$AQUA_ROOT_DIR" ]; then
		echo "Failed detecting VM enforcer intallation directory, exiting."
		exit 1
	fi
}

stop_vm_enforcer()
{
	dbg "[debug]: stopping VM enforcer"
	vm_enforcer_service="aqua-enforcer"
	rc=0
	for i in {1..3}; do
		systemctl stop "$vm_enforcer_service" 2>&1 | grep -iv "not loaded"
		systemctl is-active --quiet "$vm_enforcer_service"
		rc=$?

		[ "$rc" != 0 ] && break

		sleep 1s
	done
	
	if [ "$rc" = 0 ]; then
		# Case when service is still running.
		echo "Failed stopping vm enforcer, exiting"
		exit 1
	fi
}

delete_vm_enforcer_data()
{
	dbg "[debug]: deleting VM enforcer data"
	db_dir="$AQUA_ROOT_DIR"/data	
	rm -rf "$db_dir"/*
	rm -rf "$db_dir"/guid
}


create_golden_image_file()
{
	dbg "[debug]: creating golden image file"
	touch "$AQUA_ROOT_DIR"/GOLDEN_IMAGE
}

parse_command_line "$@"
check_permissions
detect_install_dir

[ "$SILENT_MODE" = 0 ] && display_prompt

echo "Please wait."
stop_vm_enforcer
delete_vm_enforcer_data

create_golden_image_file

echo "Operation successful. The VM Enforcer is ready for Golden Image creation."

exit 0
