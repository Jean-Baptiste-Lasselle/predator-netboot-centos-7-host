#!/bin/bash

# --
# ¤ Compatibility list
# --
# + Centos 7
# ----------------------
# 
# 
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							ENV								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------
# - Logging des opérations
# ---------------------------------------
export NOMFICHIERLOG="$(pwd)/provision-systeme-kytes.log"
rm -f $NOMFICHIERLOG
touch $NOMFICHIERLOG

export PROVISIONING_USER=$USER
export PROVISIONING_USER_GRP=$GROUP

export CENTRALIZED_ID_MGMT_USERNAME=jlasselle
export CENTRALIZED_ID_MGMT_PWD=nimportequoi
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							FONCTIONS						##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de modifier les configurations réseau pour 
# que les interfaces réseau Linux soient configurées en DHCP, démarrent
# au boot.
# --------------------------------------------------------------------------------------------------------------------------------------------
reconfigurer_interfaces_reseau () {
# --------------------------------------------------------------------------------------------------------------------------------------------
# ADRESSE_SERVEUR_DHCP=
# sudo sed -i 's/ONBOOT="yes"/ONBOOT="no"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s*
# 
# --------------------------------------------------------------------------------------------------------------------------------------------
for fichierconf in $(ls /etc/sysconfig/network-scripts/ifcfg-enp0s*)
do
	sudo sed -i 's/ONBOOT=no/ONBOOT=yes/g' $fichierconf
done

}

configurerPROXY () {
# 
# --- ----------------------------------------------------------------------------------------------------------------------------------------
# ---
# --- > Configuration à appliquer au global:
# --- 
# --- 
# ---			------------------------------>>>>>>>>>>>>>>>>>>>>>>         /etc/environment
# ---
# ---
# http_proxy="http://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/"
# https_proxy="https://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/"
# ftp_proxy="ftp://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/"
# no_proxy="*.sopragroup.com|*.sopra|localhost|127.0.0.1|*esante.usine.logicielle"
# 
# no_proxy=".mylan.local,.domain1.com,host1,host2"
#
export FICHIER_CONF_ENV_TEMP=./etc.environment

touch $FICHIER_CONF_ENV_TEMP
echo "http_proxy=http://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/" >> $FICHIER_CONF_ENV_TEMP
echo "https_proxy=https://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/" >> $FICHIER_CONF_ENV_TEMP
echo "ftp_proxy=ftp://$CENTRALIZED_ID_MGMT_USERNAME:$CENTRALIZED_ID_MGMT_PWD@manh.proxy.corp.sopra:8080/" >> $FICHIER_CONF_ENV_TEMP
echo "no_proxy=*.sopragroup.com|*.sopra|localhost|127.0.0.1|*esante.usine.logicielle" >> $FICHIER_CONF_ENV_TEMP
sudo cp $FICHIER_CONF_ENV_TEMP /etc/environment

# et je redonne les droits "normaux" au nouveau fichier de conf
sudo chown -R root:root /etc/environment
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   /etc/environment
# pour ne mette que les exacts droits tels qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   /etc/environment
sudo chmod g+r   /etc/environment
sudo rm -f $FICHIER_CONF_ENV_TEMP


# 
# --- ----------------------------------------------------------------------------------------------------------------------------------------
# ---
# --- > Configuration à appliquer dans
# ---			------------------------------>>>>>>>>>>>>>>>>>>>>>>          /etc/yum.conf:
# ---
# ---
# --- ----------------------------------------------------------------------------------------------------------------------------------------
export FICHIERCONFRESEAUTEMP=./recup.etc.yum.conf
export FICHIER_CONF_INTERF_RESEAU=/etc/yum.conf

sudo cp -f $FICHIER_CONF_INTERF_RESEAU $FICHIERCONFRESEAUTEMP
# -
sudo chmod a-r-w-x   $FICHIERCONFRESEAUTEMP
# # - pour que le user de provisioning ait les droits en écriture et lecture sur ce fichier temporaire
sudo chmod u+r+w   $FICHIERCONFRESEAUTEMP
sudo chmod g+r   $FICHIERCONFRESEAUTEMP
# -
sudo chown -R $USER:$USERGROUP $FICHIERCONFRESEAUTEMP
echo "# The SOPRA proxy emmerding centos" >> $FICHIERCONFRESEAUTEMP
echo "proxy=http://manh.proxy.corp.sopra:8080" >> $FICHIERCONFRESEAUTEMP
echo "# But yes, I speak French" >> $FICHIERCONFRESEAUTEMP
echo "proxy_username=$CENTRALIZED_ID_MGMT_USERNAME" >> $FICHIERCONFRESEAUTEMP
echo "proxy_password=$CENTRALIZED_ID_MGMT_PWD" >> $FICHIERCONFRESEAUTEMP

sudo rm -f $FICHIER_CONF_INTERF_RESEAU
sudo cp -f $FICHIERCONFRESEAUTEMP $FICHIER_CONF_INTERF_RESEAU
sudo rm -f $FICHIERCONFRESEAUTEMP

# et je redonne les droits "normaux" au nouveua fichier de conf
sudo chown -R root:root $FICHIER_CONF_INTERF_RESEAU
# on enlève tous les droits à tout le monde
sudo chmod a-r-w-x   $FICHIER_CONF_INTERF_RESEAU
# pour ne mette que les exacts droits tels qu'ils sont au commissionning d'un CentOS 7
sudo chmod u+r+w   $FICHIER_CONF_INTERF_RESEAU
sudo chmod g+r   $FICHIER_CONF_INTERF_RESEAU

# proxy=http://manh.proxy.corp.sopra:8080
# proxy_username=$CENTRALIZED_ID_MGMT_USERNAME
# proxy_password=$CENTRALIZED_ID_MGMT_PWD

# 
# no_proxy=".mylan.local,.domain1.com,host1,host2"
# 
# ---

}


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#########################################							OPS								##########################################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

