#!/bin/bash

# Menerima input nama service
echo "Masukkan Nama Service (tanpa ekstensi .service):"
read dir

echo "Masukkan entry file js (dengan extensi):"
read entry
# Lokasi direktori systemd
systemd_dir="/etc/systemd/system/"

# Mendapatkan lokasi Node.js dari command whereis
node_path=$(whereis node | awk '{print $2}')

# Memastikan lokasi Node.js ditemukan
if [ -z "$node_path" ]; then
  echo "Node.js tidak ditemukan. Pastikan Node.js terinstal."
  exit 1
fi

# Membuat file service dengan template dan lokasi Node.js
sudo bash -c "cat > $systemd_dir$dir.service << EOL
[Unit]
Description=$dir
After=network.target

[Service]
User=root
WorkingDirectory=/root/$dir/
Environment=PATH=$node_path:/root/$dir/node_modules/.bin
ExecStart=/bin/bash -c \"cat /root/$dir/answers.txt | $node_path /root/$dir/$entry\"
Restart=always

[Install]
WantedBy=multi-user.target
EOL"

# Menampilkan pesan konfirmasi
echo "File $dir.service telah dibuat di /etc/systemd/system/."

sudo systemctl daemon-reload
sudo systemctl enable $dir.service
sudo systemctl start $dir.service
journalctl -fu $dir.service