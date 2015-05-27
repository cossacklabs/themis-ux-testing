# -*- coding: utf-8 -*-

from gevent import pywsgi
import gevent.monkey
gevent.monkey.patch_all()

import json
import argparse
import random, string
from datetime import datetime

import pymongo

from themis import smessage, scell

file_db_keys = 'lstore.txt'

sccs = ['Success','OK','OLALA','Perfecto','Uspeh','WIN','Pobeda']

def run(env, start_response):
	if env['PATH_INFO'] == '/':
		string_get = env['wsgi.input'].readline()
		try:
			inc = json.loads(string_get)
		except:
			start_response('404 Not Found', [('Content-Type', 'application/json')])
			return [json.dumps({"error":"Not json"})]
		else:
			if not isinstance(inc,dict) or len(inc.keys()) != 1:
				start_response('404 Not Found', [('Content-Type', 'application/json')])
				return [json.dumps({'error':'Wrong body'})]
			else:
				name = inc.keys()[0]
				try:
					mess = inc[name].decode('base64')
				except:
					start_response('404 Not Found', [('Content-Type', 'application/json')])
					return [json.dumps({'error':'Encode error'})]
				print name,'---->', mess
				if name not in main_dict_user.keys():
					main_dict_user[name] = mess
					start_response('200 OK', [('Content-Type', 'application/json')])
					encrypter=smessage.smessage(server_priv, main_dict_user[name]);
					res = ''.join(random.choice(sccs) for i in range(1))
					res = encrypter.wrap(res)
					return [json.dumps({'answer':res.encode('base64')})]
				else:
					try:
						encrypter=smessage.smessage(server_priv, main_dict_user[name]);
						message = encrypter.unwrap(mess);
						tm_now = str(datetime.now())
						dem = db_crypt.encrypt(message,'%s%s' % (name,tm_now))

						dbm.insert_one({'name':name,'ts':tm_now,'mess':dem.encode('base64')})
						start_response('200 OK', [('Content-Type', 'application/json')])
						res = encrypter.wrap(''.join(random.choice(sccs) for i in range(1)))
						return [json.dumps({'answer':res.encode('base64')})]
					except Exception, e:
						print e
						start_response('404 Not Found', [('Content-Type', 'application/json')])
						return [json.dumps({'error':'Duplicate user'})]
	elif env['PATH_INFO'] == '/stat':
		res = ''
		res += '<table>'
		res += '<tr><td>' + 'Name'+ '</td><td>' + 'Timestamp' + '</td><td>' + 'Message' + '</td></tr>'
		for x in dbm.find({}):
			try:
				res += '<tr><td>' + str(x['name'])+ '</td><td>' + str(x['ts']) + '</td><td>' + str(db_crypt.decrypt(x['mess'].decode('base64'),'%s%s' % (x['name'],x['ts']))) + '</td></tr>' 
			except:
				pass
		res += '</table>'
		start_response('200 OK', [('Content-Type', 'text/html')])
		return [str(res)]
	else:
		start_response('404 Not Found', [('Content-Type', 'application/json')])
		return [json.dumps({'error':'Not Found'})]

if __name__ == '__main__':
	main_dict_user = {}
	parser = argparse.ArgumentParser()
	parser.add_argument("-m",'--master_pass', help='set master password')
	args = parser.parse_args()
	if not args.master_pass:
		print 'No master pass'
		exit(0)
	else:
		master_pass = args.master_pass
	dict_dbkeys = {}
	try:
		fp = open(file_db_keys,'r')
		for x in fp.readlines():
			mp,dbp = x.split()
			dict_dbkeys[mp] = dbp
		fp.close()
	except:
		pass
	if master_pass in dict_dbkeys.keys():
		dbkey = dict_dbkeys[master_pass]
	else:
		dbkey = ''.join(random.choice(string.lowercase) for i in range(32))
		fp = open(file_db_keys,'a+')
		fp.write('%s %s\n' % (master_pass,dbkey))
		fp.close()

	db_crypt = scell.scell_full(dbkey)

	#init mongoconnect
	dbm = pymongo.MongoClient('127.0.0.1',27017).tmain.stor



	main_dict_user = {}
	server_priv= str('\x52\x45\x43\x32\x00\x00\x00\x2d\x49\x87\x04\x6b\x00\xf2\x06\x07\x7d\xc7\x1c\x59\xa1\x8f\x39\xfc\x94\x81\x3f\x9e\xc5\xba\x70\x6f\x93\x08\x8d\xe3\x85\x82\x5b\xf8\x3f\xc6\x9f\x0b\xdf')
	# server_pub  = str('\x55\x45\x43\x32\x00\x00\x00\x2d\x75\x58\x33\xd4\x02\x12\xdf\x1f\xe9\xea\x48\x11\xe1\xf9\x71\x8e\x24\x11\xcb\xfd\xc0\xa3\x6e\xd6\xac\x88\xb6\x44\xc2\x9a\x24\x84\xee\x50\x4c\x3e\xa0')
	server = pywsgi.WSGIServer(('0.0.0.0', 8828), run)
	try:
		server.serve_forever()
	except KeyboardInterrupt:
		print 'Bye'