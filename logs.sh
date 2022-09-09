if [ -z "$1" ]; then
    echo "Argument <minifi|api|nginx> is required!!!"
    exit 1
fi

MODE=$1

if [[ $MODE =~ ^(minifi)$ ]]; 
then
     docker logs minifi -f --tail 100
fi
if [[ $MODE =~ ^(api)$ ]]; 
then
     docker logs hisgateway-api -f --tail 100
fi
if [[ $MODE =~ ^(nginx)$ ]]; 
then
     docker logs nginx -f --tail 100
fi
