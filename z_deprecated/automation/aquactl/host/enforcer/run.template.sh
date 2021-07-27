#!/bin/bash

{{ .Values.RuncPath }} run -d --pid-file /run/aqua-enforcer.pid enforcer > /opt/aquasec/tmp/aqua-enforcer.log 2>&1

exit 0