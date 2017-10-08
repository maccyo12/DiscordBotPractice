require 'discordrb'
require 'json'

# json読み込み
File.open("setting.json") do |file|
    $jsonSetting = JSON.load(file)
end

bot = Discordrb::Commands::CommandBot.new token:$jsonSetting["token"], client_id: $jsonSetting["client_id"], prefix: '?'

#ユーザーランダム取得
bot.command :rand do |event, *code|
    #Voiceチャンネル参加者一覧取得
    #とりあえずVoiceチャンネルにいる人全員のuser_id取得
    voiceHash = event.server.voice_states

    #サーバーに参加している全員のuser_id取得
    userList = event.server.members

    #順番に照会
    userNames = []
    voiceHash.each{|key,value|
        userData =  userList.find{|k,val| k == key}
        userNames.push(userData.name)
    }

    # #テスト用に適当な人追加
    # for index in 1..20 do
    #     userNames.push('Bot-' + index.to_s)
    # end

    memberNum = code

    if memberNum.empty?
        #自動分割
        #MAX4人で分けられるだけ
        for index in 1..(userNames.count.div(4)) do
            memberNum.push(4)
        end
    end

    #並び替え
    userNames.shuffle!

    #出力用文字列(一気に吐き出したいので)
    exportStr = []

    #引数で指定した個数、先頭から吐き出し
    groupNum = 1
    memberNum.each{|arg|
        exportStr.push('----- グループ' + groupNum.to_s + ' -----')
        retVal = userNames.shift(arg.to_i)
        retVal.each{|name|
        exportStr.push(name)
        }
        groupNum = groupNum + 1
    }

    #残り吐き出し
    if !userNames.empty?
        exportStr.push('----- グループ' + groupNum.to_s + ' -----')
        userNames.each{|name|
            exportStr.push(name)
        }
    end

    #出力
    if exportStr.empty?
        event.send_message('対象となる人がいません...')        
    else
        event.send_message(exportStr.join("\n"))        
    end
end
bot.run