#!/usr/bin/env python3

from bs4 import BeautifulSoup
import urllib.request
from datetime import datetime
import pytz
from subprocess import call

listBan = {'MMD', 'mmd'}
urls = []


def upload(last):
	call(['./upload.sh', ''])
	return

def getSource():
	req = urllib.request.Request('http://www.nicovideo.jp/tag/%E8%B8%8A%E3%81%A3%E3%81%A6%E3%81%BF%E3%81%9F?sort=f&order=d&ref=cate_newall', data=None, headers={'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'})
	return urllib.request.urlopen(req).read()

def loadURLs():
	with open('urls.txt') as file:
		for line in file:
			urls.append(line.strip()[-10:])

def alreadyDone(id):
	ret=(id in urls)
	return ret

def finalize(list, last):
	hour = last[6:]
	day = last[3:5]
	toBan = False

	for item in list:
		timepost = item.find('span', {'class':'time'})
		title = item.find('p', {'class':'itemTitle'})

		if timepost != None:
			for banWord in listBan:
				if banWord in title:
					toBan = True

			if toBan == False:
				if timepost.text[6:] >= hour[:-1] and timepost.text[3:5] == day and item['data-id'][0:2] == "sm" and alreadyDone(item['data-id']) == False:
					call(['./finalize.sh', 'http://www.nicovideo.jp/watch/'+item['data-id']])
			else:
				print(item['data-id'] + " rejected")

	upload(last)

	open("last.txt", "w").write(datetime.now(pytz.timezone('Asia/Tokyo')).strftime('%m/%d')+' 00:00\n')

	return

def getLast(list, last):
	hour = last[6:]
	day = last[3:5]
	toBan = False
	
	for item in list:
		timepost = item.find('span', {'class':'time'})
		title = item.find('p', {'class':'itemTitle'})
		
		if timepost != None:
			for banWord in listBan:
				if banWord in title:
					toBan = True

			if toBan == False:
				if timepost.text[6:] >= hour[:-1] and timepost.text[3:5] == day and item['data-id'][0:2] == "sm" and alreadyDone(item['data-id']) == False:
					call(['./construct.sh', 'http://www.nicovideo.jp/watch/'+item['data-id']])
			else:
				print(item['data-id'] + " rejected")
	
	
	open("last.txt", "w").write(datetime.now(pytz.timezone('Asia/Tokyo')).strftime('%m/%d %H:%M')+'\n')
	return

def main():
	last = open("last.txt").read()
	lastday = int(last[3:5])
	now = datetime.now(pytz.timezone('Asia/Tokyo'))
	
	list = BeautifulSoup(getSource()).findAll('li', {'class':'item', 'data-id':True})
	loadURLs()

	if now.day != lastday:
		finalize(list, last)
	else:
		getLast(list, last)
 
	return

if __name__ == "__main__":
	main()
