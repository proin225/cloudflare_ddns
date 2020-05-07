Email=example@example.com
Global_Api_Key=1234567890123456789012345678901234567
Domain=example.com
A_Record=a.example.com

IP=$(curl -s "https://ipv4.icanhazip.com/")
API="https://api.cloudflare.com/client/v4"

echo $IP

H_Email="-HX-Auth-Email:$Email"
H_Auth_Key="-HX-Auth-Key:$Global_Api_Key"
H_Content="-HContent-Type:application/json"

Account_ID=$(curl -s -X GET "$API/accounts" $H_Email $H_Auth_Key $H_Content \
	| cut -d',' -f1 | sed -e s/'"id":"'/'`'/g | sed -e s/'"'//g | cut -d'`' -f2)
echo $Account_ID

Zone_ID=$(curl -s -X GET "$API/zones?name=$Domain" $H_Email $H_Auth_Key $H_Content \
	| cut -d',' -f1 | sed -e s/'"'//g | cut -d':' -f3)
echo $Zone_ID

Record_ID=$(curl -s -X GET "$API/zones/$Zone_ID/dns_records?type=A&name=$A_Record" \
	$H_Email $H_Auth_Key $H_Content \
	| grep '"id"' | sed -e s/'"id": "'//g | sed -e s/'",'//g | sed s/' '//g)
echo $Record_ID

(curl -X PUT "$API/zones/$Zone_ID/dns_records/$Record_ID" \
	$H_Email $H_Auth_Key $H_Content \
	--data '{"type":"A","name":"'"$A_Record"'","content":"'"$IP"'"}')
