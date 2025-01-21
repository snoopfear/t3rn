# t3rn

wget -O tern_upd.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/tern_upd.sh && chmod +x tern_upd.sh && ./tern_upd.sh

wget -O tern.sh https://raw.githubusercontent.com/snoopfear/t3rn/main/install1.sh && chmod +x tern.sh && ./tern.sh

wget -O tern_bot.sh https://raw.githubusercontent.com/snoopfear/t3rn/main/install_bot.sh && chmod +x tern_bot.sh && ./tern_bot.sh



wget -O upd_42.sh https://raw.githubusercontent.com/snoopfear/t3rn/refs/heads/main/ubd_42.sh && chmod +x upd_42.sh && ./upd_42.sh


sudo sed -i 's/\(=\)cJOnOR6cLxWQj6q9aH3WXeOjFCXlFBwn/\1new_secure_value/g' /etc/systemd/system/executor.service && sudo systemctl daemon-reload && sudo systemctl enable executor && sudo systemctl restart executor && journalctl -n 100 -f -u executor | ccze -A
