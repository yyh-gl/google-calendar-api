# coding: utf-8

require 'active_support/time'
require_relative 'calendar.rb'

messages = [{type: 'text', text: '↓明日の予定↓'}]

cal = Calendar.new
events = cal.fetch_calender_events
events.each do |e|
  if e.start.date.present?
    start = Date.parse(e.start.date)
    str_start = e.start.date + ' 一日中'
  else
    start = Date.parse(e.start.date_time.strftime('%Y-%m-%d'))
    str_start = e.start.date_time.strftime('%Y-%m-%d %H:%M:%S 〜')
  end
  from = Date.today
  untill = Date.today + 1.day
  
  if from <= start && start < untill
    puts "- #{e.summary} (#{str_start})"
    messages << {type: 'text', text: "#{e.summary} (#{str_start})"}
  end
end

messages << {type: 'text', text: '↑以上↑'}

cmd = <<"EOS"
curl -X POST \
-H 'Content-Type:application/json' \
-H 'Authorization: Bearer {#{ENV['ACCESS_TOKEN']}}' \
-d '{
    "to": "#{ENV['CHANNEL_ID']}",
    "messages": #{messages.to_json}
}' https://api.line.me/v2/bot/message/push
EOS

exec(cmd)
