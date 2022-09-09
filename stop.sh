if [  "$(docker ps -a)" ]; then
  if [[ -d "./hisgateway-docker-model2" && -f "./hisgateway-docker-model2/.env"  ]]; then
        cd hisgateway-docker-model2
        docker-compose down
  else
    echo 'Please confit ENV  ./set-env.sh'
  fi
else
  echo 'Please Start docker'
fi