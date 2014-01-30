#!/bin/sh

POSTUPGRADE_DIR="/root/preupgrade/postupgrade.d"

echo "Running postupgrade scripts..."

if [ -d "${NEWROOT}/${POSTUPGRADE_DIR}" ]; then
    ( cd $NEWROOT ;
      for script in "./${POSTUPGRADE_DIR}"/*/* ; do
          echo "Running ${script##./}..."
          chroot . "$script"
       done
    )
else
    echo "No postupgrade scripts found."
fi

