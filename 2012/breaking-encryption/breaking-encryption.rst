.. include:: <s5defs.txt>

===================
Breaking Encryption
===================

:Author: Aaron Toponce
:Email: aaron.toponce@gmail.com
:Date: 2012-05-05

License
=======

This presentation is licensed under the Creative Commons
Attribution-ShareAlike License.

See http://creativecommons.org/licenses/by-sa/3.0/ for more details.

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

Title Clarification
===================

.. class:: slides

* Talk should really be titled "How Encryption Breaks When You Don't Implement It Correctly"
* Targeted towards filesystems


Introduction
============

.. class:: slides

* Leaking Encrypted Information
* Information- Data Containing A Message
* Non-Information- Zero Information or Random Data/Garbage

.. container:: handout

    If you come across what appears to be encrypted data, how can you know
    for sure? Is there anything in the data that can leak information about
    how it was built or what it contains? What if you stumbled across what
    appears to be random data? Are there any tools to determine if the data
    is really encrypted data?

    To answer these questions, we need to setup some definitions. First,
    we'll define "information" as "data containing a message". This message
    has some sort of value. Take the letters "g", "n" followed by "u".
    Together, they spell "gnu", which should bring up images of African
    Wildebeast, or Richard Stallman. The order of the letters is important.
    They have meaning. They have value.

    Next, we'll define "non-information" as "zero information" or "random
    data". This "non-information" does not contain a message. There is
    nothing of value in the message. Nothing can be determined from its
    arrangements of characters.

Encrypted vs Random Data
========================

.. class:: slides
.. class:: incremental

* ``e600cb38cb2196c54be018f2de43d43f``
* ``7b4244d2e99f9e4997820bf4ac51c00d``
* ``echo "UTOS" | aespipe | xxd -ps``
* ``dd if=/dev/urandom bs=1 count=16 | xxd -ps``

.. container:: handout

    Given the following two strings of data, can you tell which is
    encrypted and which is random? Is there any way to leak any sort of
    information out of the strings to determine which is which?

        ``e600cb38cb2196c54be018f2de43d43f``
        ``7b4244d2e99f9e4997820bf4ac51c00d``

    The first was generated with:

        ``echo "UTOS" | aespipe | xxd -ps``

    with the password '12345678901234567890', and the second string was
    generated with:

        ``dd if=/dev/urandom bs=1 count=16 | xxd -ps``

    So, in reality, both of them are "encrypted", as the latter was
    generated using the Linux kernel pseudorandom number generator (PRNG),
    which uses mathematical equations to generate cryptographically secure
    data.

A Few Points
============

.. class:: slides

1. Knowing the cipher doesn't necessarily give you an advantage.
2. The cipher can be announced in the header (EG: LUKS).
3. Plausible deniability could be lost.

.. class:: handout

    A few points need to be addressed before moving on:

    1) An attacker who knows what encryption cipher was used on the message
    doesn't necessarily give him any advantage on breaking the message.
    While there may be weaknesses in some ciphers, most "cryptographically
    strong" ciphers have stood the test of time, and show few weaknesses.
    It's knowing the secret key that gives you ultimate access.

    2) As a result of #1, many utilities, such as LUKS, announce the cipher
    in some sort of header. This makes it easy for other utilities to take
    advantage of the cipher, and encrypt/decrypt data.

    3) As a result of #2, because a header exists that announces that the
    following data is actually encrypted, and how it was encrypted,
    plausible deniability is lost. Should the secret police want to
    investigate your hard drive, and discover that it is LUKS formatted,
    you cannot deny that you are encrypting data.

    So, rather than using the LUKS extensions, it would be preferrable to
    use loop-aes or dm-crypt, as no header is stored on disk. However, this
    makes it less convenient, as many tools will not know how to interact
    with the data. For example, the LUKS header can tell your operating
    system to prompt the user for the encrypted password when a USB drive
    is plugged in.

Bitmap Cryptanalysis
====================

.. class:: slides

* Composition through subtraction
* Take advantage of the bitmap header
* ``composite -compose difference img1.bmp img2.bmp diff.bmp``

.. class:: handout

    To help you understand many of these points, we will be using bitmaps
    for visualization. We will also be taking advantage of the bitmap
    header to create bitmaps out of binary files. We will be using
    ImageMagick to manipulate the images:

        ``$ composite -compose difference img1.bmp img2.bmp diff.bmp``

Image Composition
=================

.. class:: slides

+-----------------------------+---------------------------+---------------------------------+
| .. image:: pics/android.gif | .. image:: pics/blank.gif | .. image:: pics/android-neg.gif |
|    :align: center           |    :align: center         |    :align: center               |
+-----------------------------+---------------------------+---------------------------------+
| android.bmp                 | blank.bmp                 | android-neg.bmp                 |
+-----------------------------+---------------------------+---------------------------------+

