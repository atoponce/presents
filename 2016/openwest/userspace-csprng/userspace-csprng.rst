.. include:: <s5defs.txt>

=================================================
Cryptographically Secure Userspace Random Numbers
=================================================

:Author: Aaron Toponce
:Email: aaron.toponce@gmail.com
:Date: Jul 13, 2016

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

* Why use random numbers?
* Pseudorandom numbers
* Cryptographically secure pseudorandom numbers
* True random numbers
* Randomness tests

Why need random numbers?
========================

* Lottery drawing
* Generic gambling
* Thermodynamics
* Quantum mechanics
* Pattern recognition
* Game theory
* Monte Carlo simulations
* Cryptography

Randomness
==========

* Lack of pattern or pedictability of events without order.
* Individual events unpredictable.
* Frequency of different outcomes over large events is predictable.
* Randomness is distinct from chaos theory.

Monte Carlo Simulations
=======================

* Approximate a result using random numbers.
* Estimating an approximation for Pi.

.. image:: images/monte_carlo_pi.gif

Properties of Pseudorandom Numbers (PRNG)
=========================================

* Must start with an initial seed.
* Uniformally distributed.
* Large period.
* Fast generation.

Some Pseudorandom Number Designs
================================

* Middle-square method.
* Linear congruential generator.
* Lagged Fibonacci generator.
* Linear feedback-shift registers.
* Mersenne-Twister.
* Multiply with carry.
* Xorshift.

Properties of a CSPRNG
======================

* Must start with an initial seed.
* Uniformally distributed.
* Large period.
* Fast generation.
* Must satisfy the next-bit test.
* Must withstand "state compromise extensions".

How To Create A CSPRNG?
=======================

* Must be non-linear.
* Can be built using existing cryptographic primitives.
* Can address the discrete logarithm problem.
* Can address the quadratic residuosity problem.

Designs Based On Cryptographic Primitives
=========================================

* A secure block cipher (AES, Twofish, Serpent)
* A secure stream cipher (Salsa20, ISAAC, Rabbit)
* A secure cryptographic hashing function (SHA-2/3, Skein, BLAKE2)

Number Theoretic Designs
========================

* Discrete logarithm (Blum-Micali)
* Quadratic residue (Blum-Blum-Shub)
* Diffie-Hellman (given g^x, g^y, find g^(xy))

Discrete Logarithm Problem
==========================

* Given an integer 'g' over a finite group
* Find an integer 'k' which solves 'g = b^k'
* Where 'b' is an element of the same finite group

Quadratic Residuosity Problem
=============================

* Given integers 'a' and 'T'
* 'a' is a quadratic residue modulo 'T' if
* an integer 'b' exists such that 'a ≡ b^2 mod T'

Diffie-Hellman Problem
======================

* Given a generator 'g' over some group
* And given 'm = g^x' and 'n = g^y'
* Find 'p' such that 'p = g^(xy)'

Cryptographic Primitive In Counter Mode
=======================================

* Block cipher, stream cipher, or hash function.
* Begin with an n-bit counter "i" and a key "k".
* Key should have at least 80-bits of entropy.
* N = CP(i, k)
* i += 1

Counter Mode CSPRNG Example
===========================

* AES-128 in ECB mode (no IV).
* i=(128-bits 0), k="n5kzb2npmqaadheh"
* AES-128(i, k) = 7nYXRPVfbJ9bKKXY5/Xrgw
* AES-128(i+1, k) = mMuT/o4uqyi/ZiSoTuaXLA
* AES-128(i+2, k) = YCrIIhPLQmBEIpxFUXEqDA
* AES-128(i+3, k) = wBnyyhtX4oG5ar6Jxpu0+A
* AES-128(i+4, k) = PEVHWFBR0psbAxNuNiRzcA
* etc.

Counter Mode CSPRNG Observations
================================

* Only as secure as the primitive used.
* The private key must have sufficient entropy.
* Encoding may be needed.

ANSI x9.17 CSPRNG
=================

* Initially defined with 64-bit 3DES.
* Block cipher, stream cipher, or hash function.
* Begin with an n-bit seed "s" and an n-bit key "k".
* while true:
* Get an n-bit precision time "t".
* X = CP(t, k)
* O = CP(XOR(s, X), k)
* s = CP(XOR(O, X), k)

ANSI x9.17 CSPRNG Example
=========================

.. code::

    for i in xrange(0, number):
        date = repr(time.time())
        temp = aes.encrypt(date.zfill(32))
        out = aes.encrypt(sxor(seed,temp))
        seed = aes.encrypt(sxor(out,temp))
        res = struct.unpack('QQ', out)
        print(res[0]*2**64+res[1])

ANSI x9.17 CSPRNG Example
=========================

.. code::

    $ python ansi_x9.17.py -n 5 -k tawb6tfp -s 3p4cmuh2
    314010904079469780053519644035505825480
    306641776578407103837728977951414077374
    156955769336596636999723525334223823715
    173148246584751831703187613687035398429
    115865582697038227031809203876290428300

ANSI x9.17 CSPRNG Observations
==============================

* Because defined with 3DES, superceded by ANSI x9.31
* Only as secure as the primitive used.
* The private key must have sufficient entropy.
* Adversary could set the clock

Fin
===

Comments, questions, or rude remarks?

:Email: aaron.toponce@gmail.com
