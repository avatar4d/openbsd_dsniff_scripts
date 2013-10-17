openbsd_dsniff_scripts
======================
OpenBSD dsniff agent rc scripts

This is a script that will startup, shutdown, and restart dsniff, mailsnarf, msgsnarf and urlsnarf listening agents on OpenBSD routers/firewalls. It also logs their output and rotates the files  when they reach 50MB.


NOTE: This will add significant CPU overhead so be careful when/where you run this. For instance, while saturating a 100Mbit link to approximately 50% will produce a CPU load average of about 2 on an embedded device.


By default it logs to /var/log/dsniff/$APPNAME


Usage:

        sudo su -
        mkdir ~/bin
        cd ~/bin
        git clone git://github.com/avatar4d/openbsd_dsniff_scripts.git
        crontab -e


Then add the following:

        0       0       *       *       *       /root/bin/openbsd_dsniff_scripts/sniffer_agents.sh

Then edit the rc.local script:

        vi /etc/rc.local

Then add the following:

       ## start dsniff daemons
       if [ -x /root/bin/openbsd_dsniff_scripts/sniffer_agents.sh ]; then
            echo 'dsniff daemons'
            /root/bin/openbsd_dsniff_scripts/sniffer_agents.sh
       fi