* ``composite -compose difference android.bmp blank.bmp android-neg.bmp``

.. class:: handout

    This was done using the following command:

        ``$ composite -compose difference android.bmp blank.bmp android-neg.bmp``

Random Composition Code
=======================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=random1.bmp bs=1 count=120054``
* ``dd if=/dev/urandom of=random2.bmp bs=1 count=120054``
* ``dd if=blank.bmp of=random1.bmp bs=1 count=54 conv=notrunc``
* ``dd if=blank.bmp of=random2.bmp bs=1 count=54 conv=notrunc``
* ``composite -compose difference random1.bmp random2.bmp random-neg.bmp``

Random Composition Images
=========================

.. class:: slides

+------------------------------+-----------------------------+---------------------------------+
| .. image:: pics/random1.gif  | .. image:: pics/random2.gif | .. image:: pics/random-neg.gif  |
|    :align: center            |    :align: center           |    :align: center               |
+------------------------------+-----------------------------+---------------------------------+
| random1.bmp                  | random2.bmp                 | random-neg.bmp                  |
+------------------------------+-----------------------------+---------------------------------+

.. class:: handout

    This should come as no surprise. Subtracting random data from random
    data should yield random data.

Roadmap
=======

.. class:: slides

* Use bitmap composition
* Sart with worst case implementation
* End with best case implementation
* Images are not rigorous, but helpful

.. class:: handout

    Our plan for this presentation is to use bitmap difference composition
    throughout to help visualize what is going on. While using bitmaps is
    certainly not rigorous, it will give us a good idea as to what is going
    on. So, we'll start with the worst case implementation, and show how it
    falls apart, and work our way towards the best case implementation.

Electronic Codeblock (ECB)
===========================

.. class:: slides

* Simplest encryption mode
* Message is divided into blocks
* Each block encrypted separately
* Identical plaintext blocks are encrypted into identical ciphertext blocks
* Structure is not hidden well

.. class:: handout

    Electronic Codeblock, or ECB for short, is the simplest encryption mode
    for encrypting blocks. It divides the message into smaller blocks,
    usually 128- or 256-bits, then encrypts each bit using the provided key.
    Because the encryption algorithm is the same for each block, each
    identical plaintext block will be encrypted to identical ciphertext
    blocks. As a result, structured data such as images, videos and music is
    not hidden well.

    Because each block is not dependent on the other, ECB can be highly
    parallelized, which results in substantial speed encrypting and
    decrypting the blocks.

Cipher-block Chaining (CBC)
===========================

.. class:: slides

* Initialization Vector used
* Message is divided into blocks
* Each plaintext block XORed with the previous ciphertext block
* Result encrypted

.. class:: handout

    Cipher-block Chaining, or CBC for short, requires need of an
    Initialization Vector (IV). This IV "kickstarts" the encryption process
    by XORing itself with the plaintext before encrypting each block. The
    resulting string is encrypted, and the ciphertext is saved to disk. It
    is also memory copied, and is XORed with the next plaintext block before
    encryption. This process continues for every block in the plaintext. As
    a result, identical plaintext blocks each receive a different ciphertext
    block. Thus, structure is not preserved, and the resulting message
    appears to be random.

    The IV is stored on disk, or in the encrypted message, to which the key
    provides access to. So decryption happens in reverse. The IV is
    decrypted with your key, the ciphertext is decrypted with the algorithm,
    and the result is XORed with the IV to produce the plaintext.

    Unfortunately, because of the chain, CBC cannot be parallelized. Due to
    the extra XOR operations as well, it is slower than non-parallelized
    ECB.

ECB Image
=========

.. class:: slides
.. class:: tiny simple

* ``openssl enc -aes-128-ecb -in android.bmp -out android-ecb.bmp``
* ``dd if=blank.bmp of=android-ecb.bmp bs=1 count=54 conv=notrunc``

CBC Image
=========

.. class:: slides
.. class:: tiny simple

* ``openssl enc -aes-128-cbc -in android.bmp -out android-cbc.bmp``
* ``dd if=blank.bmp of=android-cbc.bmp bs=1 count=54 conv=notrunc``

Plaintext vs ECB vs CBC
=======================

.. class:: slides

+-----------------------------+---------------------------------+---------------------------------+
| .. image:: pics/android.gif | .. image:: pics/android-ecb.gif | .. image:: pics/android-cbc.gif |
|    :align: center           |    :align: center               |    :align: center               |
+-----------------------------+---------------------------------+---------------------------------+
| Plaintext                   | ECB Encrypted                   | CBC Encrypted                   |
+-----------------------------+---------------------------------+---------------------------------+

