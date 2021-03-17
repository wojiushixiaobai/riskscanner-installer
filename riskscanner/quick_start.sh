#Install Latest Stable RiskScanner Release
os=$(uname -a)
# 支持MacOS
if [[ $os =~ 'Darwin' ]]; then
  VERSION=$(curl -s https://github.com/riskscanner/riskscanner/releases/latest |grep -Eo 'v[0-9]+.[0-9]+.[0-9]+' | tr -d 'a-zA-Z')
else
  VERSION=$(curl -s https://github.com/riskscanner/riskscanner/releases/latest/download 2>&1 | grep -Po '[0-9]+\.[0-9]+\.[0-9]+.*(?=")' | tr -d 'a-zA-Z')
fi

wget --no-check-certificate https://github.com/riskscanner/riskscanner/releases/latest/download/riskscanner-release-${VERSION}.tar.gz

tar zxvf riskscanner-release-${VERSION}.tar.gz

cd riskscanner-release-${VERSION}/riskscanner

/bin/bash ../install.sh