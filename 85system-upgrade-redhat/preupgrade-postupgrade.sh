#!/bin/sh

POSTUPGRADE_DIR="/root/preupgrade/postupgrade.d"

echo "Running postupgrade scripts..."

if [ -d "${NEWROOT}/${POSTUPGRADE_DIR}" ]; then
    ( cd $NEWROOT ;

      find "./${POSTUPGRADE_DIR}" -type f -perm /u+x -exec ls -1 {} + | \
        while read -r script ; do
          echo "Running ${script##./}..."
          scriptdir="$(echo "${script}" | sed 's|^\(.*\)/\([^/]*\)$|\1|')"
          scriptbase="$(echo "${script}" | sed 's|^\(.*\)/\([^/]*\)$|\2|')"
          chroot . /bin/sh -c "cd \"${scriptdir}\" && ./\"${scriptbase}\""
       done
    )
else
    echo "No postupgrade scripts found."
fi

