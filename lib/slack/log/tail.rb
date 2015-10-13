require 'slack/log/tail/version'
require 'httmultiparty'
require 'faye/websocket'
require 'eventmachine'
require 'open-uri'
require 'tempfile'
require 'yaml'
require 'uri'

module Slack
  module Log
    module Tail
      class Client
        include HTTMultiParty

        base_uri 'https://slack.com/api'

        def initialize(token)
          @initialize_time = Time.now.to_i
          @token = token
          @url = self.class.post('/rtm.start', body: {token: @token})['url']
          @callbacks ||= {}
        end

        def start
          EM.run do
            ws = Faye::WebSocket::Client.new(@url)

            ws.on :open do |event|
            end

            ws.on :message do |event|
              data = JSON.parse(event.data)
              if data['type'] == 'message'
                output(Time.now, data['channel'], data['user'], data['text'])
              end
            end

            ws.on :close do |event|
              EM.stop
            end
          end
        end

        def output(time, channel, user, message)
          $stdout.puts "#{time} #{channel} #{user}  #{message}"
        end
      end
    end
  end
end
