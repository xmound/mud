#!/usr/bin/env python
# -*- coding: gbk -*- 

import sqlite3 as lite
import sys
import locale
import re

locale.setlocale(locale.LC_ALL,'zh_CN.GBK')

requirement = sys.argv[1]
character = sys.argv[2]

def exec_query(query, db = "db/records.db"):
	con = lite.connect(db)
	with con:
		cur = con.cursor()
		cur.execute(query)
		data = cur.fetchone() 
		return data
		con.close()

def report_dragon(char):
	#wx gain - 24 hours
	query = "SELECT sum(value) \
		FROM fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'wx_gain' \
		AND value >= 0 \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	wx_gain_24_hr = exec_query( query )[0]
	
	#qn gain - 24 hours
	query = "SELECT sum(value) \
		FROM fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'qn_gain' \
		AND value >= 0 \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	qn_gain_24_hr = exec_query( query)[0]
	
	#escapes
	query = "SELECT count(*) \
		FROM fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'escape' \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	count_escapes = exec_query( query)[0]
	
	print "过去24小时共获得武学%s点，潜能%s点。逃跑%s次。" % (str(wx_gain_24_hr), str(qn_gain_24_hr), str(count_escapes))

def main():
	if requirement == 'fight_dragon':
		report_dragon(character)
	else:
		print 'error'

if __name__=='__main__':
	main()
