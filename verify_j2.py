#!/usr/bin/env python3
"""
Check for errors in Jinja2-templates

This Python script checks Jinja2 templates for syntax errors and provides information about any errors found.
"""

import sys
from jinja2 import Environment, TemplateSyntaxError

try:
    ENV = Environment()
    with open(sys.argv[1]) as template:
        ENV.parse(template.read())
except TemplateSyntaxError as e:
    print ("%s: Syntax check failed: %s in %s at %d\n" % (template, e.message, e.filename, e.lineno))
    exit(1)
except IOError as io:
    print ("No such file or directory: " + str(sys.argv[1]))
    exit(1)
