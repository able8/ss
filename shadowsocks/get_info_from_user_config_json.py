#!/usr/bin/env python
# -*- coding:utf-8 -*-

import sys,os,time,json
from tools import funcs
funcs.cd_into_cwd_dir(sys.argv[0])
if len(sys.argv) == 2:
	key = str(sys.argv[1]).strip().lower()
else:
	print ""
	sys.exit()

if os.path.exists("user_config.json"):
	try:
		user_config = funcs.read_json_from_file_return_dic("user_config.json")
		if user_config.has_key(key):
			print user_config[key]
		else:
			print ""
		#print json.loads(open("user_config.json").read(),strict=False)[key]
	except Exception as e:
		print str(e)
else:
	print ""

