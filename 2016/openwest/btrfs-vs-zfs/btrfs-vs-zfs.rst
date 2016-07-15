.. include:: <s5defs.txt>

============
Btrfs vs ZFS
============

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

* Overview of Btrfs and ZFS
* Common features
* Distinct features
* Common command examples

Overview
========

* Btrfs

  - Designed by Oracle
  - Marked stable in mainline in 2014
  - Actively developed

* ZFS

  - Designed by Sun Microsystems
  - Now owned by Oracle
  - Initially CDDL (GPL incompatible)
  - Now proprietary

OpenZFS fork
============

* 2008: ZFS version 5, Zpool version 28
* 2008: LLNL porting ZFS to native Linux kernel module
* 2008: FreeBSD active development
* 2009: Oracle acquires Sun Microsystems
* 2010: OpenSolaris discontinued
* 2010: Illumos continued as the OpenSolaris successor
* 2013: OpenZFS project begins

OpenZFS contributors
====================

* Delphix
* Illumos
* Joyent
* Intel
* FreeBSD
* LLNL (ZFS on Linux)
* OpenZFS on OS X

Shared Features
===============

* Copy-on-write
* Volume & RAID management
* Snapshots
* Sending and receiving filesystems
* Transparent compression
* Online scrubbing
* File integrity through checksums
* Data deduplication
* TRIM support for SSDs (currently just FreeBSD)
* Encryption coming (maybe)???

ZFS Distinct Features
=====================

* ZFS

  - ARC is an advanced cache different from LRU/MRU
  - L2ARC as a hot read cache or ghosted ARC pages
  - ZIL can be on a fast SSD (SLOG)
  - Checksum is Fletcher-4, SHA-256, or Edon-R (ugh)
  - Compression is zle, zlib, lzjb, or lz4
  - RAIDZ-1/2/3
  - Slab allocator
  - Integrated NFS/CIFS/iSCSI exports
  - Automatic checksum healing

Btrfs Distinct Features
=======================

* Btrfs

  - Cache is LRU/MRU (FIFO)
  - Bcache requires preformatting logical disk
  - Checksum is CRC32c (256-bit, hardware support)
  - Compression is zlib or lzo
  - Standard RAID-5/6 (no triple distributed parity)
  - Generic B-tree allocator
  - Rebalancing data
  - ``cp --reflink``

Missing Btrfs Features
======================

* Fast offline filesystem check
* Online filesystem check
* Object-level mirroring and striping
* Alternative checksum algorithms
* In-band deduplication (happens during writes)
* Other compression methods (snappy, LZ4)
* Hot data tracking and moving to faster devices

ZFS Commands
============

* 3 commands, one of which you'll never use

  * ``zpool``- Configures storage pools
  * ``zfs``- Configures filesystems
  * ``zdb``- Display pool debugging and consistency information

Btrfs Commands
==============

* A few more commands than ZFS:

  * ``mkfs.btrfs``- Creating a Btrfs filesystem
  * ``btrfs``- The main Btrfs administration tool
  * ``btrfs-debug-tree``- Print out Btrfs metadata in text form
  * ``btrfs-image``- Create a zeroed image of the filesystem with metadata
  * ``mount -t btrfs``- Mount a Btrfs filesystem
  * Et cetera

Creating a mirrored pool
========================

* ZFS

.. code::

    # zpool create tank mirror sda sdb

* Btrfs

.. code::

    # mkfs.btrfs -L tank -d raid1 -m raid1 /dev/sda /dev/sdb
    # mkdir /tank
    # mount -t btrfs /dev/sda /tank

Importing a pool
================

* ZFS

.. code::

    # zpool import -a
    # zpool import tank

* Btrfs

.. code::

    # btrfs device scan
    # btrfs device scan /dev/sda

Returning the status of a pool
==============================

* ZFS

.. code::

    # zpool status
    # zpool status tank

* Btrfs

.. code::

    # btrfs filesystem show
    # btrfs filesystem show /dev/sda

Creating subvolumes
===================

* ZFS

.. code::

    # zfs create tank/videos

* Btrfs

.. code::

    # btrfs subvolume create /tank/videos
    # mount -t btrfs -o subvol=videos /dev/sda /tank/videos

Returning the status of a subvolume
===================================

* ZFS

.. code::

    # zfs list
    # zfs list tank/videos

* Btrfs

.. code::

    # btrfs subvolume show /tank/videos

Creating snapshots
==================

* ZFS

.. code::

    # zfs snapshot tank/videos@snap_001

* Btrfs

.. code::

    # btrfs subvolume snapshot /tank/videos /tank/videos/snap_001

OR

.. code::

    # cp --reflink /tank/videos/file.mp4 /tank/videos/snapshot_file.mp4

Sending snapshots
=================

* ZFS

.. code::

    # zfs send tank/videos@snap_001

* Btrfs

.. code::

    # btrfs send /tank/videos/snap_001

Receiving snapshots
===================

* ZFS

.. code::

    # zfs recv tank/videos

* Btrfs

.. code::

    # btrfs receive /tank/videos

Enable compression
==================

* ZFS

.. code::

    # zfs get compression tank/videos
    # zfs set compression=(off|on|lzjb|lz4|gzip|gzip-N|zle)

* Btrfs

.. code::

    # mount -t btrfs -o compress=(no|lzo|zlib) /dev/sda /tank

Online scrubbing
================

* ZFS

.. code::

    # zfs scrub tank/videos

* Btrfs

.. code::

    # btrfs scrub /dev/sda

Recommendation
==============

* Test and benchmark both
* ZFS is good as a short term stop-gap
* ZFS is in Arch AUR, Debian and Ubuntu repos
* Btrfs will be the long-term storage for Linux
* Btrfs is largely feature-complete

Fin
===

* Comments, questions, rude remarks
