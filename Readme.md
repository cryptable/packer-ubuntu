EJBCA Packer template
=====================

Introduction
------------

This is a Hashicorp packer file to build an Ubuntu template for VMWare and Proxmox.

Setup
-----

1) Verify the template variables in the image-configs directory. Create a copy from the templates to your technology.

You can build them using command:
```
./build.sh <domain> <proxmox|vmware>
```

It will concatenate to the template in the image-configs directory:

- <domain>-<vm-technolofy>.shvars : settings to create the cloud-init user-date file
- <domain>-<vm-technolofy>.pkrvars.hcl: settings to build the images


TODO
----
- Testing on VMWare

Notes
-----