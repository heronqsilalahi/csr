echo "Install Generate-CSR scipt"
set -x
ssl_directory="/tmp/openssl"
# Remove previous version
rm -rf $ssl_directory
rm -rf /usr/local/bin/Generate-CSR
mkdir -p $ssl_directory
chmod 777 -R $ssl_directory
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/csr.conf -O $ssl_directory/.conf
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/generate_csr.sh -O /usr/local/bin/Generate-CSR
sudo chmod +x /usr/local/bin/Generate-CSR
set +x
echo "Script install successfully"
echo "Run command 'Generate-CSR' to start! \n"
echo " "