`A better example at Wikipedia
<http://en.wikipedia.org/wiki/Block_cipher_modes_of_operation#Electronic_codebook_.28ECB.29>`_.

.. class:: handout

    As you can clearly see with the ECB image, the structure of the Android
    logo is preserved, and is clearly visible. However, the CBC image
    appears to be completely random data, despite the fact that it is indeed
    an encrypted Android logo. CBC is not the only encryption mode that
    chains plaintext with ciphertext, but it is one of the more popular
    ones.

Filesystem Bitmaps
==================

.. class:: slides

* Plaintext vs ECB vs CBC filesystems
* Pseudorandom layer first
* Illustrated with the following images
* Goal: appear as a random bitmap

Source and Goal
===============

.. class:: slides

+-----------------------+----------------------------+
| .. image:: pics/0.gif | .. image:: pics/random.gif |
|    :align: center     |    :align: center          |
+-----------------------+----------------------------+
| 0.bmp                 | random.bmp                 |
+-----------------------+----------------------------+

.. class:: handout

    Many blogs and forums will instruct the user to put a pseudorandom layer
    of data down on the hard drive first, before encrypting and formatting
    with your filesystem, but few explain why. Hopefully, we'll illustrate
    that clearly with bitmaps.

Plaintext Filesystem
====================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/zero of=ext2-0.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-0.bmp``
* ``mkfs.ext2 /dev/loop0``
* ``mount /dev/loop0 /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-0.bmp bs=1 count=54 conv=notrunc``

ECB Filesystem
==============

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/zero of=ext2-ecb-0.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-ecb-0.bmp``
* ``cryptsetup -c aes-ecb create crypt-disk /dev/loop0``
* ``mkfs.ext2 /dev/mapper/crypt-disk``
* ``mount /dev/mapper/crypt-disk /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``cryptsetup remove crypt-disk``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-ecb-0.bmp bs=1 count=54 conv=notrunc``

CBC Filesystem
==============

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/zero of=ext2-cbc-0.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-cbc-0.bmp``
* ``cryptsetup -c aes-cbc create crypt-disk /dev/loop0``
* ``mkfs.ext2 /dev/mapper/crypt-disk``
* ``mount /dev/mapper/crypt-disk /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``cryptsetup remove crypt-disk``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-cbc-0.bmp bs=1 count=54 conv=notrunc``

No Pseudorandom Data
====================

.. class:: slides

+----------------------------+--------------------------------+--------------------------------+
| .. image:: pics/ext2-0.gif | .. image:: pics/ext2-ecb-0.gif | .. image:: pics/ext2-cbc-0.gif |
|    :align: center          |    :align: center              |    :align: center              |
+----------------------------+--------------------------------+--------------------------------+
| Plaintext Filesystem       | ECB Filesystem                 | CBC Filesystem                 |
+----------------------------+--------------------------------+--------------------------------+

.. class:: handout

    It becomes clear that when you don't put random data down on the disk
    before your encrypt the filesystem, you cean clearly see where the
    encrypted data lies, and where it doesn't. As an attacker, where am I
    going to put my focus?

Plaintext Filesystem
====================

.. class:: slides
.. class:: tiny simple


* ``dd if=/dev/urandom of=ext2-r.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-r.bmp``
* ``mkfs.ext2 /dev/loop0``
* ``mount /dev/loop0 /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-r.bmp bs=1 count=54 conv=notrunc``

ECB Filesystem
==============

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=ext2-ecb-r.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-ecb-r.bmp``
* ``cryptsetup -c aes-ecb create crypt-disk /dev/loop0``
* ``mkfs.ext2 /dev/mapper/crypt-disk``
* ``mount /dev/mapper/crypt-disk /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``cryptsetup remove crypt-disk``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-ecb-r.bmp bs=1 count=54 conv=notrunc``

CBC Filesystem
==============

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=ext2-cbc-r.bmp bs=1 count=480054``
* ``losetup /dev/loop0 ext2-cbc-r.bmp``
* ``cryptsetup -c aes-cbc create cbc-disk /dev/loop0``
* ``mkfs.ext2 /dev/mapper/cbc-disk``
* ``mount /dev/mapper/cbc-disk /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``dmsetup remove ext2-cbc-r.bmp``
* ``losetup -d /dev/loop0``
* ``dd if=0-400x400.bmp of=ext2-cbc-r.bmp bs=1 count=54 conv=notrunc``

Pseudorandom Data
=================

.. class:: slides

