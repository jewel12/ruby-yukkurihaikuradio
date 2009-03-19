$KCODE = 's'
require 'rubygems'
require 'aqtk'
require 'open-uri'
require 'rexml/document'
require 'kconv'

# はてなハイクAPI参照
PUBLIC_TIMELINE_URI = "http://h.hatena.ne.jp/api/statuses/public_timeline.xml"

INTERVAL = 60*3  # 秒

#
# YukkuriHR
#
class YukkuriHR

  def run_yukkuri_process
    # INTERVAL毎にゆっくりする
    loop do
      begin
        yukkuri( "私は最終人道兵器ゆっくりDJちゃん、お便りを紹介するよー。" )
        parse_timeline_xml
        yukkuri( make_sentence )
        yukkuri( "でわでわ、次もゆっくりしていってね！！" )
      rescue => error
        puts error
        yukkuri( "エラーですが、あわてるな、孔明の罠だ。" )
      end
          
        sleep( INTERVAL )
    end
  end


  # タイムラインのXMLデータを取得、解析
  def parse_timeline_xml
    @data_set    = Hash.new  # 最終的に読ませるデータが格納される
    max_stars    = -1        # はてなスター数の最高値
    
    timeline_xml = REXML::Document.new( open( PUBLIC_TIMELINE_URI ) )
     
    timeline_xml.elements.each("*/status") do |status|
    
      # 現在の星の最高値よりも、現在読み込んでいる投稿の方が星が多いなら各ノードのデータを取り込む。
      # url等は削除し、ある程度多い文字数の内容でないと次点を読みにいく。
      if ( status.elements["favorited"].text.to_i > max_stars )
        keyword = status.elements["keyword"].text
        content = status.elements["text"].text.split(/=/)[-1]  # textの中身が「キーワード名=本文」という形式への対処
        
        content.sub!( /http:\/\/.+/, "" ) # 画像などは改行されるので、http://から改行までを置き換える。超適当。
        
        if ( keyword.split(//s).length >= 1 && content.split(//s).length > 4 ) # キーワードは1文字以上、投稿内容は4文字以上
          @data_set[:keyword] = keyword.tosjis
          @data_set[:content] = content.tosjis
          @data_set[:name]    = status.elements["user/name"].text
          
          max_stars = status.elements["favorited"].text.to_i
        end
      end
    end
  end
  
  
  # お喋りの内容
  def make_sentence
    sentence = "はてな県はてな市のid" + @data_set[:name] + "さんから"
    sentence << @data_set[:keyword] + "についてのお便りです。"
    sentence << @data_set[:content] + "だってさ"
    
    return sentence
  end
  
  
  # ゆっくりする
  def yukkuri( sentence )
    AquesTalk::Da.play_sync( sentence, 100 )
  end

end

#
# Main
#
start_comment = <<EOF
ピーピーガーガーピーピーガーガー
ゆっくりハイクラジオが起動しました。
EOF

AquesTalk::Da.play_sync( start_comment, 100)

yhr = YukkuriHR.new
yhr.run_yukkuri_process
