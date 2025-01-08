# Restart cake services

```bash
alias restart-cake="sudo systemctl daemon-reload && \
sudo systemctl start apply-cake-qdisc.service && \
sudo systemctl start apply-cake-qdisc-wake.service && \
sudo systemctl enable apply-cake-qdisc.service && \
sudo systemctl enable apply-cake-qdisc-wake.service && \
sudo systemctl status apply-cake-qdisc.service --no-pager && \
echo \"\" && \
echo \"|-----------------------------------------------------------------------------------------------------|\" && \
echo \"\" && \
sudo systemctl status apply-cake-qdisc-wake.service --no-pager"
```