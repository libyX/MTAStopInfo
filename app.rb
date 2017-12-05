# require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'securerandom'
require_relative 'local_mongo_helper.rb'
require_relative 'saas_mongo_helper.rb'

configure do
  @@local_mongo_handle = Mongo_DB_LOCAL.new
  @@saas_mongo_handle = Mongo_DB_SAAS.new
end
before do
  begin
    if request.body.read(1)
      request.body.rewind
      @request_payload = JSON.parse request.body.read, { symbolize_names: true }
    end
  rescue JSON::ParserError => e
    request.body.rewind
    puts "The body #{request.body.read} was not JSON"
  end
end

post '/signup' do
  token = @@local_mongo_handle.signup(@request_payload[:username],
                              @request_payload[:password])
  		  @@saas_mongo_handle.signup(@request_payload[:username],
                              @request_payload[:password])

  return {:status => "pass", :token => token}.to_json
end


post '/login' do
  token = @@local_mongo_handle.login(@request_payload[:username],
                               		 @request_payload[:password])
  		  @@saas_mongo_handle.login(@request_payload[:username],
                               		 @request_payload[:password])
  if token
    {:status => "pass", :token => token}.to_json
  else
    return {:status => "fail",:message => "Invalid Username or Password"}.to_json
  end
end

post '/logout' do
  status = @@local_mongo_handle.logout(@request_payload[:username])
  		   @@saas_mongo_handle.logout(@request_payload[:username])

  if status
    return {:status => "pass"}.to_json
  else
    return {:status => "fail",:message => "User not found"}.to_json
  end
end

post '/addstop' do
  auth_status = @@local_mongo_handle.authenticate(@request_payload[:username],
                                            	  @request_payload[:token])
  
  if !auth_status 
    return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
  end
  key = SecureRandom.urlsafe_base64(8)
  status = @@local_mongo_handle.add_stop(@request_payload[:username],
                                   		 @request_payload[:stop][:name],
                                   		 @request_payload[:stop][:code],key)
  		   @@saas_mongo_handle.add_stop(@request_payload[:username],
                                   		@request_payload[:stop][:name],
                                   		@request_payload[:stop][:code],key)
  if status
    return {:status => "pass" ,:key => key}.to_json
  else
    return {:status => "fail",:message => "Failed to add stop"}.to_json
  end
end

post '/getstops' do
  auth_status = @@local_mongo_handle.authenticate(@request_payload[:username],
                                          @request_payload[:token])
  
  if !auth_status 
    return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
  end

  stops = @@local_mongo_handle.get_stops(@request_payload[:username])

  if stops
    return {:status => "pass", :data => stops}.to_json
  else
    return {:status => "fail",:message => "No stops found"}.to_json
  end
end

post '/removestop' do
  auth_status = @@local_mongo_handle.authenticate(@request_payload[:username],
                                          @request_payload[:token])
  
  if !auth_status 
    return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
  end

  status = @@local_mongo_handle.delete_stop(@request_payload[:username],
                                   @request_payload[:key])
  		   @@saas_mongo_handle.delete_stop(@request_payload[:username],
                                   @request_payload[:key])
  if status
    return {:status => "pass" }.to_json
  else
    return {:status => "fail",:message => "Failed to remove stop"}.to_json
  end
end

post '/updatestop' do
  auth_status = @@local_mongo_handle.authenticate(@request_payload[:username],
                                          @request_payload[:token])
  
  if !auth_status 
    return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
  end

  status = @@local_mongo_handle.update_stop(@request_payload[:username],
                                    @request_payload[:key],
                                    @request_payload[:stop][:name],
                                    @request_payload[:stop][:code])
  status = @@saas_mongo_handle.update_stop(@request_payload[:username],
                                    @request_payload[:key],
                                    @request_payload[:stop][:name],
                                    @request_payload[:stop][:code])
  if status
    return {:status => "pass" }.to_json
  else
    return {:status => "fail",:message => "Failed to update stop"}.to_json
  end
end

get '/' do
  redirect '/login.html'
end

