.. include:: <s5defs.txt>

=======
systemd
=======

:Author: Aaron Toponce
:Email: aaron.toponce@gmail.com
:Date: Jul 14, 2016

License
=======

This presentation is licensed under the Creative Commons Attribution-ShareAlike
license.

See http://creativecommons.org/licenses/by-sa/4.0/ for more details.

.. container:: handout
    
    This document is licensed under the CC:BY:SA
    Details to the license can be found here:
    http://creativecommons.org/licenses/by-sa/3.0/

    The licnese states the following:
     * You are free to copy, distribute and tranmit this work.
     * You are free to adapt the work.
    Under the following conditions:
     * You must attribute the work to the copyright holder.
     * If you alter, transform, or build on this work, you may redistribute the
       work under the same, similar or compatible license.
    With the understanding that:
     * Any conditions may be waived if you get written permission from the
       copyright holder.
     * In no way are any of the following rights affected by the license:
     
         * Your fair dealing or fair use rights;
         * The author's moral rights;
         * Rights other persons may have either in the work itself or
           in how the work is used, such as publicity or privacy rights.
           
     * For any reuse or distribution, you must make clear to others the license
       terms of this work. The best way to do this is with a link to the web
       page provided above or below.

    The above is a human-readable summary of the license, and is not to be used
    as a legal substitute for the actual licnse. Please refer to the formal
    legal document provided here:
    http://creativecommons.org/licenses/by-sa/3.0/legalcode

Introduction
============

* What is systmed?
* systemd features

What this presentation is not
=============================

* Not going to "sell" systemd.
* Not going to "bash" systemd.

What this presentation is
=========================

* An introduction.
* An explanation of features.
* A comparison to other init systems.

What is systemd?
================

