# -*- coding: utf-8 -*-
'''
customStat execution module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Module used to request some information to Linux minion:
- Time system load
- Average CPU load
- Process
- Used disk space (percentage)
- Users logged in
- Memory used (percentage)
- Swap memory used (percentage)
- IPv4 for interfaces

.. versionadded:: 0.0.1
'''


# Import Python libs
from __future__ import absolute_import, unicode_literals, print_function
import logging
import os
import urllib2 as Url

# Import salt libs
import salt.utils.compat
import salt.utils.network as Network


log = logging.getLogger(__name__)

__virtualname__ = 'customStat'

__num_user_logged_from_uptime__ = 0
__average_from_uptime__ = ''
__swap_memory_percentage__ = ''

def __virtual__():
    '''
    Only work on POSIX-like systems
    '''
    # Disable on Windows, a specific file module exists:
    if salt.utils.platform.is_windows():
        return (False, 'The network execution module cannot be loaded on Windows.')
    return True


def get_stats():
    '''
    Return the all statistic options passed to this minion>

    CLI Example:

    .. code-block:: bash

        salt '*' customStats.get_stats
    '''
    if __grains__['kernel'] == 'Linux':
        ret={}
        ret.update({'Uptime':get_uptime()})
        ret.update({'Users':get_user_logged()})
        ret.update({'Average':get_avg()})
        ret.update({'Disk':get_disk()})
        ret.update({'Process':get_process()})
        ret.update({'Memory used':get_memory()})
        ret.update({'Swap used':get_swap()})
        ret.update({'IPv4':get_network_ip_addrs()})
        ret.update({'Check connection':get_connection_check()})
    return ret


def get_disk():        
    '''
    Return the percentage of used ROOT disk to this minion
    '''
    cmd = 'df -P'
    ret = {}
    comps = []
    out = __salt__['cmd.run'](cmd, python_shell=False).splitlines()

    log.debug(out)

    for line in out:
        if not line:
            continue
        if line.startswith('Filesystem'):
            continue
        comps = line.split()
        try:
            if comps[5] == "/":
                ret = comps[4]
            else:
                pass
        except IndexError:
            log.error('Problem parsing disks usage information')
            ret = {}
    return ret


def get_disks():
    '''
    Return the percentage of used disk passed to this minion
    '''
    cmd = 'df -P'
    ret = {}
    comps = []
    out = __salt__['cmd.run'](cmd, python_shell=False).splitlines()
    #f = os.popen(cmd)
    #out = f.read().splitlines()

    log.debug(out)

    for line in out:
        if not line:
            continue
        if line.startswith('Filesystem'):
            continue
        comps = line.split()
        while len(comps) >= 2 and not comps[1].isdigit():
            comps[0] = '{0} {1}'.format(comps[0], comps[1])
            comps.pop(1)
        if len(comps) < 2:
            continue
        try:
            ret[comps[5]] = comps[4]
        except IndexError:
            log.error('Problem parsing disks usage information')
            ret = {}

    return ret


def get_uptime():
    '''
    Return the uptime to this minion
    '''
    cmd = 'uptime'
    ret = {}
    comps = []
    out = __salt__['cmd.run'](cmd, python_shell=False).splitlines()
    #f = os.popen(cmd)
    #out = f.read().splitlines()

    log.debug(out)

    for line in out:
        if not line:
            continue
        comps = line.split('up')
        dotted = comps[1].split(',')
        user = [0] * 1
        avg = [0] * 1
        try:
            user[0] = list(dotted[2].split())[0]
        except IndexError:
            log.error('Problem parsing NumberUser in uptime information')
            ret = {}    
        
        try:
            comps = line.split('average:')
            avg[0] = str(comps[1]).strip()
        except IndexError:
            log.error('Problem parsing Average in uptime information')
            ret = {}
        
        try:
            ret = str(dotted[0]).strip()
            global __num_user_logged_from_uptime__
            global __average_from_uptime__
            __num_user_logged_from_uptime__ = user[0]
            __average_from_uptime__ = avg[0] 
        except IndexError:
            log.error('Problem parsing uptime information')
            ret = {}

    return ret    


def get_user_logged():
    '''
    Return the number of user logged into this minion
    '''
    return __num_user_logged_from_uptime__

def get_avg():
    '''
    Return the average CPU Load (one, five, and fifteen minute averages) into this minion
    '''
    return __average_from_uptime__


def get_process():
    '''
    Return the number of the ALL processes (user+root) run into this minion
    '''
    cmd = 'ps -AL --no-headers ' + chr(124) + 'wc -l'
    ret = {}
    comps = []
    out = __salt__['cmd.run'](cmd, python_shell=True).splitlines()
    #f = os.popen(cmd)
    #out = f.read().splitlines()

    log.debug(out)

    for line in out:
        comps = line.split()
        try:
            ret = comps[0]
        except IndexError:
            log.error('Problem parsing processes information')
            ret = {}

    return ret


def get_memory():
    '''
    Return the percentage of used memory to this minion
    '''
    cmd = 'free'
    ret = {}
    comps = []
    out = __salt__['cmd.run'](cmd, python_shell=False).splitlines()
    #f = os.popen(cmd)
    #out = f.read().splitlines()

    log.debug(out)

    for line in out:
        if not line:
            continue
        if line.startswith(' ') or line.startswith('total'):
            continue
        comps = line.split()
        try:
            num = float(comps[2])
            den = float(comps[1])
            temp = (num/den)*100
            if line.startswith('Mem'):
                ret = str("{0:.1f}".format(temp))
            if line.startswith('Swap'):
                global __swap_memory_percentage__
                __swap_memory_percentage__ = str("{0:.1f}".format(temp))
        except IndexError:
            log.error('Problem parsing memory information')
            ret = {}
    return ret    


def get_network_ip_addrs():
    ret = {}
    stringa = str()
    listIP = Network.ip_addrs()
    for ip in listIP:
        stringa = stringa + ' ' + ''.join(ip)
    ret = stringa.strip()
    return ret

def get_connection_check():
    ret = {}
    cmd = 'ping www.google.com'
    try:
        Url.urlopen('http://www.google.com', timeout=0.5)
        ret = '1'
    except Url.URLError as err: 
        log.error('Problem to contact http://www.google.com:80')
        ret = '0'
    return ret


def get_swap():
    '''
    Return the percentage of swap memory to this minion
    '''
    return __swap_memory_percentage__


if __name__ == "__main__":
    get_stats()