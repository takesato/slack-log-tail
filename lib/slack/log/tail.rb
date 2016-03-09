require 'slack/log/tail/version'
require 'httmultiparty'
require 'faye/websocket'
require 'eventmachine'
require 'open-uri'
require 'tempfile'
require 'yaml'
require 'uri'
require 'colored'

module Slack
  module Log
    module Tail
      class Client
        include HTTMultiParty

        base_uri 'https://slack.com/api'

        def initialize(token)
          @initialize_time = Time.now.to_i
          @token = token
          list_users
          list_channels
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
              send(data['type'], data)
            end

            ws.on :close do |event|
              EM.stop
            end
          end
        end


        def hello(data)
        end

        def message(data)
          return if data['hidden'] == true
          #return if data['message'] == ''
          return unless @times[data['channel']]
          time = Time.now.strftime("%H:%M:%S").bold
          channel = "##{@channels[data['channel']]}".to_s.ljust(22)[0..21].green
          user = @users[data['user']].to_s.ljust(20)[0..19].yellow
          message =  data['text']
          sep = "|".green
          $stdout.puts "#{time} #{channel} #{user} #{sep} #{message}"
          #$stdout.puts data
        end

        def user_typing(data)
        end

        def channel_marked(data)
        end

        def channel_created(data)
        end

        def channel_joined(data)
        end

        def channel_left(data)
        end

        def channel_deleted(data)
        end

        def channel_rename(data)
        end

        def channel_archive(data)
        end

        def channel_unarchive(data)
        end

        def channel_history_changed(data)
        end

        def dnd_updated(data)
        end

        def dnd_updated_user(data)
        end

        def im_created(data)
        end

        def im_open(data)
        end

        def im_close(data)
        end

        def im_marked(data)
        end

        def im_history_changed(data)
        end

        def group_joined(data)
        end

        def group_left(data)
        end

        def group_open(data)
        end

        def group_close(data)
        end

        def group_archive(data)
        end

        def group_unarchive(data)
        end

        def group_rename(data)
        end

        def group_marked(data)
        end

        def group_history_changed(data)
        end

        def file_created(data)
        end

        def file_shared(data)
        end

        def file_unshared(data)
        end

        def file_public(data)
        end

        def file_private(data)
        end

        def file_change(data)
        end

        def file_deleted(data)
        end

        def file_comment_added(data)
        end

        def file_comment_edited(data)
        end

        def file_comment_deleted(data)
        end

        def pin_added(data)
        end

        def pin_removed(data)
        end

        def presence_change(data)
        end

        def manual_presence_change(data)
        end

        def pref_change(data)
        end

        def user_change(data)
        end

        def team_join(data)
        end

        def star_added(data)
        end

        def star_removed(data)
        end

        def reaction_added(data)
        end

        def reaction_removed(data)
        end

        def emoji_changed(data)
        end

        def commands_changed(data)
        end

        def team_plan_change(data)
        end

        def team_pref_change(data)
        end

        def team_rename(data)
        end

        def team_domain_change(data)
        end

        def email_domain_changed(data)
        end

        def team_profile_change(data)
        end

        def team_profile_delete(data)
        end

        def team_profile_reorder(data)
        end

        def bot_added(data)
        end

        def bot_changed(data)
        end

        def accounts_changed(data)
        end

        def team_migration_started(data)
        end

        def reconnect_url(data)
        end

        def dubteam_created(data)
        end

        def dubteam_updated(data)
        end

        def dubteam_self_added(data)
        end

        def subteam_self_removed(data)
        end

        def list_users
          @users = {}
          self.class.post('/users.list', body: {token: @token})['members'].each{|member| @users[member['id']] = member['profile']['real_name'] }
        end

        def list_channels
          @channels = {}
          @times = {}
          c = self.class.post('/channels.list', body: {token: @token})['channels']
          c.each{|channel| @channels[channel['id']] = channel['name'] }
          c.select{|c| c['name'].include?('times') }.each{|channel| @times[channel['id']] = 1 }
          c.select{|c| c['name'].include?('hobby') }.each{|channel| @times[channel['id']] = 1 }
          c.select{|c| c['name'].include?('sakebu') }.each{|channel| @times[channel['id']] = 1 }
        end
      end
    end
  end
end
