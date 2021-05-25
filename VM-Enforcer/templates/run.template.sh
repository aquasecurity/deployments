#!/bin/bash

{{ .Values.RuncPath }} run -d --pid-file /run/aqua-enforcer.pid enforcer > /var/log/aquasec.log 2>&1

exit 0
