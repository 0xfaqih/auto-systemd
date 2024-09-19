#!/bin/bash

# Menerima input nama service
echo "Masukkan Nama Service (tanpa ekstensi .service):"
read dir

# Pilihan antara Node.js atau Python
echo "Pilih jenis proyek:"
echo "1) Node.js"
echo "2) Python"
read choice

# Lokasi direktori systemd
systemd_dir="/etc/systemd/system/"

if [ "$choice" -eq 1 ]; then
  echo "Masukkan entry file js (dengan ekstensi):"
  read entry

  # Mendapatkan lokasi Node.js dari command whereis
  node_path=$(whereis node | awk '{print $2}')

  # Memastikan lokasi Node.js ditemukan
  if [ -z "$node_path" ]; then
    echo "Node.js tidak ditemukan. Pastikan Node.js terinstal."
    exit 1
  fi

  # Membuat file service dengan template untuk Node.js
  sudo bash -c "cat > $systemd_dir$dir.service << EOL
[Unit]
Description=$dir
After=network.target

[Service]
User=root
WorkingDirectory=/root/$dir/
Environment=PATH=/bin:/root/.nvm/versions/node/v20.16.0/bin:/root/$dir/node_modules/.bin
ExecStart=/bin/bash -c \"cat /root/$dir/answers.txt | $node_path /root/$dir/$entry\"
Restart=always

[Install]
WantedBy=multi-user.target
EOL"

elif [ "$choice" -eq 2 ]; then
  echo "Masukkan entry file Python (dengan ekstensi):"
  read entry

  # Mendapatkan lokasi Python dari command whereis
  python_path=$(whereis python3 | awk '{print $2}')

  # Memastikan lokasi Python ditemukan
  if [ -z "$python_path" ]; then
    echo "Python tidak ditemukan. Pastikan Python terinstal."
    exit 1
  fi

  # Membuat file service dengan template untuk Python
  sudo bash -c "cat > $systemd_dir$dir.service << EOL
[Install]
WantedBy=multi-user.target

[Unit]
Description=$dir Service
After=network.target

[Service]
User=root
WorkingDirectory=/root/$dir/
Environment=PATH=/root/$dir/venv/bin/
ExecStart=/bin/bash -c "/root/$dir/venv/bin/python3.10 /root/$dir/$entry < /root/$dir/answers.txt"
Restart=always
EOL"

else
  echo "Pilihan tidak valid. Silakan pilih 1 untuk Node.js atau 2 untuk Python."
  exit 1
fi

# Menampilkan pesan konfirmasi
echo "File $dir.service telah dibuat di /etc/systemd/system/."

sudo systemctl daemon-reload
sudo systemctl enable $dir.service
sudo systemctl start $dir.service
journalctl -fu $dir.service
