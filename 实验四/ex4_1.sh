#!/sur/bin/env bash

while getopts f:l:q:c:m:th OPT;do
  case $OPT in
    f)
      former=$OPTARG
      echo "请输入待修改文件的扩展名(包括\".\")"
      read extention
      rename 's/^/'$former'/' *$extension
      ;;
    l)
      last=$OPTARG
      echo "请输入待修改文件的扩展名(包括\".\")"
      read extention
      rename 's/'$extention'/'$last''$extention'/' *$extention
      ;;
    q)
      ratio=$OPTARG
      find ./ -regex '.*\(jpg\|JPG\|jpeg\)' convert -quality $ratio
      ;;
    m)
      text=$OPTARG
      convert  -draw 'text 0,0 "'$text'"'  -fill 'rgba(255, 255, 255, 0.5)'  -pointsize 200  -font Droid Sans  -gravity center  *.jpg  watermarked_%d.jpg
      ;;
    t)
      mogrify -format png *.jpg
      mogrify -format svg *.jpg
      ;;
    h)
      echo "Usage: bash image.sh [optinon] [parameter] 
      -f  统一添加文件名前缀
      -l  统一添加文件名后缀
      -q  对jpeg格式图片进行图片质量压缩
      -m  对图片批量添加自定义文本水印
      -t  将png/svg图片统一转换为jpg格式图片
      "
      ;;
    \?)
      echo "failed"
      exit 1
      ;;
  esac
done
