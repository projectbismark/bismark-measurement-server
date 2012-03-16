#!/usr/bin/env python

import bottle
import bottle_sqlite
import sqlite3
import hashlib
import base64
import json
import time
import socket
import xmlrpclib
import datetime

# make some middleware
# responsibilities include:
#   - http basic auth (and later, some credential caching scheme)
#   - content-md5 header, if present
#             if 'Content-MD5' in response.headers:
#                response.set_header(
#                        'Content-MD5',
#                        base64.b64encode(hashlib.md5(''.join(out)).digest()))
#   - etag header, if present

SETTINGS_FILE = 'settings.json'

with open(SETTINGS_FILE, 'r') as f:
    settings = json.load(f)

class MserverMgmtApp(object):
    def __init__(self, bottle_app):
        self.post_response=[]
        self.bottle_app = bottle_app

    def post_hook(self, f):
        self.post_response.append(f)
        return f

    def wsgi(self, environ, start_response):
        bottle_status = [None]
        bottle_headers = [None]
        def bottle_start_response(status, headers):
            bottle_status[0] = status
            bottle_headers[0] = headers
        bottle_out = self.bottle_app.wsgi(environ, bottle_start_response)
        bottle_status = bottle_status[0]
        bottle_headers = bottle_headers[0]
        # this might not scale well for large documents
        if hasattr(bottle_out, '__iter__'):
            bottle_out = [x for x in bottle_out]
        # do stuff here...
        for func in self.post_response:
            func(bottle_status, bottle_headers, bottle_out)
        start_response(bottle_status, bottle_headers)
        return bottle_out


app = bottle.Bottle()
app.install(bottle_sqlite.SQLitePlugin(dbfile=settings['dbfile']))
mserver_app = MserverMgmtApp(app)


@mserver_app.post_hook
def add_conditional_contentmd5(status, headers, out):
    add_contentmd5(status, headers, out, conditional=True)

def add_contentmd5(status, headers, out, conditional=False):
    index = -1
    for i in xrange(len(headers)):
        if headers[i][0].lower() == 'Content-MD5'.lower():
            index = i
    if index == -1 and not conditional:
        headers.append(None)
        index = len(headers) - 1
    if index > -1:
        headers[index] = (
                'Content-MD5',
                base64.b64encode(hashlib.md5(''.join(out)).digest()))

#@app.hook('before_request')
#def check_auth():
#    print("### before_request")
#    if bottle.request.url.find('jabberwocky') > -1:
#        #raise bottle.HTTPError(401, {'error': 'access denied'})
#        raise bottle.HTTPResponse(json.dumps({'error': 'access denied'}), 401)

#@app.route('/')
#def identifier():
#    return {'measurement_servers': '/mservers'}


@app.get('/mservers')
@app.get('/mservers/')
def get_all_mservers(db):
    c = db.execute('SELECT * from mservers;')
    rows = c.fetchall()

    try:
        if 'text/html' in headers['accept']:
            return template('all_mservers', mservers=rows)
        elif 'application/json' in header['accept']:
            out = []
            for row in rows:
                out.append('/mservers/' + row['fqdn'])
            return({'mservers': out})
    except KeyError:
        pass
    raise bottle.HTTPError(406)



@app.get('/mservers/<mserver_fqdn>')
@app.get('/mservers/<mserver_fqdn>/')
def get_mserver(db, mserver_fqdn):
    c = db.execute('SELECT * from mservers where fqdn = ?;', (mserver_fqdn,))
    row = c.fetchone()
    if row:
        return {
                'fqdn' : row['fqdn'],
                'ip' : row['ip'],
                'last_seen' : row['last_seen'],
                'last_seen_iso_utc' : datetime.datetime.utcfromtimestamp(
                        row['last_seen']).isoformat(),
                'bismark-mserver_version' : row['version'],
                'puppet_config_version' : row['puppet_version']
                }
    raise bottle.HTTPError(404, "mserver not found.")