+----------------------------+--------------------------------+--------------------------------+
| .. image:: pics/ext2-r.gif | .. image:: pics/ext2-ecb-r.gif | .. image:: pics/ext2-cbc-r.gif |
|    :align: center          |    :align: center              |    :align: center              |
+----------------------------+--------------------------------+--------------------------------+
| Plaintext Filesystem       | ECB Filesystem                 | CBC Filesystem                 |
+----------------------------+--------------------------------+--------------------------------+

.. class:: handout

    At this point, it should be clear that putting a pseudorandom data layer
    down on the disk first, before encrypting, makes it difficult for an
    attacker to identify where the pseudorandom data ends and the encrypted
    filesystem begins, when using CBC mode.

Information Leak
================

.. class:: slides

* We have not met our goal.
* Introducing the Snapshot Attack
* CBC information leak

    1. Single key simple IV mode
    2. Multi-key-v3 mode
    3. 128-bit aes-cbc-essiv:sha256

.. class:: handout

    Despite our dest efforts of using CBC and encrypting our data, we will
    still suffer from information leak through what is called the "snapshot
    attack". This attack assumes that an attacker has physical access to
    your disk, and makes daily images of it. Through difference composition,
    we can remove similar bits betwen snapshots to reveal where the
    encrypted data is lying, and maybe even discover some data that it is
    designed to protect.

    So, let's look at three cheap ways of getting the task done. First,
    we'll look at single key simple IV mode, which is basically a way of
    saying to just provide a password to kickstart the encryption. The
    second way is muilt-key-v3 mode, which is a way of saying to provide
    both a password and a physical key to start the encryption process.
    Lastly, we'll look at the default of LUKS, and see how it compares.

    All three of these modes will reveal information about the data it's
    designed to protect.

Single Key Simple IV
====================

.. class:: slides
.. class:: tiny simple

* ``aespipe < 0.bmp > aes0.bmp``
* ``aespipe < blank.bmp > aes-blank.bmp``
* ``dd if=0.bmp of=aes0.bmp bs=1 count=54 conv=notrunc``
* ``dd if=blank.bmp of=aes-blank.bmp bs=1 count=54 conv=notrunc``
* ``composite -compose difference aes0.bmp aes-blank.bmp aes-diff.bmp``

Single Key Bitmaps
==================

.. class:: slides

+--------------------------+-------------------------------+------------------------------+
| .. image:: pics/aes0.gif | .. image:: pics/aes-blank.gif | .. image:: pics/aes-diff.gif |
|    :align: center        |    :align: center             |    :align: center            |
|    :height: 400px        |    :height: 400px             |    :height: 400px            |
|    :width: 400px         |    :width: 400px              |    :width: 400px             |
+--------------------------+-------------------------------+------------------------------+
| aes0.bmp                 | aes-blank.bmp                 | aes-diff.bmp                 |
+--------------------------+-------------------------------+------------------------------+

.. class:: handout

    CBC has completely failed us. With our 'aes-diff.bmp' I can clearly see
    the underlying structure of the 0.bmp image. This is only because the
    password is the same between files. Our password becomes our
    Initialization Vector (IV). If the password was different, then we have
    success, but this isn't very likely, as for filesystems, you likely use
    the same password to unlock your hard drive.

Single Key Bitmap Comparison
============================

.. class:: slides

+--------------------------+-------------------------------+--------------------------------+
| .. image:: pics/0.gif    | .. image:: pics/aes-diff.gif  | .. image:: pics/random-400.gif |
|    :align: center        |    :align: center             |    :align: center              |
|    :height: 400px        |    :height: 400px             |    :height: 400px              |
|    :width: 400px         |    :width: 400px              |    :width: 400px               |
+--------------------------+-------------------------------+--------------------------------+
| 0.bmp                    | aes-diff.bmp                  | random.bmp                     |
+--------------------------+-------------------------------+--------------------------------+

.. class:: handout

    We want our goal to be random.bmp, but we're not quite there. We have
    more work to do.

Multi-key-v3 Mode
=================

.. class:: slides
.. class:: tiny simple

* ``head -c 2925 /dev/urandom | uuencode -m - | head -n 66 | tail -n 65 | gpg --symmetric -a > key.gpg``
* ``aespipe -K key.gpg < 0.bmp > aes0-v3.bmp``
* ``aespipe -K key.gpg < blank.bmp > aes-blank-v3.bmp``
* ``dd if=0.bmp of=aes0-v3.bmp count=54 bs=1 conv=notrunc``
* ``dd if=blank.bmp of=aes-blank-v3.bmp count=54 bs=1 conv=notrunc``
* ``composite -compose difference aes0-v3.bmp aes-blank-v3.bmp aes-diff-v3.bmp``

