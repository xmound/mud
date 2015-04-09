#!/usr/bin/env python
# -*- coding: gbk -*- 

#import os
import sys
import locale
locale.setlocale(locale.LC_ALL,'zh_CN.GBK')
#print locale.getlocale()

string_to_convert = sys.argv[1]

def convert_number(s):
	#print isinstance(s.decode('gbk'), unicode)
	#print isinstance(s.decode('gbk').encode('gbk'),str)
	#print 'input:' + s
	s = s.replace("不到", "")
 	s = s.replace("年", "")
 	s = s.replace("甲子又十", "*60+10+")
 	s = s.replace("甲子", "*60")
 	s = s.replace("又", "+")
 	s = s.replace("一", "1")
 	s = s.replace("二", "2")
 	s = s.replace("三", "3")
 	s = s.replace("四", "4")
 	s = s.replace("五", "5")
 	s = s.replace("六", "6")
 	s = s.replace("七", "7")
 	s = s.replace("八", "8")
 	s = s.replace("九", "9")
 	s = s.replace("十", "*10+")
	if s[-1] == "+":
		s = s + "0"
	if s[0] == "\*":
		s = "1" + s
	r = eval(s)
	print r
	#return r
	
	#if (%pos(%char(41),@YaoNeili2)) {YaoNeili2=%concat(%char(40),@YaoNeili2)}; this means if there are n ')'s, add '('
	# YaoNeili2=%replace(@YaoNeili2,+~),+0~));
	# YaoNeili2=%eval(@YaoNeili2)

def main():
	convert_number(string_to_convert)

if __name__=='__main__':
	main()