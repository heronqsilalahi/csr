ssl_directory="/tmp/openssl"
mkdir -p $ssl_directory
chown 777 -R /tmp
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/csr.conf -O $ssl_directory/.conf
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/generate_csr.sh -O /usr/local/bin/Generate-CSR
sudo chmod +x /usr/local/bin/Generate-CSR
echo "Script install successfully"
echo "Run command 'Generate-CSR' to start! \n"
echo " "
