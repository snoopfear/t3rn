# t3rn


wget -O tern_upd.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/tern_upd.sh && chmod +x tern_upd.sh && ./tern_upd.sh


INST

wget -O tern_install.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/install.sh && chmod +x tern_install.sh && ./tern_install.sh

wget -O tern1.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/install_%24.sh && chmod +x tern1.sh && ./tern1.sh

wget -O tern_bot.sh https://raw.githubusercontent.com/snoopfear/t3rn/main/install_bot.sh && chmod +x tern_bot.sh && ./tern_bot.sh


UPD
wget -O upd_latest.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/upd_latest.sh && chmod +x upd_latest.sh && ./upd_latest.sh

UPD wget -O upd_53.1.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/upd_53.1.sh && chmod +x upd_53.1.sh && ./upd_53.1.sh


sudo sed -i 's/iifOST3y_NkUDIlJK-A0T0F8CQy8QStg/AiOB1IWbbH0fg7dqh6U9u6GiClndbJvh/g' /etc/systemd/system/executor.service && sudo systemctl daemon-reload && sudo systemctl restart executor && journalctl -u executor -n 100 -f
