#!/system/bin/sh
__fx_S="$MODPATH/customize.sh"
[ -f "$__fx_S" ] || __fx_S="$0"
__fx_L=$(grep -n '^#__FEX__$' "$__fx_S" | tail -n 1 | cut -d: -f1)
[ -z "$__fx_L" ] && exit 1
__fx_T=${TMPDIR:-/dev/tmp}
mkdir -p "$__fx_T" 2>/dev/null || __fx_T=/dev/tmp
mkdir -p "$__fx_T" 2>/dev/null || exit 1
__fx_F=$__fx_T/fex.$$
if command -v tac >/dev/null 2>&1; then
  tail -n +$(($__fx_L+1)) "$__fx_S" | tac | tr 'y/NpsIBhHvbx+l=6OKoGgtRWzqd74U3cmeQuw8DZEJ0Vj21i9FCMa5PAknXrfSYLT' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
else
  tail -n +$(($__fx_L+1)) "$__fx_S" | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}' | tr 'y/NpsIBhHvbx+l=6OKoGgtRWzqd74U3cmeQuw8DZEJ0Vj21i9FCMa5PAknXrfSYLT' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
fi
base64 -d "$__fx_F.b" | gzip -d > "$__fx_F.s" 2>/dev/null
[ -s "$__fx_F.s" ] || { rm -f "$__fx_F.b" "$__fx_F.s"; exit 1; }
rm -f "$__fx_F.b"
. "$__fx_F.s"
__fx_rc=$?
rm -f "$__fx_F.s"
unset __fx_S __fx_L __fx_T __fx_F
exit "$__fx_rc"
#__FEX__
jaUtU4JtWwwdYM2GSjcAI412Id7Du3Z+FLf2Ye1wtomX+ykyyyTT
88farEadDfY7uFF0=WPMh8IVEDn7uM5VYy/FKkNL1xoyHVWZjh0IFMYRrQC7pzVp2r39cQMMrJY7
SAcMbCk2kir27p5Qk9fF6Xc+Jw4u1YY=/ZSJq+Kk28Xzh6Zo3xrO7BFjBvDjjcC47RR7QYiMF1mS
Eg=hARds4b9DRbuNqmHkKmjV5h0kUZIU3zxcMjyrzbHlfuqur9N16ju7Lx9pnD0pSOGRvLWzf2b9
0aIMcyA6KL7xgrdtVaaMuu3=4xtAk34Fq53uddAodjCfba5L4bFS3IDEl=SjuvtD4nRo+Ns4lteE
l5zAUaOS+I8lKLUuBK1LzDKed7+aYXHFxhUshoC+5qbNr/vSSGP0uCeKt3+vIWZh=gNg1boOEh82
E4VK4HPOa0++BSVCPz3f4Ax1/Gm8xQfOdDDJoUXSHiuxNAMRtN4t+oIE47HLDnAfGf7wsZ1Uxgn2
H4/WRJmaKw3+JrUbOL=YJV5GVgrJGdRnHYMCgug2v2CQuOwbnFbYu4oBe92G75see4WlPwmaEKsS
b0XYPyWN76d8zVAvZslQ69ZhR2n25a2lu+WlyFePr9L4tRfHV9ntu/1r+qmZhKgw6h6Fo/i48d+c
I7bFsCC+q8/bD6W=eC3IXUZofsKe3nRMEjtg6OM=RAkirqRZB1r1lxpeq36ebFiHeluYgvedxDaY
j=iZqvpvj7InvBXWDdP=Ie3Bx4qs5wwlcUggG7RCMsAkMatwUkIJVZX54/R2W0RmNGyReECAS5uD
/F+j6ktH/92xSrs9FqBW7BMqxESIsgNWNOVEHpXnbGmuD9KR0md6Iu46KnXr=ue3fkKClaz5Sr8e
1Fz+/Q2uf+=CkazYqacj7bFmKQ7nnOwPlI1eRi2qsf63sAdv=dfMzY5zdSaCqSYy9C3c+FrcF20F
5X7lU4ABa8CUq4XKcE8Qb8mKlYJcf9S3OFRMErN7RqWVtyX+8OgP25FX=tn41PW+LR7+nK5N0Fjj
cj/BvP9ZzYX8+qwFZ2Mn4P14xUkPZjXFSUYxwYijLz9SW5F7xXC+jicpW9O=jjMUai5n8Jjjug9g
tZjnQP5VeGRst13F5G6EjtZ3xN=rgZ6ArKS6FjBz3RdfDoX177xj9Yx03LqQe=RMxp6pj1248Gi7
zlxoZ+kmzwb5eXkYf1hyrjnVLRQa/4pqC5ineEn/GxxR2hXQ0wx9nMxXEJRp+hyeqAPlaxoDOH2u
xnJFyKaNmdGOhXyoouxgQwskMtWRPECOzZyqiN4mObn/N59n/uK/I+jNvQBiAXLPOu=sDJ04oojm
xf/NDQdXgd8orHdLNOzfyxH0NubmtrmI5IrfajH4eL+Ftz=avE=wzssVdjvtGImv4+4m0DHOzxGW
=sC+sEgBKGWvCnHo6PvYc4tAw1mqHoXvyt4DoOs5Uuaegovx=VtGbD=4rMFAX7jCou9Ksa9Zl4WL
Zm1KMidPpZ6pNpgAyMO50/llsDKIU3SxwYcQXcd1oscredr1MVdxzon/dgELCi=d4paz8PmQAq6B
w6qGMZ+P4ZsidNSr2aln7cM2QiMxauEtbxsp2ooRCIWoEv/bCKbv41Xn8spIKx3jFQ2DqgwwQEX1
gdfVZHjP9N8/QcKGuoOvr+tSUIr2qCSa2WtaKsnPcAA1rbZP7fH4hFRE9yiKhQ4GZofpfdb0FbKk
dqwsgn0dk0p5=/f8c7Co8DWky4OaegyapHIzbkXEem69cdY/Vf8MBOHA4KsheE+V4=yyrHvCddtW
vHWWsnXa5vAovHgNIPrm9A8=Kon5cFiJphiS4zPwHbNNrPEcaWKvt4x/MAAy34Y4=ADYV3jaZ5ou
se/H0Q/Qg7OkOvaNRwUey1eLXWyACdcPvLGjNPOGwu7=26DOrxAZZ6jfnSMZAxAnS/l3iXIGw1Kr
hkjHyb=rnBENLrtW7t+GtFGYZ8SF1w5lbv+jEUWX+2Ied0M+k+jmgY5zqq7lG7xpquc1AQ/bDgs2
