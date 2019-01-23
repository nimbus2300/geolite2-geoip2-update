# geolite2-geoip2-update

## Overview 

A simple bash script to download GeoLite2 database files from MaxMind and move them into place for Varnish libvmod (fgsch/libvmod-geoip2) to read.

## How the script works

The script is pretty self-contained. It does the following:

1. Makes a staging directory under /tmp
2. Downloads https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
3. Downloads https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
4. Downloads the tarballs, unpacks them, locates the database files, and moves them into place under /usr/share/GeoIP

## Installation instructions

* Put the script somewhere sensible, e.g. /usr/local/bin
* chmod +x /usr/local/bin/updateGeoIp.sh
* Edit your crontab (crontab -e) to have the file downloaded as often as you wish. Once a week is a good frequency.

## Required software

* linux
* bash
* wget
* tar

## Further reading

If like me you're trying to set up your stack so that you feed through source country, these resources might help:

* GeoLite2 databases: https://dev.maxmind.com/geoip/geoip2/geolite2/ 
The GeoLite2 database tells us which country a particular IP address originates from
* Varnish: https://varnish-cache.org/ 
Varnish is a web cache front end. It sits in front of the web server and serves cached pages. 
* libvmod-geoip2: https://github.com/fgsch/libvmod-geoip2 
This is the vmod to build into varnish. This vmod inserts the ISO country code (e.g. 'US') of the HTTP request's IP address. You can then use this in your application. This method is much faster then doing it in the web server or application layer.
* Once you've built the vmod into Varnish, you can edit the /etc/varnish/default.vcl file to `import geoip2;`, determine country, and insert into the headers on the fly.

### Example edit to /etc/varnish/default.vcl


```
sub vcl_init {
    new country = geoip2.geoip2("/usr/share/GeoIP/GeoLite2-Country.mmdb");
}

sub vcl_recv {

    ...

    # pass on country information
    set req.http.X-Client-GeoIP = country.lookup("country/iso_code",
        std.ip(regsub(req.http.X-Real-IP, "[\s,].*", ""),
            client.ip));
            
    ...
}    
```

### Library files to build

The output of building libvmod-geoip2 should be these two files. You need to copy them to your varnish vmod dir:

```
/usr/lib64/varnish/vmods/libvmod_geoip2.la
/usr/lib64/varnish/vmods/libvmod_geoip2.so
```
