# t3rn

wget -O tern_upd.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/tern_upd.sh && chmod +x tern_upd.sh && ./tern_upd.sh

wget -O tern.sh https://raw.githubusercontent.com/snoopfear/t3rn/main/install1.sh && chmod +x tern.sh && ./tern.sh

wget -O tern_bot.sh https://raw.githubusercontent.com/snoopfear/t3rn/main/install_bot.sh && chmod +x tern_bot.sh && ./tern_bot.sh



wget -O upd_47.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/ubd_47.sh && chmod +x upd_47.sh && ./upd_47.sh


sudo sed -i 's/\(=\)iifOST3y_NkUDIlJK-A0T0F8CQy8QStg/\1AiOB1IWbbH0fg7dqh6U9u6GiClndbJvh/g' /etc/systemd/system/executor.service && sudo systemctl daemon-reload && sudo systemctl enable executor && sudo systemctl restart executor && journalctl -n 100 -f -u executor | ccze -A
