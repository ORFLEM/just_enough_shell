#! /bin/sh

plr_inf=$(eww state | grep plr_inf | awk '{ print $2 }')
cal_inf=$(eww state | grep cal_inf | awk '{ print $2 }')
wthr_inf=$(eww state | grep wthr_inf | awk '{ print $2 }')

case "$1" in
"plr")
  if [ "$plr_inf" = "true" ]; then
    eww update plr_inf=false
  else
    eww update plr_inf=true
  fi;;
"cal")
  if [ "$cal_inf" = "true" ]; then
    eww update cal_inf=false
  else
    eww update cal_inf=true
  fi;;
"wthr")
  if [ "$wthr_inf" = "true" ]; then
    eww update wthr_inf=false
  else
    eww update wthr_inf=true
  fi;;
esac