Multi Key Bitmaps
=================

.. class:: slides

+-----------------------------+----------------------------------+---------------------------------+
| .. image:: pics/aes0-v3.gif | .. image:: pics/aes-blank-v3.gif | .. image:: pics/aes-diff-v3.gif |
|    :align: center           |    :align: center                |    :align: center               |
|    :height: 400px           |    :height: 400px                |    :height: 400px               |
|    :width: 400px            |    :width: 400px                 |    :width: 400px                |
+-----------------------------+----------------------------------+---------------------------------+
| aes0-v3.bmp                 | aes-blank-v3.bmp                 | aes-diff-v3.bmp                 |
+-----------------------------+----------------------------------+---------------------------------+

.. class:: handout

    This looks substantially better than our single key mode, and this
    should probably be a best practice. That is, to provide both something
    that you have and something that you know. Unfortunately, the geometry
    of my zero is setting the boundaries of the encrypted bits. Even though
    the data being leaked isn't significant, and we should probably use
    multi-key mode whenever possible, we can still do better.

Multi Key Bitmap Comparison
===========================

.. class:: slides

+--------------------------+----------------------------------+--------------------------------+
| .. image:: pics/0.gif    | .. image:: pics/aes-diff-v3.gif  | .. image:: pics/random-400.gif |
|    :align: center        |    :align: center                |    :align: center              |
|    :height: 400px        |    :height: 400px                |    :height: 400px              |
|    :width: 400px         |    :width: 400px                 |    :width: 400px               |
+--------------------------+----------------------------------+--------------------------------+
| 0.bmp                    | aes-diff-v3.bmp                  | random.bmp                     |
+--------------------------+----------------------------------+--------------------------------+

.. class:: handout

    This better shows how the geometry of my 0.bmp is affecting the
    encryption boundaries of aes-diff-v3.bmp. We are getting closer to
    random.bmp, however.

128-bit aes-cbc-essiv:sha256
============================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=aes-cbc-0.bmp bs=1 count=1080054``
* ``losetup /dev/loop0 aes-cbc-0.bmp``
* ``cryptsetup luksFormat -s 128 --align-payload=8 /dev/loop0``
* ``cryptsetup luksOpen /dev/loop0 aes-crypt``
* ``mkfs.ext2 /dev/mapper/aes-crypt``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``cryptsetup luksClose /dev/mapper/aes-crypt``
* ``losetup -d /dev/loop0``

128-bit aes-cbc-essiv:sha256
============================

.. class:: slides
.. class:: tiny simple

* ``cp aes-cbc-0.bmp aes-cbc-blank.bmp``
* ``losetup /dev/loop0 aes-cbc-blank.bmp``
* ``cryptsetup luksOpen /dev/loop0 aes-crypt``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``cp blank.bmp /mnt/0.bmp``
* ``umount /mnt``
* ``cryptsetup luksClose /dev/mapper/aes-crypt``
* ``losetup -d /dev/loop0``
* ``dd if=0-600x600.bmp of=aes-cbc-0.bmp bs=1 count=54 conv=notrunc``
* ``dd if=0-600x600.bmp of=aes-cbc-blank.bmp bs=1 count=54 conv=notrunc``
* ``composite -compose difference aes-cbc-0.bmp aes-cbc-blank.bmp aes-cbc-diff.bmp``

.. class:: handout

    First, notice that we are now working on a full-blown filesystem, versus
    just encrypting files. The result will be a bit different as a result.

    Second, notice that I'm NOT reformating the disk with a new LUKS format.
    This is because your password encrypts the initialization vector at
    first setup, and it's that IV that is responsible for encrypting and
    decrypting the data on/off your disk. We need to imitate thata here. We
    do so by copying the filesystem to another file, then modifying that
    filesystem, just as we would if we were working on our computer.

128-bit aes-cbc-essiv Bitmaps
=============================

.. class:: slides

+-------------------------------+-----------------------------------+----------------------------------+
| .. image:: pics/aes-cbc-0.gif | .. image:: pics/aes-cbc-blank.gif | .. image:: pics/aes-cbc-diff.gif |
|    :align: center             |    :align: center                 |    :align: center                |
|    :height: 400px             |    :height: 400px                 |    :height: 400px                |
|    :width: 400px              |    :width: 400px                  |    :width: 400px                 |
+-------------------------------+-----------------------------------+----------------------------------+
| aes-cbc-0.bmp                 | aes-cbc-blank.bmp                 | aes-cbc-diff.bmp                 |
+-------------------------------+-----------------------------------+----------------------------------+

