#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Notification program used in the typo squatting
bachelor thesis for the python package index.

Created in autumn 2015.

Copyright by Nikolai Tschacher
"""

import os
import ctypes
import sys
import platform

debug = False

# we are using Python3
if sys.version_info[0] == 3:
  import urllib.request
  from urllib.parse import urlencode

  GET = urllib.request.urlopen
# we are using Python2
else:
  import urllib2
  from urllib import urlencode
  GET = urllib2.urlopen

def notify_home(url, package_name, intended_package_name):
  host_os = platform.platform()
  try:
    admin_rights = bool(os.getuid() == 0)
  except AttributeError:
    try:
      ret = ctypes.windll.shell32.IsUserAnAdmin()
      admin_rights = bool(ret != 0)
    except:
      admin_rights = False

  url_data = {
    'p1': package_name,
    'p2': intended_package_name,
    'p3': 'pip',
    'p4': host_os,
    'p5': admin_rights,
    'p6': '',
  }

  url_data = urlencode(url_data)
  response = GET(url + url_data)

  if debug:
    print(response)

  print('')
  print("Warning!!! Maybe you made a typo in your installation\
   command or the module does only exist in the python stdlib?!")
  print("Did you want to install '{}'\
   instead of '{}'??!".format(intended_package_name, package_name))
  print('For more information, please\
   visit http://svs-repo.informatik.uni-hamburg.de/')


def main():
  if debug:
    notify_home('http://localhost:8000/app/?',
             'bs4', 'bs4')
  else:
    notify_home('http://svs-repo.informatik.uni-hamburg.de/app/?',
                     'bs4', 'bs4')

if __name__ == '__main__':
  main()
