#!/usr/bin/env bash

for i in 1 2 3; do sudo /usr/local/bin/aws --region us-east-1 s3 cp s3://avillach-datastage-pic-sure-jenkins-dev-builds-3/releases/jenkins_pipeline_build_${stack_githash}/pic-sure-hpds-copdgene-ui.tar.gz . && break || sleep 30; done
HTTPD_IMAGE=`sudo docker load < pic-sure-hpds-copdgene-ui.tar.gz | cut -d ' ' -f 3`
sudo docker run -v /var/log/httpd-docker-logs/:/usr/local/apache2/logs/ -v /usr/local/docker-config/picsure_settings.json:/usr/local/apache2/htdocs/picsureui/settings/settings.json -v /usr/local/docker-config/psama_settings.json:/usr/local/apache2/htdocs/psamaui/settings/settings.json -v /usr/local/docker-config/:/usr/local/apache2/cert/ -v /usr/local/docker-config/httpd-vhosts.conf:/usr/local/apache2/conf/extra/httpd-vhosts.conf -p 80:80 -p 443:443 -d $HTTPD_IMAGE



#!/bin/bash
if [ $# -eq 3 ]
then
    sudo adduser $1
    if [ $3 -eq 1 ]
    then
        sudo usermod -a -G wheel $1
    fi
    mkdir /home/$1/.ssh
    cat $2 >> /home/$1/.ssh/authorized_keys
    chmod 600 /home/$1/.ssh/authorized_keys
    chmod 700 /home/$1/.ssh
    chown -R $1:$1 /home/$1/
else
    echo "This script requires the username, a path to an ssh public key for the user, and a 1 or 0 which controls if the user has sudo. Please try again."
fi

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9pMXcD3K+PwjppAHV47zUDGqT4yB8EPCZpkO/wxzwlN92jFJYBMs6AAV1Heg0wFQvzI1U2vw4x8TyisL/jfIlAksuKUVBqf2LkWyqbzcbvCpEP4lIbDZCFkRiK323Eenxrakwp9ybeb791avVi6d4VwxOYOC56NF5AwjXjXENqNWnLzbvxN24c9pV6ndeh6VcdoL1b1P2hZ8KT5ZzhI7Bq5rlZss+kqfbJie8IFphuYlOmSqh5CfHV8wYGNk9UFYuvbBTl6Z72rqPzcXkRPsEqaXNKOSWEt+wDs8Y7vBAIYxZCaqYyYDV5m4jp4828ODa32x1df1Osrm0aSkNWNln nchu@nathans-mbp.public.wireless.med.harvard.edu