.. class:: handout

    This shouldn't be surprising, actually. Because we're not reformatting
    the disk between snapshots, nor changing our password, and reencrypting
    our disk as a result, all of the identical bits go away in the
    composition, and we can make out what LUKS is trying to hide.

    It would be nice if LUKS supported multi-key-v3, as we could get the
    increased benefits of actually hiding th edata, but unfortunately, and
    this time, it does not.

Best Practice
=============

.. class:: slides

* Encryption leaks data
* Recommendations for avoiding the snapshot attack

    * Filling the disk with data
    * Intentional fragmentation

.. class:: handout

    Because LUKS is the default encrypted container for most GNU/Linux
    installations, we'll stick with that for the rest of this document.
    Because LUKS also does not support multi-key-v3 mode, we will be stuck
    with single key, simple IV mode. However, this isn't necessarily a bad
    thing, and we can do some extra steps to hide the data rather
    effectively, thus creating a "best practice".

    First, will fill any remaining space with random data, day in and day
    out. Second, we could also intentionally fragment the disk, and see if
    that buys us any security with the filesystem snapshots.

Filling Motivation
==================

.. class:: slides

* Mount, remove waste file, work, add waste file
* Wash, rinse, repeat
* Snapshot attack less effective

.. class:: handout

    The motivation is simple. When you are finished working at your
    computer, you create a "waste" file that fills the disk with random
    data, then leave for the day. When you get back to work, you remove the
    waste file, so you have space on your hard drive, then work. As you are
    done for the day, again you create the waste file, and go home.

    Because we're creating a random waste file every day, then removing it
    every day, we're constantly flipping the bits on the hard drive. This
    will make the snapshot attack less effective, because composing a
    difference of two random bits results in random bits, as we already
    discovered. So, let's see what happens.

Filling The Disk
================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=aes-cbc-filled-0.bmp bs=1 count=1080054``
* ``losetup /dev/loop0 aes-cbc-filled-0.bmp``
* ``cryptsetup create aes-crypt /dev/loop0``
* ``mkfs.ext2 /dev/mapper/aes-crypt``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``cp 0.bmp /mnt``
* ``dd if=/dev/urandom of=/mnt/waste``
* ``umount /mnt``
* ``cryptsetup remove aes-crypt``
* ``losetup -d /dev/loop0``

Filling The Disk
================

.. class:: slides
.. class:: tiny simple

* ``cp aes-cbc-filled-0.bmp aes-cbc-filled-blank.bmp``
* ``losetup /dev/loop0 aes-cbc-filled-blank.bmp``
* ``cryptsetup create aes-crypt /dev/loop0``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``cp blank.bmp /mnt/0.bmp``
* ``rm /mnt/waste``
* ``dd if=/dev/urandom of=/mnt/waste``
* ``umount /mnt``
* ``cryptsetup remove aes-crypt``
* ``losetup -d /dev/loop0``
* ``dd if=0-600x600.bmp of=aes-cbc-filled-0.bmp bs=1 count=54 conv=notrunc``
* ``dd if=0-600x600.bmp of=aes-cbc-filled-blank.bmp bs=1 count=54 conv=notrunc``
* ``composite -compose difference aes-cbc-filled-0.bmp aes-cbc-filled-blank.bmp aes-cbc-filled-diff.bmp``

Disk Filling Bitmaps
====================

.. class:: slides

+--------------------------------------+------------------------------------------+-----------------------------------------+
| .. image:: pics/aes-cbc-filled-0.gif | .. image:: pics/aes-cbc-filled-blank.gif | .. image:: pics/aes-cbc-filled-diff.gif |
|    :align: center                    |     :align: center                       |     :align: center                      |
|    :height: 400px                    |     :height: 400px                       |     :height: 400px                      |
|    :width: 400px                     |     :width: 400px                        |     :width: 400px                       |
+--------------------------------------+------------------------------------------+-----------------------------------------+
| aes-cbc-filled-0.bmp                 | aes-cbc-filled-blank.bmp                 | aes-cbc-filled-diff.bmp                 |
+--------------------------------------+------------------------------------------+-----------------------------------------+

.. class:: handout

    Much better, although I can still make out my 0.bmp on the filesystem.
    We already know why this is showing up, as we saw this previously. So,
    what can we do to prevent this data leak?

Disk Filling Bitmap Comparison
==============================

.. class:: slides

+--------------------------+------------------------------------------+--------------------------------+
| .. image:: pics/0.gif    | .. image:: pics/aes-cbc-filled-diff.gif  | .. image:: pics/random-600.gif |
|    :align: center        |    :align: center                        |    :align: center              |
|    :height: 400px        |    :height: 400px                        |    :height: 400px              |
|    :width: 400px         |    :width: 400px                         |    :width: 400px               |
+--------------------------+------------------------------------------+--------------------------------+
| 0.bmp                    | aes-cbc-filled-diff.bmp                  | random.bmp                     |
+--------------------------+------------------------------------------+--------------------------------+

