#!/bin/bash

set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# Connectivity tools
sudo yum install -y pssh rsync

# Dev tools
sudo yum install -y gcc gcc-c++ ant git

# Install java-8 for Spark 2.2.x
sudo yum install -y java-1.8.0 java-1.8.0-devel
sudo yum --enablerepo='*-debug*' install -y java-1.8.0-openjdk-debuginfo
sudo yum remove -y  java-1.7.0
sudo /usr/sbin/alternatives --auto java
sudo /usr/sbin/alternatives --auto javac

# Perf tools
sudo yum install -y dstat iotop strace sysstat htop perf
sudo debuginfo-install -y glibc
sudo debuginfo-install -y kernel

# PySpark and MLlib deps
sudo yum install -y python-matplotlib python-tornado scipy libgfortran
# SparkR deps
sudo yum install -y R
# Ganglia
sudo yum install -y ganglia ganglia-web ganglia-gmond ganglia-gmetad

# Install Maven
cd /tmp
wget "http://archive.apache.org/dist/maven/maven-3/3.2.3/binaries/apache-maven-3.2.3-bin.tar.gz"
tar xvzf apache-maven-3.2.3-bin.tar.gz
mv apache-maven-3.2.3 /opt/

# Edit bash profile
echo "export PS1=\"\\u@\\h \\W]\\$ \"" >> ~/.bash_profile
echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0" >> ~/.bash_profile
echo "export M2_HOME=/opt/apache-maven-3.2.3" >> ~/.bash_profile
echo "export PATH=\$PATH:\$M2_HOME/bin" >> ~/.bash_profile

source ~/.bash_profile

# Create /usr/bin/realpath which is used by R to find Java installations
# NOTE: /usr/bin/realpath is missing in CentOS AMIs. See
# http://superuser.com/questions/771104/usr-bin-realpath-not-found-in-centos-6-5
echo '#!/bin/bash' > /usr/bin/realpath
echo 'readlink -e "$@"' >> /usr/bin/realpath
chmod a+x /usr/bin/realpath
