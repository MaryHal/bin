#!/usr/bin/env python

# What features do i want...
# - restore/backup based on time
# - possibly lesser restores based on older backups? that seems like a bit
#   much. Or a bit over my head at this point in time.
# - allow the user to report the filesystem type. 'cuz you know...FAT32 is annoying. 

# POSSIBLY restore packages too

import os
import sys

import subprocess
from optparse import OptionParser
import datetime

def savePackageLists():
    print ("Saving explicitly installed packages...")
    os.system("pacman -Qeq > ~/pkglist_explicit")
    print ("Saving AUR/non-local packages...")
    os.system("pacman -Qmq > ~/pkglist_aur")

def createBackup(filesystem):
    # TODO: actually do stuff for other file system types
    filesystem = filesystem.lower()
    os.system("sudo tar -cvf '/home/sanford/archlinux.tar' '/home/sanford/'")
    os.system("sudo tar -cvf '/home/sanford/shared.tar' '/mnt/shared/'")
    
def restoreBackup():
    pass

def checkPrivileges():
    return os.getuid() == 0 and "root" or "not root"

def getDate():
    return datetime.datetime.now()

if __name__ == "__main__":
"""
    if checkPrivileges() != "root":
        print ("Script needs root access.")
        sys.exit()
"""

    parser = OptionParser()
    parser.add_option('-b', '--backup', action='store', type='string', dest='backupDirectory', metavar='DIRECTORY', help='Create a backup of /home/sanford/ and /mnt/shared/ in directory DIRECTORY.')

    # is this no longer wrong? will find out later...
    parser.add_option('-r', '--restore', action='store', type='string', dest='restoreDirectory', metavar='DIRECTORY', help='Restore a backup. This should use the most recent copies of the backup tarballs.')

    parser.add_option('-f', '--filesystem', action='store', type='string', dest='filesystem', help='Designate the file system type; This is used as drives formatted as FAT32 cannot have file sizes larger than 4GB')

    parser.add_option('-p', '--packages-only', action='store_true', dest="packagesOnly", help='Only create package lists')

    (options, args) = parser.parse_args()

    print (options)
    print (args)

    # add priority to backup over restore
    # Try to rethink this form. I feel like there is a better way to do this.
    if options.packagesOnly == True:
        savePackageLists()
    elif options.backupDirectory != None:
        savePackageLists()
        createBackup()
    elif options.restoreDirectory!= None:
        # TODO: fix this.
        restoreBackup()
    else:
        parser.print_help()

    


