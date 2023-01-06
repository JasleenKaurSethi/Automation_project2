CRON_FILE="/etc/cron.d/automation"
if [ ! -f $CRON_FILE ]
then
        echo "cron file for root doesnot exist, creating.."
        touch $CRON_FILE
        echo "* * * * * root /root/Automation_Project/automation.sh" >> $CRON_FILE
	chmod 600 /etc/cron.d/automation
fi
s3_bucket="task2-s3bucket"
echo $s3_bucket
apt-get update -y
dpkg --get-selections | grep apache
if [ $? -eq 0 ]
        then
                echo "Apache2 is already installed"
        else
                echo "Installing Apache Server..."
                apt-get install apache2
fi
sudo systemctl status apache2
if [ $? -ne 0 ]
then
        sudo service apache2 start
else
        echo "Apache2 service running"
fi
timestamp=$(date '+%d%m%Y-%H%M%S')
name="Jasleen"
tar_file_name="$name-httpd-logs-$timestamp"
echo $tar_file_name
tar -zcvf $tar_file_name.tar.gz /var/log/apache2/*.log
cp $tar_file_name.tar.gz /tmp
aws s3 cp /tmp/$tar_file_name.tar.gz s3://$s3_bucket/$tar_file_name.tar.gz
if [ -e /var/www/html/inventory.html ]
then
        continue
else
        touch /var/www/html/inventory.html
        echo "inventory.html created"
        echo "Log Type                  Time Created            Type            Size" >> /var/www/html/inventory.html
fi
Log_Type="httpd-logs"
Type="tar"
Size=`du -sh $tar_file_name.tar.gz | awk '{print $1}'`
echo "$Log_Type         $timestamp              $Type           $Size" >> /var/www/html/inventory.html

