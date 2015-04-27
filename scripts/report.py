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
		AND value <= 200 \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	wx_gain_24_hr = exec_query(query)[0]
	
	#qn gain - 24 hours
	query = "SELECT sum(value) \
		FROM fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'qn_gain' \
		AND value >= 0 \
		AND value <= 100 \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	qn_gain_24_hr = exec_query(query)[0]
	
	# unique minutes
	query = "select count(distinct strftime('%%H:%%M',dt)) num_minutes \
		from fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'wx_gain' \
		AND value >= 0 \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	num_minutes = exec_query(query)[0]
	
	#escapes
	query = "SELECT count(*) \
		FROM fight_dragon_log \
		WHERE char = '%s' \
		AND dt >= datetime('now', '-1 day', 'localtime') \
		AND event = 'escape' \
		" % character
	query = re.sub('(\t)*(\s)+', ' ', ''.join(query))
	count_escapes = exec_query(query)[0]
	
	activeness = num_minutes *100  / (60*24)
	active_hours = 1.0* num_minutes / 60
	avg_wx_gain = wx_gain_24_hr * 60 / num_minutes
	avg_qn_gain = qn_gain_24_hr * 60 / num_minutes 
	
	print "在过去24小时内活跃打龙时间约为%.1f小时,共获得武学%s，潜能%s。平均%s武学/小时，%s潜能/小时。全效率期望值为每天%d武学。期间中断逃跑%s次。" \
	% (active_hours, str(wx_gain_24_hr), str(qn_gain_24_hr), str(avg_wx_gain), str(avg_qn_gain), avg_wx_gain*24, str(count_escapes))

def main():
	if requirement == 'fight_dragon':
		report_dragon(character)
	else:
		print 'error'

if __name__=='__main__':
	main()
