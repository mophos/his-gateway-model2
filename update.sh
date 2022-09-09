if ! [ "$(git remote -v)" ]; then
    cd ..
    rm -rf ../his-gateway-no-git
    mv his-gateway-model2 his-gateway-no-git
    git clone https://github.com/mophos/his-gateway-model2.git
    cp -r his-gateway-no-git/cert ./his-gateway-model2/.
    cp -r his-gateway-no-git/data ./his-gateway-model2/.
    cp -r his-gateway-no-git/hisgateway-docker-model2 ./his-gateway-model2/.
    cd his-gateway-model2
fi

./load-cert.sh
if [[ -d './hisgateway-docker-model2' && -f './hisgateway-docker-model2/docker-compose.yml' ]]; then
    git checkout -- .
    version_old=`cat ./script.version`
    git pull
    version_new=`cat ./script.version`
    if  ! [[ $version_old == $version_new ]]; then
        ./run-after-update.sh $version_old
    fi
    cd hisgateway-docker-model2
    docker-compose down
    git checkout -- .
    git pull
    docker pull mophos/hisgateway-client-web
    docker pull mophos/hisgateway-client-api
    docker pull mophos/hisgateway-history-api
    docker-compose up -d
    cd ..
else
    echo 'git clone hisgateway-docker-model2'  
    git clone https://github.com/mophos/hisgateway-docker-model2.git
fi