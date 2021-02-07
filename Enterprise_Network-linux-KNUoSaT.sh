#!/usr/bin/env bash
if [ -z "$BASH" ] ; then
   bash  $0
   exit
fi



my_name=$0


function setup_environment {
  bf=""
  n=""
  ORGANISATION="[1X-CONFIG #221] Kwame Nkrumah University of Science and Technology"
  URL="your local Enterprise Network support page"
  SUPPORT="your local Enterprise Network support"
if [ ! -z "$DISPLAY" ] ; then
  if which zenity 1>/dev/null 2>&1 ; then
    ZENITY=`which zenity`
  elif which kdialog 1>/dev/null 2>&1 ; then
    KDIALOG=`which kdialog`
  else
    if tty > /dev/null 2>&1 ; then
      if  echo $TERM | grep -E -q "xterm|gnome-terminal|lxterminal"  ; then
        bf="[1m";
        n="[0m";
      fi
    else
      find_xterm
      if [ -n "$XT" ] ; then
        $XT -e $my_name
      fi
    fi
  fi
fi
}

function split_line {
echo $1 | awk  -F '\\\\n' 'END {  for(i=1; i <= NF; i++) print $i }'
}

function find_xterm {
terms="xterm aterm wterm lxterminal rxvt gnome-terminal konsole"
for t in $terms
do
  if which $t > /dev/null 2>&1 ; then
  XT=$t
  break
  fi
done
}


function ask {
     T="1x-config"
#  if ! [ -z "$3" ] ; then
#     T="$T: $3"
#  fi
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "${1}\n${2}?" --title "$T" ; then
       return 0
     else
       return 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     text=`echo "${1}" | fmt -w60`
     if $ZENITY --no-wrap --question --text="${text}\n${2}?" --title="$T" 2>/dev/null ; then
       return 0
     else
       return 1
     fi
  fi

  yes=Y
  no=N
  yes1=`echo $yes | awk '{ print toupper($0) }'`
  no1=`echo $no | awk '{ print toupper($0) }'`

  if [ $3 == "0" ]; then
    def=$yes
  else
    def=$no
  fi

  echo "";
  while true
  do
  split_line "$1"
  read -p "${bf}$2 ${yes}/${no}? [${def}]:$n " answer
  if [ -z "$answer" ] ; then
    answer=${def}
  fi
  answer=`echo $answer | awk '{ print toupper($0) }'`
  case "$answer" in
    ${yes1})
       return 0
       ;;
    ${no1})
       return 1
       ;;
  esac
  done
}

function alert {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --sorry "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --warning --text="$1" 2>/dev/null
     return
  fi
  echo "$1"

}

function show_info {
  if [ ! -z $KDIALOG ] ; then
     $KDIALOG --msgbox "${1}"
     return
  fi
  if [ ! -z $ZENITY ] ; then
     $ZENITY --info --width=500 --text="$1" 2>/dev/null
     return
  fi
  split_line "$1"
}

function confirm_exit {
  if [ ! -z $KDIALOG ] ; then
     if $KDIALOG --yesno "Really quit?"  ; then
     exit 1
     fi
  fi
  if [ ! -z $ZENITY ] ; then
     if $ZENITY --question --text="Really quit?" 2>/dev/null ; then
        exit 1
     fi
  fi
}



