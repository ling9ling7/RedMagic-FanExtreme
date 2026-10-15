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
  tail -n +$(($__fx_L+1)) "$__fx_S" | tac | tr 'xRzIwV9TuSUf/ErQ4KJNthy3jlvmgGk2Ab0s+cpe5ZYnOMWP68DLqoa7B1H=XdiCF' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
else
  tail -n +$(($__fx_L+1)) "$__fx_S" | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}' | tr 'xRzIwV9TuSUf/ErQ4KJNthy3jlvmgGk2Ab0s+cpe5ZYnOMWP68DLqoa7B1H=XdiCF' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
fi
base64 -d "$__fx_F.b" | gzip -d > "$__fx_F.s" 2>/dev/null
[ -s "$__fx_F.s" ] || { rm -f "$__fx_F.b" "$__fx_F.s"; exit 1; }
rm -f "$__fx_F.b"
. "$__fx_F.s"
__fx_rc=$?
rm -f "$__fx_F.s"
[ "$__fx_rc" != "0" ] && exit "$__fx_rc"
unset __fx_S __fx_L __fx_T __fx_F __fx_rc
#__FEX__
ewrYYbQrCtnDO2irBTcVzH3ULzUmL3=X7HUCx4jplokeI4xx
qPuDW1Ms9XXHs86Uef=K0Y01qQSjNLLGd6R8K0RPGytSK9YM42gYs7HO7JBvR8KW7dHwCMTOW7Xi
RpGCZ==YDsfO7Cmp4Ln1xrYLaa8B=927eGTuyXM+aEroDeNpzClOYlrMn=EOeby2qgoXl7hM+k3W
Scn6q99e9JROY6wyGE+/xEM5jAhIb1O7ooweXc5hkwjEMITkjW6lbk8sP/3Q/aZ+9aOcO9VZDSU3
B=yMzg7SwO8TiOONWccWNs/9m8LbKWCUL8Qan+lJpMPU1M=hlsCjopVBy3zmMdgevP/VMD4/zVOE
l=maoLGeKzO6ytoVdpU8dhXbOnUDtlMCPsXOlq4ffushw5fOwT7skd46h0UY8p/0XnvLIDO8JgVi
EvLThN+JmbSJk10cB1PMoZz7SiGWAE70k5SAuEztPI/sXMjN2EmK5b48fpA8Pfkv=2SQmTYVPO13
uqgP4UIaaMuqDa3j+1WoXg3asMaZoYfobMUgwhl=0l5JBq=KKAyVg6s24YfZG93pfJ0+OnLKTuew
psacpwXDkqsOSyVmH=PMkU0SqlA8ArqSR2fB7b//iLdPjr6tRj6L/thAWutRSd4BHjAA6gDV+Nva
c6tZ4G3mT813lWGnHveUo0ZeK5PShb0gZC1gapoQudDGytNNK2mAc4h+498dY/6tv8OQYHPQGBzA
RNY8z/JMEMQh3TtZmNf9O5HmHUWZvRYhlyLz2DB0H84j1OlTzigHHAqUp+SOvlDdPtWLnBzEhyxc
ZU=UDso5NI3LA+Btn2vjVRTJl46zH5unS63=L0uReynzuiI+jgMLK62TpqB51XV51fH4KcmC=xYD
s5wQLtiDgO9UaV1CzKtl1uMNGTLkZhnnybQIebEy0LpQPyfWyUbcpCEP+/ae39zQm+TPHQqZyZBR
TzLEgmU/EN60wJAVrWSwCyP8CpPt6r65aYpO63ypAEsfSmZ4nfajnSlWO532awflSnJHNP/cPdCP
UgWSfm8AqoeaiQv2p1EqiKl=O+I32YdrndT7gdlHMmKyklps=d/T2hqqkHGam1wyZpWlYyZZoObn
NfjbcLtuhPODoImyln9XttGacrjXM3XXe+KO=0c=/oOMmGIXAinYkC5X4XM1pZasiNyW6loW7vk1
ErJf5QmPMTvB0y+B0383KXR5zjzLqZPoR5ibY9NpETX0Y5fb18fBAZhIjg4V=26vS0cE44TmnV=b
fTQW3bOKtbKG4ZBNDukP5AzH2xDKrVl/zLuukm8kd4nYK/9rIePKIQxlMI4r3tjTI0xO8c3ndAGw
U/AuP/uRZVHRfD7/gmxkhNytqp4+UGR4hqXBoBSlxTg/Kh4u4bIMXjZ9ewdTQcdz9QwKz44lIww4
KXBu/teqrJZSzfzooiuJ6mU+wHW+rOm1CeQ22VMT0gysAW9+SPeCRhbu+2sA/E4GPk=M4UEMz/pY
6=DJ+WyrM5Wek6GHie5PIxLaGoX/g7Vz+PZKeMkwvCHjKrUZ5KNw4ywwUX4PYAckcZNjwkQnJ=B2
fBnYJ2oz/0cfr/u1o1uzwkrIObZLngYJ0RtG3EOWdQN7GPkVQGBjS+cENJSEdkMj+6KlthT5rRCR
wjwuPRxlBbEYSzhsevCIXUUYKUyjeB64nWoOLX3Gu/ilgD2QG6igGsetgXQP4/iCZEvS4fxhYzy4
JkTokVMU9+8Y++u4Vd=Tb7QBu7KUtTZ90ujN9xq2du2X3G8TZiOdka9AWHiP1iNAhi2reWndrOL8
pxJRZx50V+yfxHcN0GlKpxIH3LngpiKNi8EHdAyD91uyldZXJTmPk3pkgi1LLaBiCjN3niOwSCAb
TBOuxxLKq95zC=h3mh/Nh8NiLYiB7vjJD0Jm89SdpkA6VJOLiIfusrojDDDmpaNTLy=gPt9t/5Qv
