echo 'Start Download Certificate...'
if [[ -d "./hisgateway-docker"  &&  -f "./hisgateway-docker/.env" ]]; then
  if  [ "$(uname -a | grep el7)" ]; then
     if ! [ -x "$(command -v curl)" ]; then 
      yum install curl -y
    fi

    if ! [ -x "$(command -v unzip)" ]; then 
      yum install unzip -y
    fi
  else
    if ! [ -x "$(command -v curl)" ]; then 
      apt-get install curl
    fi

    if ! [ -x "$(command -v unzip)" ]; then 
      apt-get install unzip
    fi
  fi
 

  set -o allexport; source "./hisgateway-docker/.env"; set +o allexport
  if [ -f "./cert/version" ]; then
      version=`cat ./cert/version`
      loadtype="1"
      response_check_v=$(curl --request POST \
      --silent -d \
      --url https://hisgateway.moph.go.th/api/sh/cert/check \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data hospcode=${HOSPCODE} \
      --data version=${version}
      )
    else
    loadtype="2"
    response_check_v=$(curl --request GET \
      --silent -d \
      --url https://hisgateway.moph.go.th/api/cert/check \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data hospcode=${HOSPCODE}
    )
    fi

    check_v=$( echo $response_check_v | python -c "import sys, json; print json.load(sys.stdin)['ok']")
    if [ $check_v == 'True' ]; then
      if [ $loadtype == '1' ]; then
        echo "Certificate New Version."
      fi

      check_file=$( echo $response_check_v | python -c "import sys, json; print json.load(sys.stdin)['ok']")

      if [ $check_file == 'True' ]; then
          echo "Download certificate..."
          read -p "E-mail ict portal ($EMAIL_ICTPORTAL): " email
          read -s -p "Password ict portal : " password
          email="${email:=`echo $EMAIL_ICTPORTAL`}"
          response=$(curl --request POST \
          --silent -d \
          --url https://hisgateway.moph.go.th/api/login \
          --header 'Content-Type: application/x-www-form-urlencoded' \
          --data username=${email} \
          --data password=${password}
        )
        checkLogin=$( echo $response | python -c "import sys, json; print json.load(sys.stdin)['ok']")
        if [ $checkLogin == 'True' ]; then
          token=$( echo $response | python -c "import sys, json; print json.load(sys.stdin)['token']")
          curl --request GET \
          --url https://hisgateway.moph.go.th/api/api/cert \
          --header 'Content-Type: application/x-www-form-urlencoded' \
          --data token=${token} -o cert.zip
          if ! [ -d "./cert" ]; then
          mkdir cert 
          fi
          rm -rf cert/*
          unzip cert.zip -d cert/
          rm -rf cert.zip
          password=`cat cert/password*`
          sed -i -e "s/PASSWORD=.*/PASSWORD=$password/g" "./hisgateway-docker/.env"
        else
          echo '######################';
          echo 'Login failed';
          echo '######################';
          exit 1
        fi 
      else 
          echo "Certificate not found contact ADMIN"
      fi
    else
      echo "Certificate not found new version."
    fi
else 
  echo './install.sh or ./set-env.sh'
fi
