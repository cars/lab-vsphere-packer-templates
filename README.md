# vSphere Lab Templates

This project is one I use to regularly build VM Template in my vCenter 
lab.

It contains (windows directory) a trimmed down copy of the boxcutter windows
project (https://github.com/boxcutter/windows) for building Windows VM templates.
This version is focused on Windows 2016 and uses the packer builder from
(https://github.com/jetbrains-infra/packer-builder-vsphere)

It also contains a centos image. 

In addition the Jenkins job and pipeline I use to build these are included. 

## ToDo

* use cluster setting in packer versus specifying a host
* add windows 2019
