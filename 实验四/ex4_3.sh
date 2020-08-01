#!sur/bin/env bash
while getopts "niuafs:h" opt; do
  case $opt in
    n)
      more +2 web_log.tsv | awk -F\\t --posix '$1 !~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ {print $1}'|sort|uniq -c|sort -nr|head -n 100 >> result4_3_1.txt
      ;;
    i)
      more +2 web_log.tsv | awk -F\\t --posix '$1 ~ /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ {print $1}'|sort|uniq -c|sort -nr|head -n 100 >> result4_3_2.txt
      ;;
    u)
      more +2 web_log.tsv | awk -F\\t '{print $5}'|sort|uniq -c|sort -nr|head -n 100 >> result4_3_3.txt
      ;;
    a)
      more +2 web_log.tsv | awk -F\\t '{print $6}'|sort|uniq -c|awk '{sum+=$1;a[$1]=$2}END{for(i in a) {printf "%d----%.4f%s\n",a[i],i/sum*100,"%"}}' >> result4_3_4.txt
      ;;
    f)
      echo "403:" >> result4_3_5.txt
      more +2 web_log.tsv | awk -F\\t --posix '$6 ~ /403/ {print $5}'|sort|uniq -c|sort -nr|head -n 10 >> result4_3_5.txt
      echo "404:" >> result4_3_5.txt
      more +2 web_log.tsv | awk -F\\t --posix '$6 ~ /404/ {print $5}'|sort|uniq -c|sort -nr|head -n 10 >> result4_3_5.txt
      ;;
    s)
      more +2 web_log.tsv | awk -F\\t '{if($5=="'$OPTARG'") print $1}'|sort|uniq -c|sort -nr|head -n 100 >> result4_3_6.txt
      ;;
    h)
      echo "Usage: bash script_log.sh [option] [parameter]"
      echo "-n 统计访问来源主机TOP 100和分别对应出现的总次数"
      echo "-i 统计访问来源主机TOP 100 IP和分别对应出现的总次数"
      echo "-u 统计最频繁被访问的URL TOP 100"
      echo "-a 统计不同响应状态码的出现次数和对应百分比"
      echo "-f 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
      echo "-s 给定URL输出TOP 100访问来源主机"
  esac
done