@app.post('/mservers/<mserver_fqdn>')
@app.post('/mservers/<mserver_fqdn>/')
def post_mserver(db, mserver_fqdn):
    if (not fqdn_matches_remote_addr(mserver_fqdn) or
            not fqdn_authorized(db, mserver_fqdn)):
        raise bottle.HTTPError(401, "not authorized")
    if bottle.request.json:
        json_valid = True
        try:
            if 'ip' not in bottle.request.json:
                json_valid = False
            else:
                octets = bottle.request.json['ip'].split('.')
                if (len(octets) != 4 or
                        not all((0 <= int(o) <= 255 for o in octets))):
                    json_valid = False
            if 'bismark-mserver_version' not in bottle.request.json:
                json_valid = False
        except (LookupError, ValueError, AttributeError):
            json_valid = False

        if not json_valid:
            raise bottle.HTTPError(400, "malformed request")

        db.execute(
                'REPLACE INTO mservers '
                '(fqdn, ip, last_seen, version, puppet_version) VALUES (?,?,?,?,?);',
                (mserver_fqdn,
                bottle.request.json['ip'],
                int(time.time()),
                bottle.request.json['bismark-mserver_version'],
                bottle.request.json.get('puppet_config_version', None)))
        db.commit()
        return bottle.HTTPResponse(status=204)
    else:
        raise bottle.HTTPError(
                400, "request must be formatted as application/json")


@app.get('/mservers/<mserver_fqdn>/hosts.allow')
def get_mserver_hostsallow_json(db, mserver_fqdn):
    if (not fqdn_matches_remote_addr(mserver_fqdn) or
            not fqdn_authorized(db, mserver_fqdn)):
        raise bottle.HTTPError(401, "not authorized")
    return({'hosts.allow' : {'ALL' : 'ALL'}})


##########################


def fqdn_matches_remote_addr(fqdn):
    try:
        if (bottle.request.remote_addr in settings['admin_ips'] or
            bottle.request.remote_addr == socket.gethostbyname(fqdn + '.')):
            return True
    except IOError as ioe:
        print(ioe)
    return False

def fqdn_authorized(db, fqdn):
    try:
        c = db.execute(
                'SELECT * from authorized_fqdns where fqdn = ?;', (fqdn,))
        if c.fetchone():
            return True
    except sqlite3.Error:
        pass
    return False

def check_sqlite(db):
    if not db.execute(
            "SELECT name "
            "FROM sqlite_master "
            "WHERE type = 'table' and name = 'mservers'").fetchone():
        db.execute(
            "CREATE TABLE mservers "
            "   (fqdn text primary key, "
            "   ip text, "
            "   last_seen integer, "
            "   version text, "
            "   puppet_version text);")
        db.commit()
    if not db.execute(
            "SELECT name "
            "FROM sqlite_master "
            "WHERE type = 'table' and name = 'authorized_fqdns'").fetchone():
        db.execute("CREATE TABLE authorized_fqdns (fqdn text primary key);")
        db.commit()

def add_authorized_fqdns(db, additional_fqdns=[]):
    plc = xmlrpclib.ServerProxy(
            'https://www.planet-lab.org/PLCAPI/',
            allow_none=True)

    auth = settings['planetlab']['auth']
    node_ids = plc.GetSlices(auth, {'name': 'gt_bismark'}, ['node_ids'])
    node_list = plc.GetNodes(auth, {'node_id': node_ids[0]['node_ids']})
    node_fqdns = [('bismark.gt.' + n['hostname']) for n in node_list]
    node_fqdns.extend(additional_fqdns)

    db.execute('DELETE FROM authorized_fqdns;');
    db.executemany(
            'INSERT INTO authorized_fqdns(fqdn) VALUES (?)',
            ((n,) for n in node_fqdns))
    db.commit()

def resolve_admin_fqdns():
    settings['admin_ips'] = []
    for fqdn in settings['admin_fqdns']:
        try:
            settings['admin_ips'].append(socket.gethostbyname(fqdn))
        except IOError as ioe:
            print(ioe)

def main(debug=False):
    db = sqlite3.connect(settings['dbfile'])
    check_sqlite(db)
    add_authorized_fqdns(db, additional_fqdns=settings['admin_fqdns'])
    resolve_admin_fqdns()
    db.close()
    if debug:
        bottle.debug()
        bottle.run(
                app=mserver_app.wsgi,
                host='0.0.0.0',
                port=8080,
                reloader=True)
    else:
        bottle.run(
                app=mserver_app.wsgi,
                host=settings['http_server']['host'],
                port=settings['http_server']['port'])

if __name__ == '__main__':
    main()
