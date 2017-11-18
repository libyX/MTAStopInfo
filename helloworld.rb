# require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'securerandom'
require_relative 'mongo_helper.rb'

configure do
  @@mongo_handle = Mongo_DB.new
end
# before do
#   begin
#     if request.body.read(1)
#       request.body.rewind
#       @request_payload = JSON.parse request.body.read, { symbolize_names: true }
#     end
#   rescue JSON::ParserError => e
#     request.body.rewind
#     puts "The body #{request.body.read} was not JSON"
#   end
# end

# post '/signup' do
#   token = @@mongo_handle.signup(@request_payload[:username],
#                               @request_payload[:password])

#   return {:status => "pass", :token => token}.to_json
# end

get '/' do
  "Hello World!"
end

