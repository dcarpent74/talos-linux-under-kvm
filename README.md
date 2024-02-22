# talos-linux-under-kvm
An experiment in trying out Talos Linux in a pinch

---

I decided to try Talos Linux as an easy Kubernetes setup.  It certainly looks like
it should be easy.  At first I started with a Windows 10 Laptop with 16 GB of RAM
and Hyper-V.  I tried to squeeze three VMs on that, which sort of worked.

I had to search through the other setup instructions as the commands under the
Hyper-V section seemed to no be quite right (perhaps due to updates to the talosctl
options). Once I had that figured out, it took a number of spontanious reboots
and manually configuring each node multiple times because of the reboots to finally
get the nodes configured. The control plane struggled to come up with multiple
container restarts, but I finally had a basic Talos Kubernetes cluster on the laptop.
I pretty much had no hope of going further with the cluster than this.  The laptop
was clearly at it limit, but it worked.

So maybe I should try this on a KVM server where I have more resources...  The comment
in the [KVM section](https://www.talos.dev/v1.6/talos-guides/install/virtualized-platforms/kvm/)
was a little daunting, "Talos is known to work on KVM. We don’t yet have a documented
guide specific to KVM..." At this point I was in a hurry to get something to work, so
here it goes...

I used the same TALOS release downloads as I did for Windows / Hyper-V.
Under the [1.6.4 release](https://github.com/siderolabs/talos/releases/tag/v1.6.4).
Note the latest has moved up...  Check the [releases page](https://github.com/siderolabs/talos/releases)
for the latest.  From there I downloaded the [metal-amd64 ISO](https://github.com/siderolabs/talos/releases/download/v1.6.4/metal-amd64.iso)
and the [linux-amd64 talosctl](https://github.com/siderolabs/talos/releases/download/v1.6.4/talosctl-linux-amd64).
Again, the links here are the 1.6.4 version which is no longer latest, so you should
probably refind these under the [releases page](https://github.com/siderolabs/talos/releases).

I saved off scripts for the Windows setup, and then allocated some VMs on a Linux
KVM server.  In my case I am using OpenSUSE LEAP 15.5 on an old Intel Westermere
system (L5640) with 24 BG of RAM.  I allocated each VM with 4GB of RAM and 4 VCPUs.
I also allocated a 200 GB virtual disk for each (which is probably more than I needed
at the moment, but I am using LVM and this is a backup server, so disk space is cheap
and plentiful.

I made my original node using the virt-manager GUI.  My sanitized config XML is in the
config directory here, and the other two nodes were contrsucted by simply copying and
renaming the XML from the first.
* virsh dumpxml <domainname> > Node-0.xml
* cp Node-0.xml Node-1.xml
* Using text editor update the Node-1.xml file:
  * remove the uuid (near the beginning) line.
  * remove the mac (in the virtual ethernet device section) line.
  * Update the Name and description lines.
  * Change the virtual disk line.
  * Since I used LVM, I allocate the virtual disk volume outside of virsh or virt-manager.
* virsh define Node-1.xml
* And likewise for Node-2.

I also needed to do some light translation from Powershell to bash. but the same there was
little else required to get my KVM cluster running.

Running the scripts in order (names for order here):

00-cp-config.sh generates the controlplane.yaml and worker.yaml for the cluster (these are
also included in the config directory here).  After running this I needed to edit the two
yaml files.  Since my disks are using the virtio drivers, I need to alter the line
"disk: /dev/sda" to "disk: /ded/vda" in the "install:" section.

01-cp.up, 02.w1.up and 02-w2.up cause each of the nodes to commit their configuration to
disk.  They reboot and come back up configured as they were hand configured before after
the reboot.

03-bootstrap.sh sets the client config context, starts the cluster and then creates the
kubeconfig client that can be used as your ~/.kube/config for kubectl.

This just worked seamlessly.  I have not yet dug into the details of the cluster and I
can see now if I had taken the time to read through the getting started materials.  The
bottom line is that Linux KVM virtual machines will work under pretty normal VM
configuration options.  I used getoo as a template becasue that seemed to me to best
represent "I have no idea" at the time.  It uses a Q35 chipset emulation and BIOS
(instead of UEFI) ro boot.  It also uses the standard host-passthrough CPU options.

It is certainly possible that down the road I might want to tweak these VMs depending
on workloads, migration needs, etc.  That could include changes to the VCPUs and
memory settings as well as changes to the physical networking (curently just a bridge
to a local LAN) or storage allocation.  Since most KVM based configurations (at least
in my experience) filter through libvirt, whether using vagrant, virt-manager or
whatever, it seems like TAlos Linux should just work.  Maybe there are some particular
corner cases where you might need to do some special tweaking, but from this I would
guess that one might consider the KVM install just like the vagrant / libvirt install,
but using another tool like virt-manager to create the VMs.

Based on what I see in some of the other installation guides, a predictable command
line option is preferred to a more ambiguous and error-prone process of walking through
a VM setup GUI, so I can see why virt-manager might be avoided here.  Also, unfortunately
there are details to the XML file defining your VM that need to change from one Linux
distribution to another, making something like virt-manager a good starting place if
you are not intimately familiar with your libvirt level configuration.  For example,
moving VMs from RedHat to Ubuntu in the past was more trouble than just the dumpxml,
copy and define process.  Your milage will probably vary if you use my XML file unless
you are running on OpenSUSE LEAP 15.

