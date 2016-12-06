#!/bin/bash
set -e

#  Christophe Cassagnabere & David Giangiacomo
#       Custom script to set automatically the version number
#       for PHP apps in debian packages.
#

# Import global variables
. package_variables

VERSION=`date "+%y.%m.%d.%H.%M"`
REVISION=`git log --pretty=format:'%h' -n 1`

# Replace global variables in template files
echo "> Processing templates"
for i in `find . -name '*.dh'`
do
	#Removing file extension and keeping full path
	FILENAME=${i%%.dh}
	cp ${i} ${FILENAME}
	for line in `grep "=" package_variables`; do
		# Get variable name
		VARIABLE=${line%%=*};
		# Check that variable name AND value are not empty
		if ! [[ -z "${VARIABLE}" || -z "${!VARIABLE}" ]]; then
			sed -i "s/#${VARIABLE}#/${!VARIABLE}/g" ${FILENAME}
		fi
	done
	sed -i "s/#VERSION#/${VERSION}/" ${FILENAME}
	sed -i "s/#REVISION#/${REVISION}/" ${FILENAME}
done

# Prepares unpacked war deployment
echo "> Unpacking war"
for i in `find binaries/ -name '*.war'`
do
    mkdir -p webapps
    FILENAME=`basename ${i} .war`    
    unzip -q ${i} -d webapps/${FILENAME}
    cp binaries/${FILENAME}.xml webapps/${FILENAME}.xml
    if ! [ -z "${PACKAGE_NAME}" ]; then
        sed -i "s/#PACKAGE_NAME#/${PACKAGE_NAME}/g" webapps/${FILENAME}.xml
    fi
    if ! [ -z "${APP_NAME}" ]; then
        sed -i "s/#APP_NAME#/${APP_NAME}/g" webapps/${FILENAME}.xml
    fi
done

# Create changelog if it doesn't exist
if ! [ -f "debian/changelog" ]; then
    echo "${PACKAGE_NAME} (00.01.01.01-r1) lucid; urgency=low

  * Initial release: template version

 --  Ymagis Devteam <devteam@ymagis.com>  Thu, 01 January 2000 00:00:00 +0100" > debian/changelog
fi

echo "> Building package"
# Tagging changelog
#dch -v ${VERSION}-r${REVISION} "New upstream release"
rm -f ../*.dsc ../*.changes ../*.tar.gz ../*.deb
 
dpkg-buildpackage -us -uc -rfakeroot -edevteam@ymagis.com

# Clearing temp files
echo "Clearing temp files"
for i in `find . -name '*.dh'`
do
    #Removing file extension and keeping full path
    FILENAME=${i%%.dh}
    rm ${FILENAME}
done
if ! [ -z "${PACKAGE_NAME}" ]; then
    rm -Rf debian/${PACKAGE_NAME}*
fi
rm -Rf webapps debian/files build-stamp configure-stamp