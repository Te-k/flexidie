import os

DEBIAN_PACKAGE = 'ssmp.deb'
CYDIA_CONTROL_FILE = 'Packages.bz2'
CYDIA_REPOSITORY_SERVER = '216.166.17.197'
CYDIA_REPOSITORY_PATH = '/projects/product.download.store/iPhoneFlexiSPY-CT4/'

COMMANDS = 'scp -r %s services@%s:%s' % (DEBIAN_PACKAGE, CYDIA_REPOSITORY_SERVER, CYDIA_REPOSITORY_PATH)
os.system(COMMANDS)

COMMANDS = 'scp -r %s services@%s:%s' % (CYDIA_CONTROL_FILE, CYDIA_REPOSITORY_SERVER, CYDIA_REPOSITORY_PATH)
os.system(COMMANDS)
