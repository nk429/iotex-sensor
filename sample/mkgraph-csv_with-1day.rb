#!/usr/bin/env ruby
# coding: utf-8
#
# 表題: グラフ作成のためのスクリプト. CSV ファイル利用版.
#

require 'csv'
require 'date'
require 'fileutils'
require 'numo/gnuplot'

###
### デバイス毎の設定
###

# デバイス名
myid =ARGV[0] 

# 公開ディレクトリ
pubdir="/iotex/graph_1month/#{myid}"
# データ置き場
#srcdir="/iotex/graph_1month/#{myid}/"
srcdir="/home/j1428/public_html/data_csv_1day"

(DateTime.parse('#ARGV[0]}")..DateTime.now).select{|d| d.day==1}.each do |time_from|
###
### 初期化
###
# 公開ディレクトリの作成
#FileUtils.rm_rf(   pubdir ) if    FileTest.exists?( pubdir )
#FileUtils.mkdir_p(pubdir) until FileTest.exists?(pubdir)
pubdir_temp="#{pubdir}/temp/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_temp ) until FileTest.exists?( pubdir_temp )
pubdir_humi="#{pubdir}/humi/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_humi ) until FileTest.exists?( pubdir_humi )
pubdir_didx="#{pubdir}/didx/#{time_from.strftime("%Y-%m")}"
FileUtils.mkdir_p( pubdir_didx ) until FileTest.exists?( pubdir_didx )


# 欠損値
miss = 999.9

## csv ファイルに含まれる変数の一覧
#vars = [
#  "time","temp","temp2","temp3","humi","humi2","humi3",
#  "dp","dp2","dp3","pres","bmptemp","dietemp","objtemp","lux",
#  "didx","didx2","didx3"
#]


###
### データの取得とグラフの作成
### 

# 7, 30, 90, 120, 240, 360 日の幅で描画  
#[7, 30, 90, 120, 240, 360].each do |range|
#  p "#{range} days"

  # 描画範囲
#  time_from = DateTime.now - range
  
  # 配列の初期化
  ops = ["mean", "min", "max"]
  time_list = Array.new
  temp_list = Hash.new
  humi_list =Hash.new
didx_lish=Hash.new

temp_list["mean"]=Array.new
humi_lish["mean"]=Array.new
didx_list["mean"]=Array.new
  
temp_list["mean2"]=Array.new
humi_list["mean2"]=Array.new
didx_list["mean2"]=Array.new

temp_list["max"]=Array.new
humi_list["max"]=Array.new
didx_list["max"]=Array.new

temp_list["min"]=Array.new
humi_list["min"]=Array.new
didx_list["min"]=Array.new
   Dir.glob("#{srcdir}/*mean*csv").sort.each do |csv| 
    # 初期化
#    time_list     = Array.new
#    temp_list[op] = Array.new

    CSV.foreach( csv ) do |item|

      time = DateTime.parse( "#{item[0]} 00:00:00 JST" ) # 時刻
        
      # 指定期間のデータのみ配列化 (7日毎の値)
      if time>=time_from&&time<=time_from>>1&&time.min==0

        time_list.push( time )              # 時刻
        temp_list["mean"].push(item[1].to_f)
	humi_list["mean"].push(item[4].to_f)
	didx_list["mean"].push(item[15].to_f)
      end
    end
  end
  
 Dir.glob("#{srcdir}/*mean2*csv").sort.each do |csv| 

    CSV.foreach( csv ) do |item|

      time = DateTime.parse( "#{item[0]} 00:00:00 JST" ) # 時刻
        
      # 指定期間のデータのみ配列化 (7日毎の値)
      if time>=time_from&&time<=time_from>>1&&time.min==0

        time_list.push( time )              # 時刻
        temp_list["mean2"].push(item[1].to_f)
	humi_list["mean2"].push(item[4].to_f)
	didx_list["mean2"].push(item[15].to_f)
      end
    end
  end

 Dir.glob("#{srcdir}/*max*csv").sort.each do |csv| 

    CSV.foreach( csv ) do |item|

      time = DateTime.parse( "#{item[0]} 00:00:00 JST" ) # 時刻
        
      # 指定期間のデータのみ配列化 (7日毎の値)
      if time>=time_from&&time<=time_from>>1&&time.min==0

        time_list.push( time )              # 時刻
        temp_list["max"].push(item[1].to_f)
	humi_list["max"].push(item[4].to_f)
	didx_list["max"].push(item[15].to_f)
      end
    end
  end

 Dir.glob("#{srcdir}/*min*csv").sort.each do |csv| 

    CSV.foreach( csv ) do |item|

      time = DateTime.parse( "#{item[0]} 00:00:00 JST" ) # 時刻
        
      # 指定期間のデータのみ配列化 (7日毎の値)
      if time>=time_from&&time<=time_from>>1&&time.min==0

        time_list.push( time )              # 時刻
        temp_list["min"].push(item[1].to_f)
	humi_list["min"].push(item[4].to_f)
	didx_list["min"].push(item[15].to_f)
      end
    end
  end
p "plot from #{time_list[0]} to #{time_list[-1]}"
  ###
  ### 1 日ごとの統計量. グラフ化. 
  ###

  # 平均値, 最小値, 最大値の比較のグラフ
  Numo.gnuplot do
    set title: "#{ARGV[1]}(温度)"
    set ylabel:   "temperature (C)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%Y/%m/%d"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_temp_#{time_from.strftime("%Y%m%d")}.png"
    set : nokey
    set :datafile, :missing, "999.9"
    
    plot [time_list, temp_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, temp_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:3, title:"min "],
         [time_list, temp_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:3, title:"max "],
         [time_list, temp_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"black",lw:3, title:"mean2 "]

  end   

  Numo.gnuplot do
    set title: "#{ARGV[1]}(湿度)"
    set ylabel:   "humidity(%)"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%Y/%m/%d"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_humi_#{time_from.strftime("%Y%m%d")}.png"
    set : nokey
    set :datafile, :missing, "999.9"
    
    plot [time_list, temp_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, temp_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:3, title:"min "],
         [time_list, temp_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:3, title:"max "],
         [time_list, temp_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"black",lw:3, title:"mean2 "]
end
  Numo.gnuplot do
    set title: "#{ARGV[1]}(不快指数)"
    set ylabel:   "disconfort index"
    set xlabel:   "time"
    set xdata:    "time"
    set timefmt_x:"%Y-%m-%dT%H:%M:%S+00:00"
    set format_x: "%Y/%m/%d"
    set xtics:    "rotate by -60"
    set terminal: "png"
    set output:   "#{pubdir}/#{myid}_didx_#{time_from.strftime("%Y%m%d")}.png"
    set : nokey
    set :datafile, :missing, "999.9"
    
    plot [time_list, temp_list["mean"], using:'1:($2)', with:"linespoints", lc_rgb:"green", lw:3, title:"mean"],
         [time_list, temp_list["min"], using:'1:($2)', with:"linespoints", lc_rgb:"blue",  lw:3, title:"min "],
         [time_list, temp_list["max"], using:'1:($2)', with:"linespoints", lc_rgb:"red",   lw:3, title:"max "],
         [time_list, temp_list["mean2"], using:'1:($2)', with:"linespoints", lc_rgb:"black",lw:3, title:"mean2 "]

end 
end
