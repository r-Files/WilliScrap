# -*- coding: utf-8 -*-
"""
Created on Wed Jan  1 13:13:54 2020

@author: pribahsn
"""

import json
import re
import requests
import urllib
import time
import os
import datetime
import pandas as pd
from bs4 import BeautifulSoup


def fetchAdd(url):
    page = requests.get(url)

    soup = BeautifulSoup(page.content, 'html.parser')
    table = soup.find_all('div', class_='row col-2-box')

    columns = [span.text.strip() for span in table[0].find_all('span', class_='col-2-desc')]
    values = [span.text.strip() for span in table[0].find_all('div', class_='col-2-body')]
    result = pd.DataFrame(data=[values], columns=columns)
    if 'Wohnfläche' in result.columns:
        result.at[0, 'Wohnfläche'] = float(result.at[0, 'Wohnfläche'].replace('m²', ''))
    if 'Nutzfläche' in result.columns:
        result.at[0, 'Nutzfläche'] = float(result.at[0, 'Nutzfläche'].replace('m²', ''))
    if 'Gesamtfläche' in result.columns:
        result.at[0, 'Gesamtfläche'] = float(result.at[0, 'Gesamtfläche'].replace('m²', ''))
    if 'Zimmer' in result.columns:
        result.at[0, 'Zimmer'] = float(result.at[0, 'Zimmer'].replace(',', '.'))
    result['Preis'] = 0 if len(re.findall('.*€(.*?),', soup.title.text)) == 0 else re.findall('.*€(.*?),', soup.title.text)[0].strip().replace('.', '')
    result['Titel'] = soup.title.text.strip()
    result['Bezirk'] = urllib.parse.urlparse(url).path.split('/')[6]
    result['whCode'] = int(soup.find('span', id='advert-info-whCode').text.split(':')[1].strip())
    result['zuletztGeaendert'] = time.mktime(datetime.datetime.strptime(soup.find('span', id='advert-info-dateTime').text.split(':', 1)[1].strip(), "%d.%m.%Y %H:%M").timetuple())
    result['link'] = url

    result.set_index('whCode')

    return result


def getAddUrls(district):
    parameters = urllib.parse.urlencode({'rows': '10000'})

    url = district+'?'+parameters

    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')

    soup.find_all('section', class_='content-section isRealestate')

    return ['https://'+urllib.parse.urlparse(district).netloc+add.find_all('a', href=True)[0]['href'] for add in soup.find_all('section', class_='content-section isRealestate')]


time_start = time.time()
# read config file
with open('config.json') as json_file:
    data = json.load(json_file)

# read previous results
if os.path.isfile(data['config']['scrapfile']):
    results = pd.read_csv(data['config']['scrapfile'])
else:
    results = pd.DataFrame(columns=['link'])
print('Config finished:', time.time()-time_start)

addsFetched = 0
for district in [item for sublist in data['willhaben']['pages'].values() for item in sublist]:
    links = getAddUrls(district)
    for link in links:
        if results['link'].str.contains(link, regex=False).any(): # skip already present adds
            continue
        print(link)
        add = fetchAdd(link)
        results = results.append(add, sort=False)
        addsFetched += 1


print(addsFetched, ' adds finished:', time.time()-time_start)


