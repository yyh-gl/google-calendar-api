# coding: utf-8
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Meeting Notification by Slack'.freeze
CLIENT_SECRETS_PATH = 'client_secret.json'.freeze
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             'calendar-ruby-quickstart.yaml').freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

class Calendar
  # Initialize the API
  def initialize
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end
  
  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' +
           'resulting code after authorization'
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end
  
  def fetch_calender_event
    # Fetch the next 100 events for the user
    calendar_id = 'mmiki@mikilab.doshisha.ac.jp'
    response = @service.list_events(calendar_id,
                                    max_results: 100,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: Time.now.iso8601)
    return response.items unless response.items.empty?
    puts 'No upcoming events found'
  end
end


#####################################################
# Sample program
#####################################################

# get event title with start date or date time
cal = Calendar.new
events = cal.fetch_calender_event
events.each do |e|
  start = e.start.date || e.start.date_time
  puts "- #{e.summary} (#{start})"
end
