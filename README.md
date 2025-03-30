# t3rn


INST

wget -O tern_install.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/install.sh && chmod +x tern_install.sh && ./tern_install.sh

wget -O tern1.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/install_%24.sh && chmod +x tern1.sh && ./tern1.sh

NON API 53

wget -O install_nonapi_53.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/install_nonapi_53.sh && chmod +x install_nonapi_53.sh && ./install_nonapi_53.sh


UPD

wget -O upd_latest.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/upd_latest.sh && chmod +x upd_latest.sh && ./upd_latest.sh

wget -O upd_53.1.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/upd_53.1.sh && chmod +x upd_53.1.sh && ./upd_53.1.sh


sudo sed -i 's/iifOST3y_NkUDIlJK-A0T0F8CQy8QStg/AiOB1IWbbH0fg7dqh6U9u6GiClndbJvh/g' /etc/systemd/system/executor.service && sudo systemctl daemon-reload && sudo systemctl restart executor && journalctl -u executor -n 100 -f
