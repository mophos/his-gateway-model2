option=$1
if [[ $option =~ ^(help)$ || $option =~ ^(--help)$ ]]; then
    echo "## Set config HIS-Gateway ##"
    echo
    echo "usage: ./set-env.sh [--help] [--show] [--force]"
    echo
    echo -e "help\t list about concept guides"
    echo -e "show\t show config"
    echo -e "force\t force set config"
    exit 1
fi

if [[ $option =~ ^(show)$ || $option =~ ^(--show)$ ]]; then
    if [ -f "./hisgateway-docker-model2/.env" ]; then
        cat ./hisgateway-docker-model2/.env
    else
        echo "No set config.Please ./set-env.sh"
    fi
    exit 1
fi

if ! [ -d "./hisgateway-docker-model2" ]; then
    git clone https://github.com/mophos/hisgateway-docker-model2.git
fi
if ! [ -f "./hisgateway-docker-model2/.env" ] || [[ $option =~ ^(set)$ ]] || [[ $option =~ ^(--force)$ ]]; then
    if [ -f "./hisgateway-docker-model2/.env" ]; then
        hospcode=$(sed '/^HOSPCODE=/!d;' hisgateway-docker-model2/.env | awk -F '=' '{print $2}')
        port=$(sed '/^PORT=/!d;' hisgateway-docker-model2/.env | awk -F '=' '{print $2}')
        secretkey=$(sed '/^SECRET_KEY=/!d;' hisgateway-docker-model2/.env | awk -F '=' '{print $2}')
        email=$(sed '/^EMAIL_ICTPORTAL=/!d;' hisgateway-docker-model2/.env | awk -F '=' '{print $2}')
        password=$(sed '/^PASSWORD=/!d;' hisgateway-docker-model2/.env | awk -F '=' '{print $2}')

    else
        hospcode="12345"
        port="80"
        secretkey="$(
            echo $(date +%s) | md5sum | head -c 20
            echo
        )"
        email=""
        password=""
    fi
    echo 'Config..'
    echo 'รหัสโรงพยาบาล'
    read -p "HOSPCODE (defalut: $hospcode): " HOSPCODE
    # echo 'รหัสของ cert (ในไฟล์ password_xxxxx.txt)'
    # read -p 'PASSWORD: ' PASSWORD
    echo 'ตั้งค่า port ที่จะเปิดเว็บ'
    read -p "PORT (defalut: $port): " PORT
    echo 'ตั้งค่า SECRET_KEY เป็นอะไรก็ได้ (ex. 123456)'
    read -p "SECRET_KEY (defalut: $secretkey): " SECRET_KEY
    
    read -p "E-mail ict portal: (defalut: $email)" EMAIL_ICTPORTAL
    # echo 'ตั้งค่า Password ict portal'
    # read -p 'Password: ' PASSWORD_ICTPORTAL

    HOSPCODE="${HOSPCODE:=$(echo $hospcode)}"
    PORT="${PORT:=$(echo $port)}"
    SECRET_KEY="${SECRET_KEY:=$(echo $secretkey)}"
    EMAIL_ICTPORTAL="${EMAIL_ICTPORTAL:=$(echo $email)}"

    cat <<EOF >./hisgateway-docker-model2/.env

PORT=${PORT}
HOSPCODE=${HOSPCODE}
SECRET_KEY=${SECRET_KEY}
BROKER_URL=kafka1.moph.go.th:19093
PATH_DNS=/etc/resolv.conf
DATA_PATH=./data
CONFIG_PATH=./data/conf

EOF
    echo
# echo "Please Open firewall for open website."
# echo;
# echo "Ex. \tfirewall-cmd --permanent --add-port=${PORT}/tcp"
# echo "\tfirewall-cmd --reload"
else
    echo 'Set new ENV type "./set-env.sh --force"'
fi
