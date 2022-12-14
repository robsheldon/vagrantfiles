# Vagrantfiles for desktop applications

This is a collection of Vagrantfiles and shell scripts I'm using to experiment with running all of my desktop applications in virtualbox VMs.

The Vagrantfiles are structured in hierarchical directories: `[OS]/[Release]/[Environment]/[Application]`. The Vagrantfiles include some provisioning logic that makes it easy to manage this setup for multiple applications.

My goal is to eventually run *all* of my desktop applications in individual VMs.

## But why?

I want to decouple my applications from my operating system. I want to be able to reliably "black start" my entire development environment -- to go from an empty hard drive to a fully functional desktop environment, with all my data restored, with only a little effort. I want to wrest control back from applications with ravenous appetites for resources -- I want to be able to choose exactly how much CPU, RAM, and disk each one gets. I want better security from suspect applications that are a regrettable professional necessity (like Zoom). I want to run the best applications each operating system has to offer all on one platform. I like the idea of Qubes but I want the convenience and hardware support of a mainstream Linux distribution on my laptop.

Those were all motivations that drove me to think about this for a while, but this is gradually also becoming an experiment in minimal desktop Linux and an opportunity to learn Vagrant (and then explore its boundaries a bit).

So far the experiment is going well! These VMs are being hosted on an early 2019 model LG Gram 17Z990, so newer and more powerful hardware shouldn't have any trouble with them.

I'm making these freely available (MIT-licensed) in part because this will force me to have a hard separation between my personal data and the applications that manage it.

Feel free to open an Issue with a suggestion or a bug report or even make a pull request with some environments and applications of your own.
