#!/usr/bin/env python

import argparse
import subprocess
import os
import sys
import socket
import paramiko
import logging
import logging.handlers
import yaml

def parse_options():
    parser = argparse.ArgumentParser(description="""

    Backup Data
""")
    parser.add_argument('-c', '--config', help='config file (default=move-em.yaml)', type=str, default='move-em.yaml')
    parser.add_argument('-v', '--verbosity', help='Show debug output', action='count', default=0)
    arguments = vars(parser.parse_args())
    return arguments 


def logger(name, verbosity=1):
    global log
    level = {
        0: logging.ERROR,
        1: logging.WARNING,
        2: logging.INFO,
        3: logging.DEBUG
    }.get(verbosity, logging.DEBUG)
    
    if log:
        return log

    log = logging.getLogger(name=name)
    log.setLevel(level=level)

    fh = logging.FileHandler('/var/log/move-em.log')
    fh.setLevel(logging.DEBUG)

    ch = logging.StreamHandler()
    ch.setLevel(level)

    formatter = logging.Formatter("%(asctime)s %(name)s %(levelname)-7s %(message)s")
    fh.setFormatter(formatter)
    ch.setFormatter(formatter)

    log.addHandler(fh)
    log.addHandler(ch)
    return log



def rsync_dir(source, ssh_user, target, node, keyfile):
   ssh_options = ' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
   ssh_options += ' -i %s' % keyfile
   ssh_options += ' -x -o ConnectTimeout=1 -o PasswordAuthentication=no '
   ssh_cmd = "/usr/bin/ssh %s" % ssh_options

   rsync_cmd = "/usr/bin/rsync --progress --recursive -av -e '%s' %s %s@%s:%s 2>&1" % (ssh_cmd, source, ssh_user, node, target)

   process = subprocess.Popen(rsync_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
   while True:
       nextline = process.stdout.readline()
       if nextline == '' and process.poll() != None:
           break
       log.debug(nextline.strip())

   output = process.communicate()[0]
   exitCode = process.returncode

   if exitCode == 0:
       log.info('Rsync for %s to %s at %s [OK]' % (source, target, node))
       return True
   else:
       log.error('Rsync for %s to %s as %s at %s: exitcode: %s [FAILED]' % (source, target, ssh_user, node, exitCode))
       log.debug('Output was: %s' % output)
       return False


def test_ssh(node, keyfile, ssh_user):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname=node, username=ssh_user, key_filename=keyfile)
    try:
        ssh = client.get_transport().open_session()
        ssh.exec_command('uptime')
        if ssh.recv_exit_status() != 0:
            return False
        else:
            return True
    except Exception as e:
        log.error('Testing ssh gave an exception: %s' % e)
        return False


def main():
    args = parse_options()
    log = logger("Backup script", args['verbosity'])

    log.info('Reading config file %s' % args['config'])
    try:
        with open(args['config']) as fh:
            config = yaml.load(fh)
    except Exception as e:
        log.error("Failed to parse config file %s: Error: %s" % (args['config'], e))

    if not os.path.isfile(config['ssh_key']):
        log.error('SSH Keysfile %s not found!' % config['ssh_key'])
        sys.exit(1)

    log.info('Testing remote server %s for ssh connectivity' % config['backup_host'])
    ssh_ok = test_ssh(config['backup_host'], config['ssh_key'], config['ssh_user'])
    if not ssh_ok:
        log.error('Failed to connect to %s' % config['backup_host'])
        sys.exit(1)

    log.info('Starting backup routine')
    for source_dir in config['backup_src']:
        if not os.path.isdir(source_dir):
            log.error('Dir %s not found! Skipping!' % source_dir)
            continue

        target_dir = config['backup_dest']

        log.info('Rsyncing sourcedir %s to %s:%s' % (source_dir, config['backup_host'], target_dir))
        rsync = rsync_dir(source_dir, config['ssh_user'], target_dir, config['backup_host'], config['ssh_key'])
        if not rsync:
            log.error('Failed to connect to %s' % config['backup_host'])
            sys.exit(1)
    log.info('All dirs done!')


if __name__ == "__main__":
    log = {}
    main()
