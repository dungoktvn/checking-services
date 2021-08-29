## athena.env file location
filepath="/opt/athena/env/athena.env"
## Getting arguments from command
while getopts i:n: flag
do
    case "${flag}" in
        i) tenant_id=${OPTARG};;
        n) nos_host=${OPTARG};;
    esac
done

#Checking for Tenant ID and NOS Host IP
if [ $tenant_id != "" ] ; then
    check_tenant=$(cat $filepath | grep -w "TENANT_ID=$tenant_id");
    if [ -z "$check_tenant" ] ; then echo "Tenant ID is INCORRECTED. Tenant ID is now set as $(cat $filepath | grep 'TENANT_ID'). Please check"; else echo "Tenant ID: $tenant_id <<Corrected>>"; fi
fi

if [ $nos_host != "" ] ; then
    check_nos=$(cat $filepath | grep -w "NOS_HOST=$nos_host");
    if [ -z "$check_nos" ] ; then echo "NOS_HOST is INCORRECTED. NOS_HOST is now set as $(cat $filepath | grep NOS_HOST). Please check"; else echo "NOS_HOST: $nos_host <<Corrected>>"; fi
fi

## Checking services status
srv_name=(gateway middle backend geocodeservice importservice plannedrollover reportsserver aggregateservice rres overlay command-distributor geocalculation ivin timeattendance)

for y in "${srv_name[@]}"; do
    if [ $(sudo systemctl is-active $y) == "active" ] ; then
        echo "$y service: $(sudo systemctl status $y | grep -e 'Active: active (running)')"
    else
        echo "$y is INACTIVE"
    fi
done

echo "geoserver service: $(docker ps | grep geoserver)"

#function to check Telnet from BE to WOSNOS

function check_telnet ()
{
    host_ip=$1
    host_port=$2

    telnet_check=$(timeout 2 telnet $1 $2)
    if [ "$telnet_check" != "" ] ; then
        echo "Telnet to $1 $2 SUCCESSFULLY"
    else
        echo "Telnet to $1 $2 UNSUCCESSFULLY"
    fi

}

echo ""
check_telnet $nos_host 8801
check_telnet $nos_host 8901

#function to format result from ps commnad
function check_ps () 
{
    arr=()
    #b=$(cat $1)
    b=$(ps aux | grep $1 | grep -v grep | grep -v sudo)
    #echo $b
    regex='^-'
    prefix="-D"
    for word in $b
    do
        if [[ $word =~ $regex ]]; then
            arr+=("${word#"$prefix"}")
        fi
    done
    for value in "${arr[@]}"
    do
        echo $value
    done
}

#Run ps command for services to get its parameters
ser_name=(Transaction Routing GeoCodeService ImportService PlannedRollover Reports Aggregate RideRegis Overlay Command GeoCal DriverTime Special)

for i in "${ser_name[@]}"; do
    echo ""
    echo ">>> $i <<<"
    check_ps $i
done