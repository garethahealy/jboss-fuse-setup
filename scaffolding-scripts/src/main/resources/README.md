# Scaffolding Scripts

# How to run
## install-fuse.sh - from Maven Central
cd /tmp &&
    wget https://repo1.maven.org/maven2/com/garethahealy/fuse-setup/scaffolding-scripts/${project.version}/scaffolding-scripts-${project.version}-all.zip &&
    unzip scaffolding-scripts-*-all.zip &&
    cd scripts &&
    chmod -R 755 install-fuse.sh &&
    install-fuse.sh -e local -u fuse

## install-fuse.sh - from Local
cd /tmp &&
    rm -rf scaffolding-scripts.zip scripts/ &&
    wget -O scaffolding-scripts.zip "http://localhost:8081/nexus/service/local/artifact/maven/redirect?g=com.garethahealy.fuse-setup&a=scaffolding-scripts&v=LATEST&p=zip&c=all&r=snapshots" &&
    unzip scaffolding-scripts.zip &&
    cd scripts &&
    chmod -R 755 install-fuse.sh &&
    ./install-fuse.sh -e local -u fuse

## deploy.sh
cd /opt/rh/scripts &&
    ./deploy.sh local fuse

## mvn branch
todo

## post-profile-deploy.sh
cd /opt/rh/scripts &&
    ./post-profile-deploy.sh local 1.2
