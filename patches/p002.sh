# PATCH p002
MOD=/data/adb/modules/FanExtreme
mkdir -p $MOD/.backup/p002
cp $MOD/service.sh $MOD/.backup/p002/service.sh 2>/dev/null
cp $MOD/webroot/index.html $MOD/.backup/p002/index.html 2>/dev/null
sed -i 's/echo "{\\"battery\\"/echo "{\\"p002_test\\":\\"on\\",\\"battery\\"/' $MOD/service.sh
sed -i 's/· NUbia RedMagic/· NUbia RedMagic · P002-TEST/' $MOD/webroot/index.html
grep -q 'p002_test' $MOD/service.sh || exit 1
grep -q 'P002-TEST' $MOD/webroot/index.html || exit 1
echo "p002-ok" > $MOD/.p002_marker
