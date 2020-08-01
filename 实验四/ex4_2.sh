#!sur/bin/env bash

while getopts "gpnah" opt; do
  case $opt in
    g)
      #取球员数量
      age=$(more +2 worldcupplayerinfo.tsv | awk -F\\t \
        '{if($6<20)a+=1;\
          else if($6>=20&&$6<=30)b+=1;\
          else if($6>30)c+=1}\
          END{print a,b,c}')
      #取和
      for i in $age ; do
        d=$(($d+$i))
      done
      #输出
      A=("20岁以下球员数量及百分比: " "[20岁-30岁]的球员数量及百分比: " "30岁以上球员数量及百分比: ")
      for i in $age ; do
        proportion=$(echo "scale=2; $i * 100 / $d" | bc)
        echo ${A[$ii]} $i  "|"  $proportion% >> result4_2.txt
        let ii++
      done
      ;;

      p)
        #取不同位置的球员数量
        position=$( more +2 worldcupplayerinfo.tsv | awk -F\\t \
          '{if($5=="Goalie")  a+=1;\
            else if($5=="Defender" || $5=="Défenseur") b+=1;\
            else if($5=="Midfielder") c+=1;\
            else if($5=="Forward") d+=1}\
            END{print a,b,c,d}')
        for i in $position ; do
          e=$(($e+$i))
        done
        #输出
        A=("Goalie球员数量及百分比 :" "Defender球员数量及百分比 :" "Middle球员数量及百分比 :" "Forward球员数量及百分比 :") 
        for i in $position ; do
          proportion=$(echo "scale=2; $i * 100 / $e" | bc)
          echo ${A[$ii]} $i  "|"  $proportion% >> result4_2.txt
          let ii++
        done                
        ;;

      n)
        #取名字长度
        namelength=$( more +2 worldcupplayerinfo.tsv | awk -F\\t '{print length($9)}' )
        #计算最长、最短长度
        longest=0
        shortest=100
        for i in $namelength ; do
          if [ $i -gt $longest ]; then
            longest=$i
          fi
          if [ $i -lt $shortest ]; then
            shortest=$i
          fi
        done
        #输出
        echo 名字最长的球员有 : >> result4_2.txt
        more +2 worldcupplayerinfo.tsv | awk -F\\t '{if ( length($9)=='$longest' ) print $9}' >> result4_2.txt
        echo 名字最短的球员有 : >> result4_2.txt
        more +2 worldcupplayerinfo.tsv | awk -F\\t '{if ( length($9)=='$shortest' ) print $9}' >> result4_2.txt
        ;;
      a)
        #取年龄
        age=$( more +2 worldcupplayerinfo.tsv | awk -F\\t '{print $6}' )
        #取最大、最小年龄
        oldest=0
        youngest=100
        for i in $age ; do
          if [ $i -gt $oldest ]; then
            oldest=$i
          fi
          if [ $i -lt $youngest ]; then
            youngest=$i
          fi
        done
        #输出
        echo 年龄最大的球员有: >> result4_2.txt
        more +2 worldcupplayerinfo.tsv | awk -F\\t '{if ( $6=='$oldest' ) print $9}' >> result4_2.txt
        echo 年龄最小的球员有: >> result4_2.txt
        more +2 worldcupplayerinfo.tsv | awk -F\\t '{if ( $6=='$youngest' ) print $9}' >> result4_2.txt
       ;;
     h)
       echo "Usage: bash ex4_2.sh [option] [parameter]"
       echo "-g 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
       echo "-p 统计不同场上位置的球员数量、百分比"
       echo "-n 名字最长的球员是谁？名字最短的球员是谁？"
       echo "-a 年龄最大的球员是谁？年龄最小的球员是谁？"
    esac
  done
