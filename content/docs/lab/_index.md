---
title: Lab
bookFlatSection: true
weight: 10
---

# Lab

{{< hint info >}}
**TODO**
Add link to vagrant install and usage docs.
{{< /hint >}}

Included with this set of learning is a lab environment using vagrant and packer.

# Starting the lab

Starting the lab takes one command.

```sh
$ vagrant up
```

Not all of the lab needs to be started at the same time.

```sh
$ vagrant up dc1
```

# Stopping the lab

Some or all machines can be stopped the same way
```sh
$ vagrant halt [name]
```

# Cleaning up

Use the following command to unregister the VMs from your system and free up some disk space.

```sh
$ vagrant destroy
```

