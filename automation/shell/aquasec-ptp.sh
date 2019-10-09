#!/bin/sh

##----------------MODIFY BETWEEN THESE LINES IF NECESSARY-----------------------
##Version, used for the specific release of the product
version=$1
##tag_name, used to identify the string for the tag_name
##usage $tag_name/aqua-component:$version
tag_name=$2
##------------------------------------------------------------------------------
  #Docker pull, to pull the iamges based on version
docker pull registry.aquasec.com/enforcer:$version
docker pull registry.aquasec.com/console:$version
docker pull registry.aquasec.com/gateway:$version
docker pull registry.aquasec.com/scanner:$version
docker pull registry.aquasec.com/database:$version

#tag
docker tag registry.aquasec.com/console:$version $tag_name/aqua-console:$version
docker tag registry.aquasec.com/gateway:$version $tag_name/aqua-gateway:$version
docker tag registry.aquasec.com/scanner:$version $tag_name/aqua-scanner:$version
docker tag registry.aquasec.com/enforcer:$version $tag_name/aqua-enforcer:$version
docker tag registry.aquasec.com/database:$version $tag_name/database:$version

#push
docker push $tag_name/aqua-console:$version
docker push $tag_name/aqua-gateway:$version
docker push $tag_name/aqua-scanner:$version
docker push $tag_name/aqua-enforcer:$version
docker push $tag_name/database:$version

echo ""
echo "Done pulling, tagging, and pushing"
echo ""
