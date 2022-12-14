# Vagrantfiles for desktop applications

This is a collection of Vagrantfiles and shell scripts I'm using to experiment with running all of my desktop applications in virtualbox VMs.

The Vagrantfiles are structured in hierarchical directories: `[OS]/[Release]/[Environment]/[Application]`. The Vagrantfiles include some provisioning logic that makes it easy to manage this setup for multiple applications.


## Support for defaults in your home directory

Each Vagrantfile gets a unique `$vm_id`, and then the Vagrantfile looks for a file at `~/.config/vagrant/defaults.rb`. If one is found there, it is loaded.

You can use the defaults file along with `$vm_id` to load VM-specific defaults and behavior without modifying their Vagrantfiles. An example `~/config/vagrant/defaults.rb`:

```ruby
if $vm_id == 'debian-bullseye-openbox-firefox'
    Vagrant.configure("2") do |config|
        config.vm.provider "virtualbox" do |vb|
            vb.customize ['sharedfolder', 'add', :id, '--name', 'Downloads', '--hostpath', File.join(Dir.home, 'Downloads'), '--automount', '--auto-mount-point', '/home/vagrant/Downloads']
        end
    end
end
```

This would add your local Downloads folder to the Firefox VM at `~/Downloads` and automatically mount it. (The above is for example purposes, a future version of my Firefox Vagrantfile will have this built-in.)


## Personal Notes

My goal is to eventually run *all* of my desktop applications in individual VMs.

### But why?

I want to decouple my applications from my operating system. I want to be able to reliably "black start" my entire development environment -- to go from an empty hard drive to a fully functional desktop environment, with all my data restored, with only a little effort. I want to wrest control back from applications with ravenous appetites for resources -- I want to be able to choose exactly how much CPU, RAM, and disk each one gets. I want better security from suspect applications that are a regrettable professional necessity (like Zoom). I want to run the best applications each operating system has to offer all on one platform. I like the idea of Qubes but I want the convenience and hardware support of a mainstream Linux distribution on my laptop.

Those were all motivations that drove me to think about this for a while, but this is gradually also becoming an experiment in minimal desktop Linux and an opportunity to learn Vagrant (and then explore its boundaries a bit).

So far the experiment is going well! These VMs are being hosted on an early 2019 model LG Gram 17Z990, so newer and more powerful hardware shouldn't have any trouble with them.

I'm making these freely available (MIT-licensed) in part because this will force me to have a hard separation between my personal data and the applications that manage it.

Feel free to open an Issue with a suggestion or a bug report or even make a pull request with some environments and applications of your own.


## TODO

* Detect vagrant versions > 2.2.10 with VirtualBox and automatically use VDI instead of VMDK to get trim support (see also https://github.com/hashicorp/vagrant/issues/10677 and https://developer.hashicorp.com/vagrant/docs/v2.2.10/disks/usage). There is kind of a hacky way to do this before 2.2.10 (https://crysol.org/recipe/2015-11-17/vagrant-vdi-virtual-disk-for-virtualbox.html), but it requires hardcoding the disk image path and I've decided I don't want to do that.