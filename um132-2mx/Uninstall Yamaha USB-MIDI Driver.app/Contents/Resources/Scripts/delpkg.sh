#!/bin/bash
IFS=$'\n'
restartCheck=false

# restart 要求の記述確認判定
while getopts "r" flag; do
    case $flag in
        r) restartCheck=true;;
    esac
done

cd "$(dirname $0)"
delListPath="lists"
echo "----------"
for eachFile in `ls $delListPath`
do
  echo $eachFile
  # sedの処理：'#'以降を削除：行末の空白を削除：空白行を削除
  for eachLine in `cat $delListPath/$eachFile|sed s/#.*$//|sed s/[[:blank:]]*$//|sed /^$/d`
  do
    if [ ${restartCheck} = true ]
    then
      # restart 要求
      if [ ${eachLine:0:1} = "r" ]
      then
        echo "RestartRequired"
        exit 0
      fi
    else
      # ファイルの削除
      if [ ${eachLine:0:1} = "f" ]
      then
        echo "delete file:${eachLine:1}"
        rm -f "${eachLine:1}"
      fi
      # ディレクトリの再帰的削除
      if [ ${eachLine:0:1} = "d" ]
      then
        echo "delete dir:${eachLine:1}"
        rm -fR "${eachLine:1}"
      fi
      # pkgutilによるインストール情報の削除
      if [ ${eachLine:0:1} = "p" ]
      then
        echo "forget pkg:${eachLine:1}"
        pkgutil --forget "${eachLine:1}"
      fi
      # ディレクトリが空の場合、そのディレクトリを削除
      if [ ${eachLine:0:1} = "c" ]
      then
        # .DS_Storeは削除しておく
        find "${eachLine:1}" -name .DS_Store -delete
        # 指定されたディレクトリがある場合だけ作業する。
        if [ -d "${eachLine:1}" ];
        then
          # findコマンドに絶対パスを渡すとだめな場合があるので、相対パスで渡す
          pushd "${eachLine:1}"
          cd ..
          find `basename "${eachLine:1}"` -type d -empty -delete
          popd
        fi
      fi
    fi
  done
  echo "----------"
done


