#!/bin/sh

# Clean up
purge-old-kernels
apt-get -y autoremove --purge
apt-get -y clean

# Clear history
history -c

# Remove temporary files
rm -rf /tmp/*

