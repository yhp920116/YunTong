#!/bin/sh

# 
# 使用说明:
# 使用sh命令执行运行：　　sh ./*.sh文件名
# 使用chmod给.sh文件赐予执行X权限，然后运行：chmod +x *.sh; ./*.sh
#

marketInfoFile=MarketInfo.dat
if [ ! -f "$marketInfoFile" ]; then
echo "渠道信息配置文件’"$marketInfoFile"‘不存在，程序退出！"
exit
fi

targetName="CloudCall" #项目名称(xcode左边列表中显示的项目名称)
targetName1="YunTong"
version=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$targetName-Info.plist")

oldpwd="$PWD"
cd ~/Documents
dstDir="$PWD"/${version} # 输出的目录
cd ${oldpwd}

echo "版本输出目录 $dstDir"

if [ -d "$dstDir" ]; then
  echo "文件夹"$dstDir"已经存在，删除该文件夹并继续？ (y|n) : \c"
  read aok
  if [ $aok == "n" -o $aok == "N"  ]; then
    echo "你已取消打包"$version"。"
    exit
  else
    rm -rdf "$dstDir"
  fi
fi
mkdir "${dstDir}"

echo "开始编译，请稍候…"

cd ../ios-ngn-stack
echo "Cleaning 'ngn-stack' all ..."
buildngnlogfile=${dstDir}/build_ngn_errors.log
xcodebuild -alltargets -configuration Release clean > /dev/null  #clean all targets
echo "正在编译'ngn-stack'..."
xcodebuild -alltargets  -parallelizeTargets -configuration Release > /dev/null 2> ${buildngnlogfile}
if [ -s ${buildngnlogfile} ]; then
  echo "编译生成'ngn-stack'出错，请查看${buildngnlogfile}"
  exit
else
  rm -f ${buildngnlogfile}
fi
echo "成功编译'ngn-stack'\n"

#编译cloudcall
cd ../ios-cloudcall

xcodebuild clean -configuration Release > /dev/null

outputDir="./build"
releaseDir="${outputDir}/Release-iphoneos"
DATE=`date +%Y-%m-%d`
for line in $(cat $marketInfoFile) #读取所有渠道号
do
ipafilename=`echo $line|cut -f1 -d':'` #渠道名
srcid=`echo $line|cut -f2 -d':'`       #渠道号
echo "$srcid" > sourceid.dat
releaseName=${targetName1}_${version}_For_${ipafilename}_$DATE.ipa

#OEM文件替换
yes | cp OEM_FILE/${ipafilename}/*.png OEM_FILE/
yes | cp OEM_FILE/${ipafilename}/*.h OEM_FILE/
yes | cp OEM_FILE/${ipafilename}/en.lproj/InfoPlist.strings ./en.lproj/
yes | cp OEM_FILE/${ipafilename}/zh-Hans.lproj/InfoPlist.strings ./zh-Hans.lproj/

echo "正在编译生成'${targetName1}.app'..."
appfile="${releaseDir}/${targetName1}.app"
buildErrLogFile=${dstDir}/build_errors.log
xcodebuild -target "$targetName1" -configuration Release -sdk iphoneos build > /dev/null 2> ${buildErrLogFile}
if [ -s ${buildErrLogFile} ]; then
  > sourceid.dat
  echo "编译生成'${targetName1}.app'出错，请查看${buildErrLogFile}"
  exit
else
  rm -f ${buildErrLogFile}
fi
echo "成功编译生成'${targetName1}.app'"

echo "正在打包'${releaseName}'..."
ipapath="${dstDir}/${releaseName}"
/usr/bin/xcrun --sdk iphoneos PackageApplication "$appfile" -o "$ipapath" > /dev/null
echo "成功打包'${releaseName}‘\n"

done

> sourceid.dat

echo "编译结束。"

rm -rdf "${outputDir}"
rm -rdf "../ios-ngn-stack/build"

open ${dstDir}

exit