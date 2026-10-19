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
  tail -n +$(($__fx_L+1)) "$__fx_S" | tac | tr 'H7etlNu5Yw3o9XS1iCOKEc/A8IyQpq+n=6Z4xW0GvUrkgzmMDJhadbjFPLVfTRs2B' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
else
  tail -n +$(($__fx_L+1)) "$__fx_S" | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}' | tr 'H7etlNu5Yw3o9XS1iCOKEc/A8IyQpq+n=6Z4xW0GvUrkgzmMDJhadbjFPLVfTRs2B' 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=' > "$__fx_F.b"
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
GlSrr61S2EkhgnsSP5WNeVA3ae3QaAfTFV32Hi80Ib+GtiHH
dMYhmLz4uTTV4JD3GofCZrZLd1w8KaaqRD7JCZ7Mq/EwCurzinpr4FVgFOPy7JCmFRVl2z5gmFTs
70q2Uffrh4ogF2Q0iakLHSrajjJPfunFGq5Y/TzxjXSbhGK0e2IgrISzkfXgG6/ndpbTIFczx+Am
wWkDduuGuO7grDl/qXx9HXzv8=ct6LgFbblGTWvc+l8Xzt5+8mDI6+J4M9A19jUxujgWguNUhw3A
Pf/zepFwlgJ5sggKmWWmK49uQJa6Cm23aJ1jkxIO0zM3LzfcI428b0NP/AeQzRpGyM9Nzhi9eNgX
IfQjbaqGCegD/EbNR03JRcT6gk3hEIz2M4TgIdiooY4clvogl5F4+RiDcZ3rJ09ZTkyathgJOpNs
Xya5cKxOQ6wO+LZWPLMzbUeFwsqm=XFZ+vw=YXeEMt94Tz8KnXQCv6iJo0=JMo+yfnw1Q5rNMgLA
YdpMi3tjjzYdhjA8xLmbTpAj4zjUbrob6z3plcIfZIvOPdfCC=/NpD4niroUquA0oOZxgkaC5YGl
04jW0lTh+d4gw/NQVfMz+3ZwdI=J=Sdw7noPF699saRM8SDE78Da9Ec=mYE7wRiPV8==DphNxKyj
WDEUiqAQ5JLAImqkVyG3bZUGCvMwc6ZpU2Lpj0b1YRhq/EKKCnQ=WicxiuJRr9DEyJg1rVM1qPe=
7KrJe9OzXz1cA5EUQKougvVQV3mUy7rcI/aenhPZVJi8LgI5espVV=d30xwgyIhRMEmakPeXc/HW
U3f3h4bvKtAa=xPEkny8N75OIiDeVvYkwDAfaZY7G/keYstx8pzaCDn50dPvLTNvLoViCWQ2fHrh
4vl1aEshpgu3jNL2eCEILYzKq5a+Uckk/61tG6X/Za01M/om/36W02XMx9jGAue1Qx5MV1dU/UP7
5eaXpQ39XKDZlO=NSmwl2/MJ20MEDSDvjr0gDA/0=X4owQUikoj8kwImgvAnjloIwkOVKM9WMR2M
3pmwoQJ=dbGjs1yn0LXdsCIfgxtAnrRSkR5FpRIVzQC/+I04fR95ncdd+VqjQLl/U0mIr/UUbg6k
Ko86WaEYcMghbtQ/IkuTEEqjWS8TzATTGxCgfZWf9bgzQqtT=skr+2vTiTzL0Uj4sK/mDIbmFy+L
XSOov1QMz5yPZ/xPZAJACT7ve8eadUMb7vs6ruK0X5TZrvo6LJoP=Uct8piNfnDywZWXii5QkNf6
o51mA6gCE6CqiUPKhY+Mv=eVnHhCSNI9eaYY+QJ+RikrC9uStGMCt1HIztiSAE85tZHgJWAkR=ql
39=YM9Y7UNV7ohF9pQH+cK/Ed0ix3q7icdTPbPwIH5p9CciYi6tzT8UuGlR51WReu1lCeiiItlli
CTPY9EGdSOUweoebbsYODQ3xlVmxSgQL2G1nnNz5Zp/4=muxwMG27c6Yxn4=9XiqM+fzi3Xze90r
DfhOxm/SzvmG+DqVsGvMtHajqbT9pFNexMUCGz+ly2V8CS3UvCKli/ll3TiMr=W+WUK8l+1kOfPn
oPkrOnbe9ZWoS9YLbLYel+Stg6UakprOZ7EqAXgmR1KFqM+N1qP8wxWXKOwXR+z8xDCIEc5vS727
l8lYM7HIP6Xrwec4Gy2tT33rC3/8GPDikmbgaTAqY9sIphn1qDspq4GEpT1Mi9s2UXywioHcre/i
O+5b+Nz3uxJrxxYiNRf56F1PYFC3E5UuZY8KuHdnRYnTAqJ5UsgR+ju=mVsMLsK=csnSGmkRSgaJ
0HO7UHvZNx/oHVWKZqIC0HtVAakp0sCKsJXVR=/huLY/IRUTO5QM+A0+psLaajPs28KAksglw2=6
5PgYHX/Mb/ve2fcAQc9KcJKsarsPFy8OhZOQJuwR0+=DNOgastoY4Sb8hhhQ0jK5a/fpMEuE9v1y
