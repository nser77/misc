#!/usr/bin/env python3

import sys, shutil, requests, zipfile, json, csv
from subprocess import Popen
from pathlib import Path

############## DEFINITION AREA ##############

def loadConfig(f):
    file=Path(f)

    if not file.exists():
        return False

    jconfig=open(file)
    config=json.load(jconfig)

    return config

def makeDir(path):
    db_dir=Path(path)
    if not db_dir.exists():
        db_dir.mkdir(parents=True)

    return db_dir

def downloadCsvDB(download_key, download_file_name, tmp_dir, extract_dir='database'):
        download_file_suffix='zip'
        download_file_path=tmp_dir / download_file_name
        download_file_url='https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key={}&suffix={}'.format(download_key,download_file_suffix)

        response=requests.get(download_file_url)

        if not response.status_code == 200:
                return False

        if not download_file_path.write_bytes(response.content):
                return False

        with zipfile.ZipFile(download_file_path) as z:
                z.extractall(extract_dir)

        return True

def getDatabaseTree(source):
    db_dirs=[x for x in source.iterdir() if x.is_dir()]
    return db_dirs

def autodiscoveryCsvDB(db_dir,db_file='GeoLite2-Country-Locations-en.csv'):
        geoip_db_dir=getDatabaseTree(db_dir)
        geoip_db_file=Path("{}/{}".format(geoip_db_dir[0],db_file))

        if not geoip_db_file.exists():
                return False

        return geoip_db_file

def cleanDB(list):
    for d in list:
        shutil.rmtree(d)

############## SCRIPT AREA ##############

config=loadConfig('conf.json')
download_file_suffix='zip'
download_file_name=Path('file.{}'.format(download_file_suffix))
commands = []

db_dir=makeDir('./database')
tmp_dir=makeDir('./tmp')

cleanDB(getDatabaseTree(db_dir))

if not downloadCsvDB(config['download_key'],download_file_name,tmp_dir):
    sys.exit(1)
    exit(0)

geoip_index_db=autodiscoveryCsvDB(db_dir)
geoip_ip_db=autodiscoveryCsvDB(db_dir,'GeoLite2-Country-Blocks-IPv4.csv')

if not geoip_ip_db:
    sys.exit(1)
    exit(0)

for country in config['ips_country']:
    country_lower=country.lower()
    country_upper=country.upper()
    address_list='geo-{}'.format(country_lower)

    with geoip_index_db.open() as f:
        index_db=csv.reader(f)
        for r in index_db:
            if country_upper in r[4]:
                if not config['devel']:
                    subprocess="./subprocess.sh {} {} {} {} {}".format(geoip_ip_db, r[0], config['mkt_ip'], address_list, tmp_dir)
                    commands.append(subprocess)
                else:
                    subprocess="./subprocess-test.sh {} {} {} {} {}".format(geoip_ip_db, r[0], config['mkt_ip'], address_list, tmp_dir)
                    commands.append(subprocess)

procs = [ Popen(i, shell=True) for i in commands ]

for p in procs:
    try:
        p.wait()

        if p:
            print("Subprocess success")
        else:
            print("Subprocess error")

    except KeyboardInterrupt:
        print("Keyboard interrupt")
        exit(0)
