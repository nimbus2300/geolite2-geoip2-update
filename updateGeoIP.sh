#!/bin/bash

# Helper script to download GeoLite2-City.mmdb and GeoLite2-Country.mmdb databases and move them into place.
# Can be added to cron (crontab -e) to  refresh periodically.

main () {
    rm -rf ${ASSEMBLE_DIRECTORY} || fail "Couldn't tidy previous run of $0";
    mkdir ${ASSEMBLE_DIRECTORY} || fail "Couldn't create ${ASSEMBLE_DIRECTORY}";
    cd ${ASSEMBLE_DIRECTORY} || fail "Couldn't change to directory ${ASSEMBLE_DIRECTORY}";
    wget https://geolite.maxmind.com/download/geoip/database/${COUNTRY_TAR} || fail "Couldn't download ${COUNTRY_TAR}!";
    wget https://geolite.maxmind.com/download/geoip/database/${CITY_TAR} || fail "Couldn't download ${CITY_TAR}!";
    tar -xzvf ${COUNTRY_TAR} || fail "Couldn't extract ${COUNTRY_TAR}!";
    tar -xzvf ${CITY_TAR} || fail "Couldn't extract ${CITY_TAR}!";
    find . -type f -iname ${COUNTRY_DB} | xargs -I {} mv {} ${TARGET_DIRECTORY} || fail "Couldn't move ${COUNTRY_DB} into place";
    find . -type f -iname ${CITY_DB} | xargs -I {} mv {} ${TARGET_DIRECTORY} || fail "Couldn't move ${CITY_DB} into place";
    echo "Done. Succefullly updated contents of ${TARGET_DIRECTORY} (note - timestamps will only update when MaxMind releases a new DB):";
    RESULT=`ls -l ${TARGET_DIRECTORY}`;
    echo "$RESULT";
    exit 0;
}

COUNTRY_TAR=GeoLite2-Country.tar.gz
COUNTRY_DB=GeoLite2-Country.mmdb

CITY_TAR=GeoLite2-City.tar.gz
CITY_DB=GeoLite2-City.mmdb

ASSEMBLE_DIRECTORY=/tmp/geoip;
TARGET_DIRECTORY=/usr/share/GeoIP;

fail () {
    echo "Error: $1";
    exit 1;
}

main;
