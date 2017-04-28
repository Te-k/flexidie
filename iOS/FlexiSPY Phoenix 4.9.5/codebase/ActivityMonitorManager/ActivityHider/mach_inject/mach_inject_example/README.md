# Welcome To MachInjectSample

MachInjectSample demonstrate the use of mach inject with the new SMJobBless API. By creating a privileged helper tool with the SMJobBless API, we can avoid asking an admin password each time we need to inject code into a process.

## Description of contents

* MachInjectSample: The app.
* Installer: a helper tool (launch-on-demand) for installing mach_inject_bundle.framework (needed by the injector). This avoid the need to create a pkg installer, as the injector need to know the path to mach_inject_bundle at compile time.
* Injector: a helper tool (launch-on-demand daemon) for injecting code in a process.
* Payload: a bundle running inside the process. For demonstration purpose, it just write a message in /var/log/system.log upon loading.

Before testing, you need to code-sign the app, injector and installer with the same certificate.

For more info about the SMJobBless API, [see here](https://developer.apple.com/library/mac/#documentation/ServiceManagement/Reference/ServiceManagement_header_reference/Reference/reference.html#//apple_ref/doc/uid/TP40012447).
For more info on mach_inject, [see here](https://github.com/rentzsch/mach_inject).
