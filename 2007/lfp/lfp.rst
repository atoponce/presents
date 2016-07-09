============================
*Linux File Permissions 101*
============================

----------------------
*Everything is a file*
----------------------

* Photos, music, video, text, etc
* Monitor
* Printer
* Hard Drive
* Network card
* Directory

--------------------------
*Linux is a multi-user OS*
--------------------------

* Simultaneos multiple user access
* Security definitions built
    * Defined as: user, group, other
    * Defined with: read, write, execute

--------------------------
*Users, groups and others*
--------------------------

* Only two accounts:
    * Many limited user accounts
    * One administrator account (root)
* Access to files is granted via permissions
* Group is a collection of users
* Everyone else 'other'

-----------------------
*Read, Write & Execute*
-----------------------

* Read: access & view the contents of the file and list the contents of a directory
* Write: create, modify and delete files
* Execute: run program/script and enter directories

----------------
*Implementation*
----------------

::

    aaron@kratos:~/tmp$ ls -l
    -rw-r--r--  1 aaron web        15 Sep 20 19:39 bar.html
    -rwxr-xr--  1 aaron aaron     510 Sep 20 19:39 foo.sh
    drwxr-xr-x  2 aaron admin    4096 Sep 20 19:39 stuff

----------------
*Implementation*
----------------

::

    -rw-r--r--   1 aaron web       15 Sep 20 19:39 bar.html
    
              -      rw-    r--     r--
            (type) (user) (group) (other)

Type:

* -\: regular file
* b\: block/buffer device
* c\: character device
* d\: directory
* l\: symbolic link
* p\: named pipe
* s\: socket

----------------
*Implementation*
----------------

::

    -rw-r--r--   1 aaron web       15 Sep 20 19:39 bar.html
    
              -      rw-    r--     r--
            (type) (user) (group) (other)

Access:

* User: read and write
* Group: read only
* Other: read only

----------------
*Implementation*
----------------

::

    -rw-r--r--   1 aaron web       15 Sep 20 19:39 bar.html
    
              1     aaron    web
           (links)  (user) (group)

Links:

* The number of links to that file

Owners:

* 'aaron' is the owner of the file
* 'web' group has access

----------------
*Implementation*
----------------

::

    -rw-r--r--   1 aaron web       15 Sep 20 19:39 bar.html
    
                15       Sep 20 19:39    bar.html
            (byte size) (modified date) (filename)

Size:

* Size of the file/directory in bytes

Date:

* Last date timestamp the file was modified

Filename:

* The actualy name of the file

--------------------
*Change permissions*
--------------------

chmod:

* Change specific permissions of a file/directory

chown:

* Change the owner of a file/directory

chgrp:

* Change the group of a file/directory

--------------------
*Change permissions*
--------------------

chmod:

* user (u), group (g), other (o), all (a)
* add (+), remove (-), set (=)
* read (r), write (w), execute (x)

::

    -rw-r--r--  1 aaron aaron     15 Sep 20 19:39  file1.txt

Demonstration

--------------------
*Change permissions*
--------------------

chmod:

* read (4), write (2), execute (1), none (0)
* Just add the numbers:
    * (0-7) (0-7) (0-7)

::

    -rw-r--r--  1 aaron aaron     15 Sep 20 19:39  file1.txt

Demonstration

--------------------
*Change permissions*
--------------------

chown:

* Change the ownership of the file
* Must be root

::

    -rw-r--r--  1 aaron aaron     15 Sep 20 19:39  file1.txt
    chown bob file1.txt
    -rw-r--r--  1 bob   aaron     15 Sep 20 19:39  file1.txt

chgrp:

* Change the group access to the file
* Don't have to be root- just in both groups

::

    -rw-r--r--  1 aaron aaron     15 Sep 20 19:39  file1.txt
    chgrp web file1.txt
    -rw-r--r--  1 aaron web       15 Sep 20 19:39  file1.txt

------------
*Quiz Time!*
------------

1. What is the numerical chmod of ``-rwxrw-r-x``?
    - Answer: 765
2. Using chmod, how do I change permissions so owner has read/write, group has read and other has no permissions?
    - Answer: chomd 640
    - Answer: chmod u+rw,g+r,o-rwx
3. Can an 'other' user create a file if its parent directory permissions are ``drwxrw-r--``?
    - Answer: no
4. Given the permissions ``----rwxrwx``, can the owner of the file read, write and/or execute the file?
    - Answer: no

------------
*Priorities*
------------

::

    ----rwxrwx  1 aaron aaron     15 Sep 20 19:39  file1.txt

