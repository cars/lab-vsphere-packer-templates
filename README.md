12345678901234567890123456789012345678901234567890123456789012345678901234567890
This project is one I use to regularly build Windows VM Template in my vCenter 
lab. 

It contains (windows directory) a trimmed down copy of the boxcutter windows 
project (https://github.com/boxcutter/windows) for building Windows VM templates. 
This version is focused on Windows 2016 and uses the packer builder from 
(https://github.com/jetbrains-infra/packer-builder-vsphere)

The second piece (vSphere_Template_Builds) is the configuration of a Jenkins 
job that regulalry builds the template using the packer plugin. 