function prompt_nonempty_string {
  prompt=$2
  if [ ! -z $ZENITY ] ; then
    if [ $1 -eq 0 ] ; then
     H="--hide-text "
    fi
    if ! [ -z "$3" ] ; then
     D="--entry-text=$3"
    fi
  elif [ ! -z $KDIALOG ] ; then
    if [ $1 -eq 0 ] ; then
     H="--password"
    else
     H="--inputbox"
    fi
  fi


  out_s="";
  if [ ! -z $ZENITY ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$ZENITY --entry --width=300 $H $D --text "$prompt" 2>/dev/null`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done
  elif [ ! -z $KDIALOG ] ; then
    while [ ! "$out_s" ] ; do
      out_s=`$KDIALOG $H "$prompt" "$3"`
      if [ $? -ne 0 ] ; then
        confirm_exit
      fi
    done  
  else
    while [ ! "$out_s" ] ; do
      read -p "${prompt}: " out_s
    done
  fi
  echo "$out_s";
}

function user_cred {
  PASSWORD="a"
  PASSWORD1="b"

  if ! USER_NAME=`prompt_nonempty_string 1 "enter your userid"` ; then
    exit 1
  fi

  while [ "$PASSWORD" != "$PASSWORD1" ]
  do
    if ! PASSWORD=`prompt_nonempty_string 0 "enter your password"` ; then
      exit 1
    fi
    if ! PASSWORD1=`prompt_nonempty_string 0 "repeat your password"` ; then
      exit 1
    fi
    if [ "$PASSWORD" != "$PASSWORD1" ] ; then
      alert "passwords do not match"
    fi
  done
}
setup_environment
show_info "This installer has been prepared for ${ORGANISATION}\n\nMore information and comments:\n\nEMAIL: ${SUPPORT}\nWWW: ${URL}\n\nInstaller created with software from https://1x-config.org."
if ! ask "This installer will only work properly if you are a member of ${bf}[1X-CONFIG #221] Kwame Nkrumah University of Science and Technology.${n}" "Continue" 1 ; then exit; fi
if [ -d $HOME/.cat_installer ] ; then
   if ! ask "Directory $HOME/.cat_installer exists; some of its files may be overwritten." "Continue" 1 ; then exit; fi
else
  mkdir $HOME/.cat_installer
fi
# save certificates
echo "-----BEGIN CERTIFICATE-----
MIIE2zCCA8OgAwIBAgIJAKc9Ygwd+FsGMA0GCSqGSIb3DQEBCwUAMIGQMQswCQYD
VQQGEwJHSDEQMA4GA1UECAwHQXNoYW50aTEPMA0GA1UEBwwGS3VtYXNpMQ4wDAYD
VQQKDAVLTlVTVDEhMB8GCSqGSIb3DQEJARYSYW5zYWhAa251c3QuZWR1LmdoMSsw
KQYDVQQDDCJLTlVTVCBSYWRpdXMgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTE2
MDgyMTIzNTI1MloXDTM2MDgxNjIzNTI1MlowgZAxCzAJBgNVBAYTAkdIMRAwDgYD
VQQIDAdBc2hhbnRpMQ8wDQYDVQQHDAZLdW1hc2kxDjAMBgNVBAoMBUtOVVNUMSEw
HwYJKoZIhvcNAQkBFhJhbnNhaEBrbnVzdC5lZHUuZ2gxKzApBgNVBAMMIktOVVNU
IFJhZGl1cyBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQDVwiRsV/nHmTYMwrsBIxere7XUMYMZ9OQaGtcbouEoOB+f
RCbrmsy456IPJP6yvyMCdJb5XXKPONBZdRmFZkkTphrl26fGs/3puj0Lq67oBpQl
WWt4oYRCqsKCAzXryiXGMClC51twQURqnYNcB42u27sU3ATvmltMFTueRvhevuoN
SVCwEMFJ19aptMbRLTWwrYAYG7RtufVd2nEq5WpkrFVvMyDN18FsI6sVQGtRNiZo
IqJGiszqyYObllIp8RbYNhx7NpG9wsSW2E2h0Dub3/bB8D2TEzlw29x/yI+97THt
lYZsaqG5IUbSQB5aZ0w4SF6OtW/TxCcy8uir0OIDAgMBAAGjggE0MIIBMDAdBgNV
HQ4EFgQUlieLWw7qyIJfIpfjQb5knAdZbCMwgcUGA1UdIwSBvTCBuoAUlieLWw7q
yIJfIpfjQb5knAdZbCOhgZakgZMwgZAxCzAJBgNVBAYTAkdIMRAwDgYDVQQIDAdB
c2hhbnRpMQ8wDQYDVQQHDAZLdW1hc2kxDjAMBgNVBAoMBUtOVVNUMSEwHwYJKoZI
hvcNAQkBFhJhbnNhaEBrbnVzdC5lZHUuZ2gxKzApBgNVBAMMIktOVVNUIFJhZGl1
cyBDZXJ0aWZpY2F0ZSBBdXRob3JpdHmCCQCnPWIMHfhbBjAPBgNVHRMBAf8EBTAD
AQH/MDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly93d3cuZXhhbXBsZS5vcmcvZXhh
bXBsZV9jYS5jcmwwDQYJKoZIhvcNAQELBQADggEBACnWimGSScWSAPFg0dFOSoEo
l2/tdaPyh/0iOZoUfrBJ2LbzH9EcOPQzn+WmljYAg+bCmYZ3su3XZzC/HDanF+ZI
czPSlxFEoIMJTvKnaBs/luFmAP3pIC2DNbmfLgGLaY0duhc5/kHIlozEYy5zgRW2
wZBGPNAfqqE2BQuqY3UFOfpCiTtBxW0UKyNC+arrlE4aQrW8Yz3iridKkHBB2Edk
6w0u7OPNxTTdvtDm/6D9jv3vb4OaNGYJODdRt+CXvn29XN/nkJfQxSnFzRhJpQkM
7h/olZvUk3AMWxK809LKU1EjqZxkN6vzEo16pS/7iLjLC3/ZWLcAUcfm3X/i5sI=
-----END CERTIFICATE-----

" > $HOME/.cat_installer/ca.pem
function run_python_script {
PASSWORD=$( echo "$PASSWORD" | sed "s/'/\\\'/g" )
if python << EEE1 > /dev/null 2>&1
import dbus
EEE1
then
    PYTHON=python
elif python3 << EEE2 > /dev/null 2>&1
import dbus
EEE2
then
    PYTHON=python3
else
    PYTHON=none
    return 1
fi

$PYTHON << EOF > /dev/null 2>&1
#-*- coding: utf-8 -*-
import dbus
import re
import sys
import uuid
import os

class EduroamNMConfigTool:

    def connect_to_NM(self):
        #connect to DBus
        try:
            self.bus = dbus.SystemBus()
        except dbus.exceptions.DBusException:
            print("Can't connect to DBus")
            sys.exit(2)
        #main service name
        self.system_service_name = "org.freedesktop.NetworkManager"
        #check NM version
        self.check_nm_version()
        if self.nm_version == "0.9" or self.nm_version == "1.0":
            self.settings_service_name = self.system_service_name
            self.connection_interface_name = "org.freedesktop.NetworkManager.Settings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManager/Settings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManager.Settings")
        elif self.nm_version == "0.8":
            #self.settings_service_name = "org.freedesktop.NetworkManagerUserSettings"
            self.settings_service_name = "org.freedesktop.NetworkManager"
            self.connection_interface_name = "org.freedesktop.NetworkManagerSettings.Connection"
            #settings proxy
            sysproxy = self.bus.get_object(self.settings_service_name, "/org/freedesktop/NetworkManagerSettings")
            #settings intrface
            self.settings = dbus.Interface(sysproxy, "org.freedesktop.NetworkManagerSettings")
        else:
            print("This Network Manager version is not supported")
            sys.exit(2)

    def check_opts(self):
        self.cacert_file = '${HOME}/.cat_installer/ca.pem'
        self.pfx_file = '${HOME}/.cat_installer/user.p12'
        if not os.path.isfile(self.cacert_file):
            print("Certificate file not found, looks like a CAT error")
            sys.exit(2)

    def check_nm_version(self):
        try:
            proxy = self.bus.get_object(self.system_service_name, "/org/freedesktop/NetworkManager")
            props = dbus.Interface(proxy, "org.freedesktop.DBus.Properties")
            version = props.Get("org.freedesktop.NetworkManager", "Version")
        except dbus.exceptions.DBusException:
            version = "0.8"
        if re.match(r'^1\.', version):
            self.nm_version = "1.0"
            return
        if re.match(r'^0\.9', version):
            self.nm_version = "0.9"
            return
        if re.match(r'^0\.8', version):
            self.nm_version = "0.8"
            return
        else:
            self.nm_version = "Unknown version"
            return

    def byte_to_string(self, barray):
        return "".join([chr(x) for x in barray])


    def delete_existing_connections(self, ssid):
        "checks and deletes earlier connections"
        try:
            conns = self.settings.ListConnections()
        except dbus.exceptions.DBusException:
            print("DBus connection problem, a sudo might help")
            exit(3)
        for each in conns:
            con_proxy = self.bus.get_object(self.system_service_name, each)
            connection = dbus.Interface(con_proxy, "org.freedesktop.NetworkManager.Settings.Connection")
            try:
               connection_settings = connection.GetSettings()
               if connection_settings['connection']['type'] == '802-11-wireless':
                   conn_ssid = self.byte_to_string(connection_settings['802-11-wireless']['ssid'])
                   if conn_ssid == ssid:
                       connection.Delete()
            except dbus.exceptions.DBusException:
               pass

    def add_connection(self,ssid):
        server_alt_subject_name_list = dbus.Array({'DNS:KNUST Radius Certificate Authority'})
        server_name = 'KNUST Radius Certificate Authority'
        if self.nm_version == "0.9" or self.nm_version == "1.0":
             match_key = 'altsubject-matches'
             match_value = server_alt_subject_name_list
        else:
             match_key = 'subject-match'
             match_value = server_name
            
        s_con = dbus.Dictionary({
            'type': '802-11-wireless',
            'uuid': str(uuid.uuid4()),
            'permissions': ['user:$USER'],
            'id': ssid 
        })
        s_wifi = dbus.Dictionary({
            'ssid': dbus.ByteArray(ssid.encode('utf8')),
            'security': '802-11-wireless-security'
        })
        s_wsec = dbus.Dictionary({
            'key-mgmt': 'wpa-eap',
            'proto': ['rsn',],
            'pairwise': ['ccmp',],
            'group': ['ccmp', 'tkip']
        })
        s_8021x = dbus.Dictionary({
            'eap': ['ttls'],
            'identity': '$USER_NAME',
            'ca-cert': dbus.ByteArray("file://{0}\0".format(self.cacert_file).encode('utf8')),
             match_key: match_value,
            'password': '$PASSWORD',
            'phase2-auth': 'pap',
        })
        s_ip4 = dbus.Dictionary({'method': 'auto'})
        s_ip6 = dbus.Dictionary({'method': 'auto'})
        con = dbus.Dictionary({
            'connection': s_con,
            '802-11-wireless': s_wifi,
            '802-11-wireless-security': s_wsec,
            '802-1x': s_8021x,
            'ipv4': s_ip4,
            'ipv6': s_ip6
        })
        self.settings.AddConnection(con)

    def main(self):
        self.check_opts()
        ver = self.connect_to_NM()
        self.delete_existing_connections('KNUST WIFI+')
        self.add_connection('KNUST WIFI+')

if __name__ == "__main__":
    ENMCT = EduroamNMConfigTool()
    ENMCT.main()
EOF
}
function create_wpa_conf {
cat << EOFW >> $HOME/.cat_installer/cat_installer.conf

network={
  ssid="KNUST WIFI+"
  key_mgmt=WPA-EAP
  pairwise=CCMP
  group=CCMP TKIP
  eap=TTLS
  ca_cert="${HOME}/.cat_installer/ca.pem"
  identity="${USER_NAME}"
  domain_suffix_match="KNUST Radius Certificate Authority"
  phase2="auth=PAP"
  password="${PASSWORD}"
}
EOFW
chmod 600 $HOME/.cat_installer/cat_installer.conf
}
#prompt user for credentials
  user_cred
  if run_python_script ; then
   show_info "Installation successful"
else
   show_info "Network Manager configuration failed, generating wpa_supplicant.conf"
   if ! ask "Network Manager configuration failed, but we may generate a wpa_supplicant configuration file if you wish. Be warned that your connection password will be saved in this file as clear text." "Write the file" 1 ; then exit ; fi

if [ -f $HOME/.cat_installer/cat_installer.conf ] ; then
  if ! ask "File $HOME/.cat_installer/cat_installer.conf exists; it will be overwritten." "Continue" 1 ; then confirm_exit; fi
  rm $HOME/.cat_installer/cat_installer.conf
  fi
   create_wpa_conf
   show_info "Output written to $HOME/.cat_installer/cat_installer.conf"
fi
