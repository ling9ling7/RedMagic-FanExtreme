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
  tail -n +$(($__fx_L+1)) "$__fx_S" | tac | tr 'pYy6PD1jRc=lsavkNZK/u2FgMqxzCAHEXUSV0wiOdT478ehbmn+oLJ9W3f5IrtBQG' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
else
  tail -n +$(($__fx_L+1)) "$__fx_S" | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}' | tr 'pYy6PD1jRc=lsavkNZK/u2FgMqxzCAHEXUSV0wiOdT478ehbmn+oLJ9W3f5IrtBQG' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
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
OPv44UkvQu7+8EBv3jwDy5g=oy=zogIrW5=QpNMiqJHO6Npp
LbR+hfeV1rr5Vnm=OlIZS4SfLkcM/ooAtmYnZSYbAFucZ14eNEC4VW58WK3xYnZhWt5PQej8hWrB
YiAQTII4+Vl8WQziNo7fpv4o99n3I1EWOAjRFre09avJ+O/iyQq84qve7Ia8OUFELCJrqW2e0Hgh
cw7mL11O1KY84mPFAa0spaedMX26Uf8WJJPOrwd2HPMae6jHMhmqUHnVbsgks9T0198w81DT+c=g
3IFeyCWcP8njB88/hwwh/Vs1znoUZhQ=onk970qKieb=feI2qVQMJiD3FgyzetCOxbsDe+NsyD8a
qIz9JoAOZy8mFuJDti=nt2rU87=+uqeQbVr8qLNllRV2Pdl8PjWVHtNm2S=4nisSr7xo6+8nKCDB
axoj2/0KzUcKHfSw3fbeJTyWcBAhXaWSHdcXRayub6sVreM/EazZdUNnliXnblHxIEckzj4Db8fg
RLCbN=699eRL+9gM0fhJrCg9Ve9TJ4lJUe=CP2qISqdK3LIZZXFDCmVEN4lTA1gilKS087oZjROP
iV9wiPr+HLV8cFDz5IbeH=ScLqXnXvLcYEl3WUssBotbMvmuYMmosu2XhRuYctN35MXXmC+D0/x9
wmuTNAgzjnfgqhA75xO=JSTOZdbc2USCTQfC9iJkRt+AFu//ZEzXwN20N1nt4smuxn8k45bkA3yX
Y/4nysKeaek2gjuTz/l18d5z5=hTxY42qFoyE+3S5nNMf8qjyBC55XL=i0c8xq+tbuho73ya2Fpw
T=I=+VJd/6goX03u7ExMDYjKqNmy5dR7cmgIoSRYOF7yRB60MCeoZmEjiL3dfrDdfl5NZwzQIp4+
VdPkouB+C81=9DfQyZuqfRe/AjoHT277FUk6OUaFSoikbFlhF=UwiQab0s9Og1ykz0jb5kLTFT3Y
jyoaCz=sa/mSPKXDvhcPQFbnQibumvmd94i8mgFiXaVlczTN7l9M7cqh8dgE9Plqc7K5/bswbtQb
=ChclznXLJO9BkxEifaLBZqI806gE4tv7tjWCtq5ezZFHqiVItsjE2LLH5A9zfPFTihq4FTTJ8U7
/lMUwouR2b8+J6zFq71ruuA9wvMregrrO0Z8ISwIsJ8ezA6rXB74HQdrNrefiT9VB/FhmqJhWxHf
avKldkzbejx3SF03SgngZrYdyMyoLTbJYdBU41/iajrS4dlUfnl3XT26MCNDIEmxcSwaNNjz7DIU
ljkhgU8ZuUZANT3/+RHbdXy5Ep+ZvDqsyoRRHznHtN74Zs1v6ObZ6kpqe6NvguMj6Sp8nwg7tXAP
=sXRbsRYTD5Yl+WsCzpH2/FuLiN0=AYN2Lr3J3cqpjCsZ2NRNU6erMT1OPtjkwty1kPZyNNq6PPN
Zr3RsuOLvKTcylyJJBRKmz=0P5h0v8zfQOkEEDejSCFVXh10cbOQY2UR0EVXsaNAbHIeN=aeysi4
mI+K0hFvedhOHmA5BOdb6po9AJrsCWDy0bTZOeHPxQ5MZv=TdZ/PNFPP=rNb4XwHwT/MPHk7KI3E
l374KEJysSwlvsRfJfRyPHv68UTo7C4KSYuAga8htk/WAbHDkA3Mc0wa/KcatHeM0mZqu2jdvYQY
PMPRbYpq3Ua4cy2VOxQ6r==4Z=FMO3mN7hJ8orgARsBqC+EkAmBCAVOuCrkbNsBQTaxcNlp24yFN
KHjJHDe=10n400RNDtIjUWk3RWZ=ujT1SRM/1pLEtRErgAnjTB8tH91Xh5BbfB/X2BEvOh7tv8on
ipKYTpdSD0Flp5w/SAqZip65go7CiBZ/Bna5tXF+1fRFqtTrKjzbHgiHCBfoo93BQM/g7B8PcQXU
j38Rp62Cf1dyQI2gz2s/2n/Bo4B3WxMK+SKzn1ctiHXmDK8oB6lRVvJM+++zi9/joFICbu1usdkx