* PID 1.
* Literally replaces /sbin/init.
* Designed by Lennart Poettering and Kay Sievers in 2010.
* Supervises all processes (it's the parent).
* Manages all services and resources.
* Alternative to SysV Init, Upstart, rc, etc.

systemd adoption
================

* Default in Fedora in 2011.
* Default in Debian, Arch, CentOS, RHEL, CoreOS, openSUSE, SLES, and Ubuntu.
* Not default in Gentoo, Slackware.

systemd myths (page 1)
======================

* http://0pointer.de/blog/projects/the-biggest-myths.html
* monolithic
* about speed
* systmed's fast bootup is irrelevant for servers
* incompatible with shell scripts
* difficult
* not modular
* only for desktops

systemd myths (page 2)
======================

* a result of the NIH syndrome
* not UNIX
* complex
* bloated
* Linux-only (not BSD-friendly)
* kernel-agnostic
* binary configuration files
* feature creep

systemd myths (page 2)
======================

* forces you to do something
* impossible to run syslog
* incompatible with SysV init
* not scriptable
* unstable and buggy
* not debuggable
* Red Hat-only
* doesn't support the /usr split from /
* doesn't allow you to replace components

What does systemd offer?
========================

* Simple dependency control (no SXX + KYY = 100)
* Service activation
* Improved logging, debugging, and profiling
* Faster startup and shutdown
* Tracking and restarting of services
* Improved resource management

systemd architecture
====================

.. image:: images/systemd_components.png

systemd units
=============

* Automount- File system automount point
* Device- Kernel device file
* Mounts- File system mount point
* Paths- systemd path-based activation
* Scope- An externally created process
* Services- Standard system service

system units cont.
==================

* Slice- A group of hierarchically organized units
* Snapshots- Saved state of the system manager
* Sockets- IPC, network socket, or a FIFO file
* Swap- Swap device or file for memory paging
* Targets- Group of system units
* Timers- systemd timer-based activation

systemd units (cont.)
=====================

* Units are defined with unit files
* Named "name.unit_type"
* The "name" is arbitrary

Unit file dependencies
======================

* Example: zfs-mount.service

.. code::

    Requires=systemd-udev-settle.service
    After=systemd-udev-settle.service
    After=zfs-import-cache.service
    After=zfs-import-scan.service
    Before=local-fs.target

* No more 00-99 ASCII order loading with K and S scripts
* Should be K+S=100, but rarely adhered to

Common Unit file options
========================

* Description=Unit Description
* Documentation=Link to additional docs
* Wants=weaker requirements
* Conflicts=Units cannot coexist
* After=Unit must start after
* Before=Unit must start before
* Requires=Additional units required
* ExecStart=Execute this for starting
* ExecStop=Execute this for stopping

Service Activation
==================

* Start services when needed
* Activated by Socket, Device, Path, Bus, and Timer
* Save resources
* Increased reliabality
* Transparent to the client

Parallel activation
===================

* Faster startup and shutdown
* Five 9's is 5.26 minutes per year
* Capacity on demand (spawning networks)

Improved resource management
============================

* Services labeled and isolated with Cgroups
* More granulated control than with nice/renice
* Balance by shares or with hard limits
* Configure multiple instances of a single service

systemd and cgroups
===================

.. image:: images/cgroups_and_systemd.png

Kernelspace service management
==============================

* All services tracked by the kernel now
* Kernel knows every child, grandchild, etc.
* Proper reaping of defunct/zombie processes

Autorestarting
==============

* Services DO crash
* systemd can restart the service automatically
* Socket stays open (minimize data loss)

Improved logging
================

* Does not need to rely on syslog (an extra service to start)
* More detail than classic syslog
* Completely optional- can rely on syslog (default)
* Improved debugging and profiling

Targets vs Runlevels
====================

.. table:: systemd targets

    ======== ================== ==============
    Runlevel Target             Symlink Target
    ======== ================== ==============
    0        poweroff.target    runlevel0.target
    1        rescue.target      runlevel1.target
    2        multi-user.target  runlevel2.target
    3        multi-user.target  runlevel3.target
    4        multi-user.target  runlevel4.target
    5        graphical.target   runlevel5.target
    6        reboot.target      runlevel6.target
    ======== ================== ==============

Target Administration
=====================

.. code::

    # systemctl get-default
    multi-user.target
    # systemctl set-default graphical.target
    rm '/etc/systemd/system/default.targot
    ln -s '/usr/lib/systemd/system/graphical.target \
    /etc/systemd/system/graphical.target'
    # systemctl isolate graphical.target

Target Administration cont.
===========================

.. code::

    # systemctl list-units --type target
    UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
    basic.target           loaded active active Basic System
    cryptsetup.target      loaded active active Encrypted Volumes
    getty.target           loaded active active Login Prompts
    graphical.target       loaded active active Graphical Interface
    local-fs-pre.target    loaded active active Local File Systems (Pre)
    local-fs.target        loaded active active Local File Systems

Halting
=======

.. code::

    # file /sbin/reboot 
    /sbin/reboot: symbolic link to /bin/systemctl

.. table:: Halting commands

    =========== ================== =====================
    Old command New command        Description
    =========== ================== =====================
    halt        systemctl halt     Halts the system
    poweroff    systemctl poweroff Powers off the system
    reboot      systemctl reboot   Reboots the system
    =========== ================== =====================

File Locations
==============

* In order of preference:

  - Local: ``/etc/systemd/system/``
  - Run-time: ``/run/systemd/system/``
  - Packages: ``/usr/lib/systemd/system/``

Example: RTL-SDR TRNG
=====================

.. code::

    [Unit]
    Description=RTL-SDR Hardware Random Number Generator
    Documentation=https://github.com/pwarren/rtl-entropy/

    [Service]
    ExecStart=/usr/local/bin/rtl_entropy -b -f 74M -e
    ExecStop=/usr/bin/pkill rtl_entropy
    ExecStopPost=/bin/rm -f /run/rtl_entropy.fifo /run/rtl_entropy.pid
    PIDFile=/run/rtl_entropy.pid

    [Install]
    WantedBy=multi-user.target

Installing the RTL-SDR TRNG Service
===================================

.. code::

    # vim /etc/systemd/systemd/rtl-entropy.service
    # systemctl daemon-reload
    # systemctl start rtl-entropy.service
    # systemctl status rtl-entropy.service

Start, Stop, Restart a Service
==============================

.. code::

    # systemctl stop rtl-entropy.service
    # systemctl start rtl-entropy.service
    # systemctl restart rtl-entropy.service

RTL-SDR TRNG Service
====================

.. image:: images/rtl-entropy.png


