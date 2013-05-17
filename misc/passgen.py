#!/usr/bin/env python
#
# Generates a password with 12 characters

import random,string,os
def passgen(size=12, chars=string.hexdigits):
    return ''.join(random.choice(chars) for x in range(size))
print passgen()
