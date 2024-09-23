## Add into your .bashrc

```script
alias fastfetch='BLUEFIN_FETCH_LOGO=$(find $HOME/.config/fastfetch/logo/* | /usr/bin/shuf -n 1) && /usr/bin/fastfetch --logo $BLUEFIN_FETCH_LOGO -c $HOME/.config/fastfetch/config.jsonc'
```
