ssl_directory="/var/openssl"
mkdir -p $ssl_directory
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/csr.conf -O $ssl_directory/.conf
wget https://raw.githubusercontent.com/heronqsilalahi/csr/main/generate_csr.sh -O /usr/local/bin/Generate-CSR
sudo chmod +x /usr/local/bin/Generate-CSR