1. Owner FIRST
2. Group SECOND
3. Other LAST

Demonstration

----------------
*4th Permission*
----------------

* chmod 4 file1.txt
* chmod 04 file1.txt
* chmod 004 file.txt
* chmod 0004 file1.txt

::

    aaron@kratos:~$ ls -l
    -------r--  1 aaron aaron      5 Sep 20 19:39  file1.txt

------------
*Sticky Bit*
------------

* Designed initially to "stick" a process in memory
* Keep from deleting other files
* 't' is applied in the other executable location
* Set on directories

::

    aaron@kratos:~$ ls -l /
    ...
    drwxrwxrwt 16 root  root    4096 Sep 20 19:39  tmp
    ...

--------------------
*Setting Sticky Bit*
--------------------

4th permission:

* Change:
    * chmod 1754 foo
    * chmod +t foo

Demonstration

------
*SGID*
------

* Set group identification on a file or directory
* Execute as set group
* Create files under set group

--------------
*Setting SGID*
--------------

4th permission:

* Change:
    * chmod 2777 file.txt
    * chmod g+s file.txt

::

    root@kratos:/home/aaron/tmp# ls -l
    drwxr-xr-x  2 root  root    4096 Sep 20 19:39  foo
    root@kratos:/home/aaron/tmp# chmod 2777 foo
    root@kratos:/home/aaron/tmp# ls -l
    drwxrsxrwx  2 root  root    4096 Sep 20 19:39  foo
    root@kratos:/home/aaron/tmp# su aaron
    aaron@kratos:~/tmp$ touch file.txt
    aaron@kratos:~/tmp$ ls -l
    -rw-r--r--  1 aaron root       0 Sep 20 19:22  file.txt

------
*SUID*
------

* Set user identification on files
* Execute as set user

--------------
*Setting SUID*
--------------

4th permission:

* Change:
    - chmod 4777 file.txt
    - chmod u+s file.txt

::

    root@kratos:/home/aaron/tmp# ls -l
    drwxr-xr-x  2 root  root    4096 Sep 20 19:39  foo
    root@kratos:/home/aaron/tmp# chmod 4777 foo
    root@kratos:/home/aaron/tmp# ls -l
    drsxrwxrwx  2 root  root    4096 Sep 20 19:39  foo
    root@kratos:/home/aaron/tmp# su aaron
    aaron@kratos:~/tmp$ touch file.txt
    aaron@kratos:~/tmp$ ls -l
    -rw-r--r--  1 aaron aaron      0 Sep 20 19:22  file.txt

-------------------------
*SUID- What's the point?*
-------------------------

* Execute a program as another user
    - programs owned by root are run as root
    - you execute the file normally
    - you *must* have execute permissions
* Isn't this dangerous?
    - backup scenario

-------
*Umask*
-------

* User file creation mode mask
* Affects default permissions on new files/directories
* Set in /etc/profile
    - Typically 'umask 022' or 'umask 002'
* Numerically same as chmod:
    - 1 = execute
    - 2 = write
    - 4 = read
* Acts as a filter rather than a setter
* Calculated using chmod - umask = value

-------
*Umask*
-------

* 777 default permissions for directories
* 666 default permissions for files
* umask = 022
* 777 - 022 = 755 (new directories)
* 666 - 022 = 644 (new files)

::

    aaron@kratos:~$ mkdir foo
    aaron@kratos:~$ touch bar
    aaron@kratos:~$ ls -l
    -rw-r--r--  1 aaron aaron      0 Sep 20 19:22  bar
    drw-r-xr-x  2 aaron aaron   4096 Sep 20 19:22  foo

-------------------
*Umask- watch out!*
-------------------

* umask = 174
* 777 - 174 = 603 (new directories)
* 666 - 174 = 602 (new files)

::

    aaron@kratos:~$ mkdir foo
    aaron@kratos:~$ touch bar
    aaron@kratos:~$ ls -l
    -rw-----w-  1 aaron aaron      0 Sep 20 19:22  bar
    drw-----wx  2 aaron aaron   4096 Sep 20 19:22  foo

--------------------------
*Umask- what's happening?*
--------------------------

* Linux won't set +x on files, so it rounds up
    * umask = 122
    * 777 - 122 = 655
    * 666 - 122 = 644 (5 means +rx, so 6 is set)

-------------------
*That's All Folks!*
-------------------

Any questions, thoughts, comments or rude remarks?

------------
*Contact me*
------------

Aaron Toponce

| mailto://aaron.toponce@gmail.com
| xmpp://aaron@aarontoponce.org
| http://aarontoponce.org
| GnuPG 1024D/8086060F

