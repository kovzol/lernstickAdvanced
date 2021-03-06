#!/bin/sh

pin_package()
{
	PACKAGE=$1
	VERSION=$(dpkg -s ${PACKAGE} | grep "Version:" | awk '{ print $2 }')
	if [ -n "${VERSION}" ]
	then
		if grep -q "Package: ${PACKAGE}" /etc/apt/preferences
		then
			# the package record is already there (because of a backports definition or similar)
			# just set the pin value to the current package version
			sed -i "/Package: ${PACKAGE}/{N;s/Package: ${PACKAGE}\nPin: .*/Package: ${PACKAGE}\nPin: version ${VERSION}/g}" /etc/apt/preferences
		else
			# the package record is still missing
			# append a new package record
			echo "
Package: ${PACKAGE}
Pin: version ${VERSION}
Pin-Priority: 999" >> /etc/apt/preferences
		fi
	fi
}

for i in /lib/modules/*
do
	pin_package "linux-image-$(echo ${i} | awk -F/ '{ print $4 }')"
done

for i in /usr/src/linux-headers-*
do
	pin_package $(echo ${i} | awk -F/ '{ print $4 }')
done

pin_package "linux-base" 
pin_package "linux-libc-dev" 
pin_package "live-boot" 
pin_package "live-boot-initramfs-tools" 
pin_package "live-initramfs" 
