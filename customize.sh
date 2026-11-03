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
  tail -n +$(($__fx_L+1)) "$__fx_S" | tac | tr '+vAsiB5Y8ed3Kj9N7VhRtpn2=XzkrwOaSbU/IfoEcCDHQW6yxl1mgFGuPZJL4qMT0' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
else
  tail -n +$(($__fx_L+1)) "$__fx_S" | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}' | tr '+vAsiB5Y8ed3Kj9N7VhRtpn2=XzkrwOaSbU/IfoEcCDHQW6yxl1mgFGuPZJL4qMT0' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
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
QgwpwrCp2IIzMmWRqQauBr6WBzko/OEKlT4WMb6IphSJK+P+++00
ff4gLcgzo4Mk/llD92GmYfBHcoZk/mFHM+vlVPAT63h+8H2EQYDBlmMnLU1ks=HsWLOxaUmmLCMk
quamd1PWPyLWksFUPx4lNJaKCIr/6MM9vEqCXKVPWfJ=YNEhO3L7k5lQ5eoQQa1rknnkUMyml6Sq
ct9Yunzirdxond/AXS8PVSQHFYDPwEBwO=3amQ+L=d8j4/X/LxA6NQ/kT3xsZoDsq7RneT2=4Wdx
DgBma+uNVTk3tLzpHggm//O9r3puPOrlXFO/zzuhzQ14dgFTrdlqOBocj9qQ/eporZnhKAirjpbc
jF=uwg7qKBfjVTw/5V6T=oVbzkKgMJ8l3YwiYh1KFXdALveqqRGD/1bVpOKeB2EY9tAt6dh7cYfW
crHVr8G7gDKK5qH1G=O4ru36vRSf3U47zooChwJq8y/3AumnpArpKhBcrk8ToZu4R4kIiE6w3tZW
8rv2nCSgVIOKCLwd7T9MCHFRHtLCRznZ8Mm1t/tWeW1U/7IdZldM/rh5bxWRkFibbr2jGISgcViq
dDJMG+2AkNzf=HueEijUNxEYnWZWFgWj/K2j+lbGLxTrpn48HxZp/v6LKXSEYVtINYNlhvyrfzKa
Bkdli11KXfvdoN29b1OBJwEh4iVbOZnmcQptN7m9nuPyLXnE56L6j3sbXONbdly8bj/Mtebz3ogM
Q9yEXeseQkBZe5J2ozG9BbO53rXiFIIjawttRkn1miuPmgpIwPBCHEJFrvnW2DnSAR+nbc1uqF/o
vlKQNPp8vxW3qLixlX52k5mX3cqBitA2A7Hc8sJZdRS/oxVnDSzNB/rNVZJL9/bO4PV1jg=FqLfb
6l=KvUW/4K91Pg=MXgaQkdlSVUkZZ7IGjB6bnyWXi4NOiuze9z4m=MF=zqg1XqM+x1OaKlLalWDl
FJkjwru5gf1wXrJVacfUdfSVjMCa4xqO7lnmcLAknX2Hp+JKf7tGWFlJ9pZr6G2KTnkKZVFADlQQ
aQv5eGxE=MJfKXIlEWmZrG6r3wPGEQJlqwM3IMyQT=xq2Flk3J1KQyas2x79QQmwgyFZfCQQ/txt
pEQZUGFHbRnip6OlFRNcQpEO3A9LtENuLVqNlQ5=Onz4ohJ6kk3QxM3DOTXUb9nm3sNsQ6WrfRyk
=j3hEKPS=IdFbJPM46Y+LQZHTnUgvrsX1FyZbcZvR33nWYJUDI3xZm3JcCnsKY+bXuGjg3ho78W/
3ZCl+VgASzR7YJ+hh/3tUIiPmp2nGc17=E+XyArS7dZvAFxZv/VvBKQAeU5yuJTG7/9ioCDrhhQS
34vAoUzJtzfhL8zTA7=4+38DA/dSpLSBFBL4gQ8rbTKlp=9gec9I=iiHzQepRBSerKrSDo87=3R2
9i1Kict5VR2e1Z8hNGeMarpuI6SX8hJe+proh7iFw/gbthe39HpRdo9rLmluJkQ1h/xVigxEjr2T
ES6VmyzGsENsAstu+m7FDvjjioVBwOq3IMaUJaz6hiaLbzL6mHz3=hZvztcT1y9zrsg=fGSUuXN5
INXRmEKGrEiyzAqLWgjZkamWUym3g/cpd3isWhhn1B2hcevd1Vder6JZfisBV3OQlUWoXtIIUcJ6
tz4HE8QGxAfvUaVR/h7eLKpqwBLWX1qgW2pgViZGauu6LdEGk48rYlncx+yVYUrREh4s4zdDldVP
zXIitZDzPDsF9v4fak1hfo2P+r7gbt+gs8B=dPJcbSNxazMvH4fm578urViYbcKHr9++L8e1zzp2
e822iZJgFeuhe8tABGLSxuf9VhZFalyCsYyqr=GI8dAALGcag2Vepr3vmuu+OrMr9uoMHOQgEFh/
ibv8DUvUtk7P7egAnIwb+6bTJ2+u1zaGeTRQAG7RI/k9WNo7L3uEENQ4ZqmEu3uZqvjOyJBRI6VL
YPQ8+eSBJocATLp2kpKRplRMEfql6IFjdeKQcw2JKWBbzDmKPKQStMF=XXkjRk3sX/a6uUvdotiW