reconfigurer_interfaces_reseau 

sudo yum update -y



clear
echo " +provision+usine+esante+  TERMINEE - " >> $NOMFICHIERLOG
echo " +provision+usine+esante+  TERMINEE - "
echo " +provision+usine+esante+  LOGS:  "
echo "   "
echo "  --  "
echo "   "
cat $NOMFICHIERLOG
echo "   "
echo "  --  "
echo "   "

# relancer_reseau
# echo 'exécutez maintenant la commande: [./relancer-reseau.sh]'
# echo 'exécutez maintenant : [sudo systemctl restart network]'


echo "Le résultat des opérations doit donner:"
echo " +provision+usine+esante+  TERMINEE - "
echo "[jibl@localhost ~]$ routel"
echo "target                 gateway          source         proto     scope    dev tbl  "
echo "default                172.21.0.1                      static          enp0s3      "
echo "172.21.0.0/ 16                         172.21.168.75   kernel     link enp0s3      "
echo "127.0.0.0              broadcast       127.0.0.1       kernel     link     lo local"
echo "127.0.0.0/ 8           local           127.0.0.1       kernel     host     lo local"
echo "127.0.0.1              local           127.0.0.1       kernel     host     lo local"
echo "127.255.255.255        broadcast       127.0.0.1       kernel     link     lo local"
echo "172.21.0.0             broadcast       172.21.168.75   kernel     link enp0s3 local"
echo "172.21.168.75          local           172.21.168.75   kernel     host enp0s3 local"
echo "172.21.255.255         broadcast       172.21.168.75   kernel     link enp0s3 local"
echo "::/ 96                 unreachable                                       lo"
echo "::ffff:0.0.0.0/ 96     unreachable                                       lo"
echo "2002:a00::/ 24         unreachable                                       lo"
echo "2002:7f00::/ 24        unreachable                                       lo"
echo "2002:a9fe::/ 32        unreachable                                       lo"
echo "2002:ac10::/ 28        unreachable                                       lo"
echo "2002:c0a8::/ 32        unreachable                                       lo"
echo "2002:e000::/ 19        unreachable                                       lo"
echo "3ffe:ffff::/ 32        unreachable                                       lo"
echo "fe80::/ 64                                             kernel          enp0s3"
echo "default                unreachable                     kernel            lo   unspec"
echo "::1                    local                     none                    lo   local"
echo "fe80::2a73:3dc3:365c:7910              local                     none    lo   local"
echo "ff00::/ 8                                                              enp0s8 local"
echo "ff00::/ 8                                                              enp0s9 local"
echo "ff00::/ 8                                                              enp0s3 local"
echo "default        unreachable                   kernel                      lo   unspec"
echo "[jibl@localhost ~]$"

clear
echo "Question suivante à résoudre:"
echo "  ==>>  Pouvoir faire les comandes yum : configuration DNS + configuration PROXY ( a marché sous Ubuntu)"
read VOYONS