.. class:: handout

    We are gettintg much, much closer to our target, but we still have data
    leak that we need to address. Let's address that with fragmenting the
    filesystem.

Fragmenting Motivations
=======================

.. class:: slides

* SSDs, such as USB thumb drives, don't suffer
* What can we gain encryption-wise with fragmentation?

.. class:: handout

    Generally speaking, fragmentation is a bad thing, when your hard drive
    consists of moving parts that need to access the data, such as platter
    drives. But, with the growth of SSDs, USB thumb drives, SD cards, and
    other solid state media, fragmentation is less of an issue. We can
    intentionally fragment the filesystem, and see what gains we achieve
    with encryption.

Simple Fragmentation Example
============================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=ext2-frag.bmp bs=1 count=1080054``
* ``losetup /dev/loop0 ext2-frag.bmp``
* ``mkfs.ext2 -N 1024 /dev/loop0``
* ``mount /dev/loop0 /mnt``
* ``for i in {1..1024}; do dd if=/dev/zero of=/mnt/$i.waste bs=1k count=1; done``
* ``rm -f /mnt/*7.waste /mnt/?7?.waste``
* ``cp 0.bmp /mnt``
* ``umount /mnt``
* ``losetup -d /dev/loop0``
* ``dd if=0-600x600.bmp of=ext2-frag.bmp bs=1 count=54 conv=notrunc``

.. class:: handout

    Notice that I'm creating a filesystem with 1024 inodes. This is because
    the filesystem is only 1MB in size, and ext2 doesn't generate enough
    inodes by default. I need more if I'm going to intentionally fragment
    the filesystem. Because if I run out of inodes, I run out of the ability
    to create new files.

    I fragment the filesystem by creating 1024 files, then removing some of
    them. By doing so, I make just enough room to save my 0.bmp file, which
    will be fragmented when placed on disk. 

Fragmented Bitmap
=================

.. class:: slides

+-----------------------+-------------------------------+
| .. image:: pics/0.gif | .. image:: pics/ext2-frag.gif |
|    :height: 400px     |    :height: 400px             |
|    :width: 400px      |    :width: 400px              |
+-----------------------+-------------------------------+
| 0.bmp                 | ext2-frag.bmp                 |
+-----------------------+-------------------------------+

.. class:: handout

    As exected, my 0.bmp is highly fragmented. This is what we'll be after
    with encrypting the data.

Fragmenting The Disk
====================

.. class:: slides
.. class:: tiny simple

* ``dd if=/dev/urandom of=aes-cbc-frag-0.bmp bs=1 count=1080054``
* ``losetup /dev/loop0 aes-cbc-frag-0.bmp``
* ``cryptsetup create aes-crypt /dev/loop0``
* ``mkfs.ext2 -N 1024 /dev/mapper/aes-crypt``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``for i in {1..1024}; do dd if=/dev/urandom of=/mnt/$i.waste count=1 bs=1k; done``
* ``rm /mnt/*{4,7}.waste``
* ``cp 0.bmp /mnt``
* ``dd if=/dev/urandom of=/mnt/waste``
* ``umount /mnt``
* ``cryptsetup remove aes-crypt``
* ``losetup -d /dev/loop0``

.. class:: handout

    Notice that I'm also filling the disk with random data. This is because
    we already learned that this is a "best practice", so I might as well
    continue doing it. So, we are both fragmenting the filesystem, and
    filling it with random data.

Fragmenting The Disk
====================

.. class:: slides
.. class:: tiny simple

* ``cp aes-cbc-frag-0.bmp aes-cbc-frag-blank.bmp``
* ``losetup /dev/loop0 aes-cbc-frag-blank.bmp``
* ``cryptsetup create aes-crypt /dev/loop0``
* ``mount /dev/mapper/aes-crypt /mnt``
* ``for i in {1..1024}; do dd if=/dev/urandom of=/mnt/$i.waste count=1 bs=1k; done``
* ``cp blank.bmp /mnt/0.bmp``
* ``dd if=/dev/urandom of=/mnt/waste``
* ``umount /mnt``
* ``cryptsetup remove aes-crypt``
* ``losetup -d /dev/loop0``
* ``dd if=0-600x600.bmp of=aes-cbc-frag-0.bmp bs=1 count=54 conv=notrunc``
* ``dd if=0-600x600.bmp of=aes-cbc-frag-blank.bmp bs=1 count=54 conv=notrunc``
* ``composite -compose difference aes-cbc-frag-0.bmp aes-cbc-frag-blank.bmp aes-cbc-frag-diff.bmp``

.. class:: handout

    Notice that on this second filesystem, I am overwriting the fragmented
    bits. Remember in the snapshot attack, any similar data gets composed
    out. So, I need to change these bits. This could be an expensive
    operation, if your disk is large, and you have a lot of fragmented
    files. I am also overwriting the waste file, for the same reasons.

Fragmented Bitmaps
==================

.. class:: slides

+------------------------------------+----------------------------------------+---------------------------------------+
| .. image:: pics/aes-cbc-frag-0.gif | .. image:: pics/aes-cbc-frag-blank.gif | .. image:: pics/aes-cbc-frag-diff.gif |
|    :align: center                  |    :align: center                      |    :align: center                     |
|    :height: 400px                  |    :height: 400px                      |    :height: 400px                     |
|    :width: 400px                   |    :width: 400px                       |    :width: 400px                      |
+------------------------------------+----------------------------------------+---------------------------------------+
| aes-cbc-frag-0.bmp                 | aes-cbc-frag-blank.bmp                 | aes-cbc-frag-diff.bmp                 |
+------------------------------------+----------------------------------------+---------------------------------------+

.. class:: handout

    At this point, this is about as good as we can get with LUKS. It took a
    bit of work getting here, but it wasn't too bad. All we had to do was
    fragment the filesystem, and fill the remaining free space. If we keep
    on top of this on a daily basis, the snapshot attack becomes virtually
    ineffective.

Final Bitmap Comparison
=======================

.. class:: slides

+--------------------------+----------------------------------------+--------------------------------+
| .. image:: pics/0.gif    | .. image:: pics/aes-cbc-frag-diff.gif  | .. image:: pics/random-600.gif |
|    :align: center        |    :align: center                      |    :align: center              |
|    :height: 400px        |    :height: 400px                      |    :height: 400px              |
|    :width: 400px         |    :width: 400px                       |    :width: 400px               |
+--------------------------+----------------------------------------+--------------------------------+
| 0.bmp                    | aes-cbc-frag-diff.bmp                  | random.bmp                     |
+--------------------------+----------------------------------------+--------------------------------+

.. class:: handout

    The lines and strides you see in the fragmented filesystem are likely
    due to filesystem metadata, which there isn't much we can do about. This
    is fairly close to our result of random.bmp. If LUKS supported
    multi-key-v3, then we wouldn't need to do as much work, but until that
    fix is implemented, this is what we need to do to prevent this attack.

Some Considerations
===================

.. class:: slides

* RAID (Level 0 or Parity)
* LVM (physical extent distribution)
* COW such as ZFS or Btrfs
* Snapshots
* Compression
* Deduplication

.. class:: handout

    We've only been been discussing single use filesystems. There are other
    storage considerations that we need to take into account. Things such as
    RAID and the various levels. How would the snapshot attack look with
    striping, such as RAID0 or RAID10? How would the snapshot attack look
    with parity-based RAID5 or RAID6?

    Logical volume management can align blocks to physical extents, and you
    can decide where to place those physical extents. How would this look
    with the snapshot attack? What if LVM is combined with RAID?

    Copy-on-write filesystems, such as ZFS or Btrfs add a new dimension to
    storage with the copy-on-write approach to storing data. Combined with a
    great deal of metadata on the disk, such as Btrees or Merkle trees, how
    does this affect the snapshot attack?

    LVM or ZFS/Btrfs snapshots store the snapshot in metadata pointers, and
    as data changes, is copied to the new volume/filesystem. How would these
    sort of changes look?

    Compression is highly used in encryption to add entropy to the encrypted
    information. It is also used in modern filesystems to increase available
    storage. How would this thwart the snapshot attack? How would the images
    look?

    Deduplication could be per file, or per block. If per block, how would
    files that have been deduplicated look? If combined with compression,
    how would that affect the result?

    These questions haven't been investigated in this document, obviously,
    but might be worth the reader's time to do so. The tools and steps have
    already been discussed in this decument, so it should be fairly trivial
    to investigate these.

Conclusion
==========

.. class:: slides

* ECB vs CBC
* Random data filesystem prep
* King attack- the Snapshot Attack
* Daily Routine:

    0. Start with fragmentation
    1. Overwrite fragmented bits with random data
    2. Work
    3. Fill remaining space with random data
    4. Repeat steps 1-3 daily

Acknowledgement
===============

.. class:: slides

* Thanks to Dr. A. G. Basile at D'Youville college for his PDF
* http://opensource.dyc.edu/sites/default/files/random-vs-encrypted.pdf

Fin
===

.. class:: slides

* Questions, comments, rude remarks?
