#!/bin/bash

# print commands and arguments as they are executed
set -x

echo "starting ubuntu devbox install on pid $$"
date
ps axjf

#############
# Parameters
#############

AZUREUSER=$1
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

###################
# Common Functions
###################

ensureAzureNetwork()
{
  # ensure the host name is resolvable
  hostResolveHealthy=1
  for i in {1..120}; do
    host $VMNAME
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      hostResolveHealthy=0
      echo "the host name resolves"
      break
    fi
    sleep 1
  done
  if [ $hostResolveHealthy -ne 0 ]
  then
    echo "host name does not resolve, aborting install"
    exit 1
  fi

  # ensure the network works
  networkHealthy=1
  for i in {1..12}; do
    wget -O/dev/null http://bing.com
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 10
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork

###################################################
# Update Ubuntu and install all necessary binaries
###################################################

time sudo apt-get -y update
# kill the waagent and uninstall, otherwise, adding the desktop will do this and kill this script
sudo pkill waagent
time sudo apt-get -y remove walinuxagent
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install ubuntu-desktop firefox vnc4server ntp nodejs npm expect gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal gnome-core

#########################################
# Setup Azure User Account including VNC
#########################################
sudo -i -u $AZUREUSER mkdir $HOMEDIR/bin
sudo -i -u $AZUREUSER touch $HOMEDIR/bin/startvnc
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/bin/startvnc
sudo -i -u $AZUREUSER touch $HOMEDIR/bin/stopvnc
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/bin/stopvnc
echo "vncserver -geometry 1280x1024 -depth 16" | sudo tee $HOMEDIR/bin/startvnc
echo "vncserver -kill :1" | sudo tee $HOMEDIR/bin/stopvnc
echo "export PATH=\$PATH:~/bin" | sudo tee -a $HOMEDIR/.bashrc

prog=/usr/bin/vncpasswd
mypass="password"

sudo -i -u $AZUREUSER /usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF

sudo -i -u $AZUREUSER startvnc
sudo -i -u $AZUREUSER stopvnc

echo "#!/bin/sh" | sudo tee $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "export XKL_XMODMAP_DISABLE=1" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "unset SESSION_MANAGER" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "unset DBUS_SESSION_BUS_ADDRESS" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "xsetroot -solid grey" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "vncconfig -iconic &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-panel &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-settings-daemon &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "metacity &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "nautilus &" | sudo tee -a $HOMEDIR/.vnc/xstartup
echo "gnome-terminal &" | sudo tee -a $HOMEDIR/.vnc/xstartup

sudo -i -u $AZUREUSER $HOMEDIR/bin/startvnc

#####################
# setup the Azure CLI
#####################
time sudo npm install azure-cli -g
time sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Chrome
####################
cd /tmp
time wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
time sudo apt-get -y --force-yes install -f
time rm /tmp/google-chrome-stable_current_amd64.deb
date
echo "completed ubuntu devbox install on pid $$"


#########################################
# Setup Mavin Splash Page
#########################################
#Update Apt Get Packages
sudo apt-get update

#Create mavin splash folder
sudo -i -u $AZUREUSER mkdir $HOMEDIR/Desktop/mavin-splash

#Create mavin splash index page
sudo -i -u $AZUREUSER touch $HOMEDIR/Desktop/mavin-splash/index.html
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/Desktop/mavin-splash/index.html

#Create the index.js page for routes
sudo -i -u $AZUREUSER touch $HOMEDIR/Desktop/mavin-splash/index.js
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/Desktop/mavin-splash/index.js

#Create the app.js page
sudo -i -u $AZUREUSER touch $HOMEDIR/Desktop/mavin-splash/app.js
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/Desktop/mavin-splash/app.js

#Create the package.json page
sudo -i -u $AZUREUSER touch $HOMEDIR/Desktop/mavin-splash/package.json
sudo -i -u $AZUREUSER chmod 755 $HOMEDIR/Desktop/mavin-splash/package.json

#write to mavin splash index page
cat <<-EOF1 > $HOMEDIR/Desktop/mavin-splash/index.html

    <!DOCTYPE html>
    <html>

        <head>
            <title>Mavin Business</title>
            <!--Bootstrap CSS-->
            <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
            <!-- Bootstrap JavaScript-->
            <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
            <!--Web Font-->
            <script src="//ajax.googleapis.com/ajax/libs/webfont/1.5.18/webfont.js"></script>

            <!-- lazy load webfonts -->
            <script type="text/javascript">
                var data = {"provider":{"google":{"families":["Open Sans:300","Open Sans:300italic","Open Sans:400","Open Sans:400italic","Open Sans:600","Open Sans:700","Open Sans:800","Lato:","Lato:","Lato:"]}}} ;
            for (p in data.provider) {
                if (p == 'google') {
                    var request = {
                        'google': data.provider[p]
                    };
                    WebFont.load(request);
                } else if (p == 'typekit' || p == 'fontkit') {
                    for(id in data.provider[p].id) {
                        var token = data.provider[p].id[id];
                        var request = {
                            [p] : { id: token }
                        };
                        WebFont.load(request);
                    }
                }
            }
            </script>
            <style>
                html{
                    width:100%;
                    height:100%;
                }
                .contact-us-background {
                    background-color:#0099ff;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    font-family: 'Open Sans', sans-serif;
                    font-size: 1.3em;
                }
                .contact-us-login-container{
                    position: relative;
                    min-height: 100%;
                    width: 100%;
                }
                .contact-us-login-card{
                    text-align: center;
                    width: 350px;
                    padding-top: 35px;
                    height: 250px;
                    margin: 0px auto;
                    position: absolute;
                    left: 0;
                    right: 0;
                }
                .card-white{
                    background-color: rgb(255,255,255);
                    box-shadow: 0 1px 3px 0 rgba(0,0,0,.2),0 1px 1px 0 rgba(0,0,0,.14),0 2px 1px -1px rgba(0,0,0,.12);
                    padding: 15px;
                }
                .contact-us-header{
                    color:#0099ff;
                }
                .vertical-center{
                    top: 50%;
                    transform: translateY(-50%);
                    -webkit-transform: translateY(-50%);
                }
                .mt25{
                    margin-top:25px;
                }
            </style>
        </head>
        <body class="contact-us-background">
            <div class="contact-us-login-container container">
                <div class="contact-us-login-card vertical-center card-white">
                    <div class="contact-us-logos">
                        <div class="col-xs-6">
                            <div class="contact-us-logo contact-us-tyrospot-logo">
                            </div>
                        </div>
                        <div class="col-xs-6">
                            <div class="contact-us-logo contact-us-hello-mavin-logo">
                            </div>
                        </div>
                    </div>
                    <h3 class="contact-us-header">Mavin Business</h3>
                    <p>Thank you for downloading Mavin Business!</p>
                    <p>Contact us at <a href="mailto:contactus@mavinglobal.com">contactus@mavinglobal.com</a> to get started.</p>
                </div>
            </div>
            </div>
        </body>

    </html>
EOF1

#Write to the index.js page
cat <<-EOF2 > $HOMEDIR/Desktop/mavin-splash/index.js

    var express = require('express');
    var router = express.Router();

    /* GET login page. */
    router.all("/*", function (req, res) {

        res.sendFile("index.html", { root: './' });
    });
    module.exports = router;

EOF2


#Write to the app.js page
cat <<-EOF3 > $HOMEDIR/Desktop/mavin-splash/app.js

    //Require dependencies
    var express = require('express');

    var app = express();

    //App Routes
    var routes = require('./index');

    //Set index route
    app.use('/', routes);

    app.set('port', 3000);

    var server = app.listen(app.get('port'), function() {
        console.log('Express server listening on port ' + server.address().port);
    });
EOF3

#write to the package.json page
cat <<-EOF4 > $HOMEDIR/Desktop/mavin-splash/package.json

    {
    "name": "mavinbusiness",
    "version": "0.0.0",
    "private": true,
    "scripts": {
        "start": "node app.js"
    },
    "description": "MavinBusiness",
    "author": "MavinGlobal",
    "dependencies": {
        "express": "^4.9.8",
        "http": "0.0.0",
        "https": "^1.0.0"
    },
    "main": "app.js",
    "devDependencies": {}
    }

EOF4

#Download forever using npm
sudo npm install forever -g --save

#Set up iptables rerouting
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 3000
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 3001

#Save iptables save
sudo iptables-save

#Navigate to Mavin splash directory
cd $HOMEDIR/Desktop/mavin-splash

#Download the node packages from the package.json file
npm install

#Run the mavin splash page
forever start app.js
