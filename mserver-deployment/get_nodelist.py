#!/usr/bin/python2

import xmlrpclib
import datetime
import json

NODE_TIMEOUT = 60*60*2  # we, like plc, assume a node is down after 2h


plc = xmlrpclib.ServerProxy(
        'https://www.planet-lab.org/PLCAPI/',
        allow_none=True)

with open('settings.json', 'r') as f:
    settings = json.load(f)
auth = settings['auth']

node_ids = plc.GetSlices(auth, {'name': 'gt_bismark'}, ['node_ids'])
node_list = plc.GetNodes(auth, {'node_id': node_ids[0]['node_ids']})

recent = []
notrecent = []
for node in node_list:
    if node['last_contact']:
        last_contact = datetime.datetime.utcfromtimestamp(node['last_contact'])
        if (datetime.datetime.utcnow() - last_contact).seconds < NODE_TIMEOUT:
            recent.append(node)
        else:
            notrecent.append(node)
    else:
        notrecent.append(node)

recent.sort(key=lambda x: '.'.join(reversed(x['hostname'].split('.'))))
notrecent.sort(key=lambda x: '.'.join(reversed(x['hostname'].split('.'))))

print("# Recently seen:\n# ==============")
for node in recent:
    print(node['hostname'])
print("# ==============\n# Total: %i\n" % len(recent))

print("# Not recently seen:\n# ==================")
for node in notrecent:
    print("# %s: %s" % (node['hostname'], node['boot_state']))
print("# ==================\n# Total: %i" % len(notrecent))
