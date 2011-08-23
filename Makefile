RELEASE=2.0

AISVERSION=1.1.4
AISRELEASE=1
AISDIR=openais-${AISVERSION}
AISSRC=openais-${AISVERSION}.orig.tar.gz

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)

DEBS=									\
	openais-pve_${AISVERSION}-${AISRELEASE}_${ARCH}.deb 		\
	libopenais3-pve_${AISVERSION}-${AISRELEASE}_${ARCH}.deb 	\
	libopenais-pve-dev_${AISVERSION}-${AISRELEASE}_${ARCH}.deb

all: ${DEBS}

${DEBS}: ${AISSRC}
	echo ${DEBS}
	rm -rf ${AISDIR}
	tar xf ${AISSRC} 
	cp -av debian ${AISDIR}/debian
	cd ${AISDIR}; dpkg-buildpackage -rfakeroot -b -us -uc

download:
	rm -rf openais-${AISVERSION} ${AISSRC}
	svn checkout http://svn.fedorahosted.org/svn/openais/tags/openais-${AISVERSION}/ openais-${AISVERSION}
	cd openais-${AISVERSION}; ./autogen.sh
	tar czf ${AISSRC} openais-${AISVERSION}/

.PHONY: upload
upload: ${DEBS}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/openais*.deb
	rm -f /pve/${RELEASE}/extra/libopenais*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEBS} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

.phony: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *.changes *.dsc ${AISDIR}

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}