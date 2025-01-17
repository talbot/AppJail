CP?=cp
FIND?=find
INSTALL?=install
MKDIR?=mkdir
RM?=rm
SED?=sed
PREFIX?=/usr/local

APPJAIL_VERSION?=2.10.0

all: install

install: utils-strip
	# Directories.
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/bin"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/etc"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/etc/rc.d"
	
	# rc scripts.
.for rc_script in appjail appjail-dns appjail-health appjail-natnet
	${INSTALL} -m 555 etc/rc.d/${rc_script}.sh "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/etc/rc.d/${rc_script}"
.endfor

	# Main script.
	${INSTALL} -m 555 appjail.sh "${DESTDIR}${PREFIX}/bin/appjail"

	# Wrappers & misc.
	${INSTALL} -m 555 share/appjail/scripts/dns.sh "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${INSTALL} -m 555 share/appjail/scripts/ajconf.sh "${DESTDIR}${PREFIX}/bin/appjail-config"
	${INSTALL} -m 555 share/appjail/scripts/ajuser.sh "${DESTDIR}${PREFIX}/bin/appjail-user"
	${INSTALL} -m 555 share/appjail/scripts/ajconf-user.sh "${DESTDIR}${PREFIX}/bin/appjail-config-user"

	# cmd
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/cmd"
	${FIND} share/appjail/cmd -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# files
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/files"
	${FIND} share/appjail/files -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# lib
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/lib"
	${FIND} share/appjail/lib -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;

	# version
	${SED} -i '' -e 's|%%VERSION%%|${APPJAIL_VERSION}|' "${DESTDIR}${PREFIX}/share/appjail/lib/version"
	
	# makejail
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd/all"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/cmd/build"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write/all"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/makejail/write/build"

	${FIND} share/appjail/makejail/cmd/all -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/cmd/build -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/write/all -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	${FIND} share/appjail/makejail/write/build -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# scripts
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/appjail/scripts"
	${FIND} share/appjail/scripts -mindepth 1 -exec ${INSTALL} -m 555 {} "${DESTDIR}${PREFIX}/{}" \;
	
	# Prefix.
.for f in bin/appjail bin/appjail-config bin/appjail-config-user bin/appjail-user share/appjail/files/config.conf share/appjail/files/default.conf share/appjail/scripts/runas.sh share/appjail/scripts/ajuser.sh
	${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|' "${DESTDIR}${PREFIX}/${f}"
.endfor

	# examples
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/examples/appjail"
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/share/examples/appjail/templates"
	${FIND} share/examples/appjail/templates -mindepth 1 -exec ${INSTALL} -m 444 {} "${DESTDIR}${PREFIX}/{}" \;
	${INSTALL} -m 444 share/examples/appjail/appjail.conf "${DESTDIR}${PREFIX}/share/examples/appjail/appjail.conf"

	# utils
.for util in find-number-from-start find-smallest-missing-number getservbyname ipcheck network
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/libexec/appjail/${util}"
	${INSTALL} -m 555 libexec/${util}/${util} "${DESTDIR}${PREFIX}/libexec/appjail/${util}/${util}"
.endfor
	# appjail-config & tok
	${MKDIR} -m 755 -p "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config"
	${INSTALL} -m 555 libexec/appjail-config/appjail-config "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config/appjail-config"
	${INSTALL} -m 555 libexec/appjail-config/tok "${DESTDIR}${PREFIX}/libexec/appjail/appjail-config/tok"

utils-strip:
	@${MAKE} -C libexec strip

utils-clean:
	@${MAKE} -C libexec clean

utils-cleanall:
	@${MAKE} -C libexec cleanall

clean: utils-clean

cleanall: utils-cleanall

uninstall:
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-config"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-config-user"
	${RM} -f "${DESTDIR}${PREFIX}/bin/appjail-user"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-dns"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-health"
	${RM} -f "${DESTDIR}${PREFIX}/etc/rc.d/appjail-natnet"
	${RM} -rf "${DESTDIR}${PREFIX}/share/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/share/examples/appjail"
	${RM} -rf "${DESTDIR}${PREFIX}/libexec/appjail"
