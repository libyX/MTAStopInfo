# require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'securerandom'
require_relative 'mongo_helper.rb'

# class App < Sinatra::Base
#   # helpers do
#   #   mongo_handle = Mongo_DB.new
#   # end
#   # def initialize
#   #   @mongo_handle = Mongo_DB.new
#   # end
  configure do
    @@mongo_handle = Mongo_DB.new
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
    token = @@mongo_handle.signup(@request_payload[:username],
                                @request_payload[:password])

    return {:status => "pass", :token => token}.to_json
  end

  post '/login' do
    token = @@mongo_handle.login(@request_payload[:username],
                                 @request_payload[:password])
    if token
      {:status => "pass", :token => token}.to_json
    else
      return {:status => "fail",:message => "Invalid Username or Password"}.to_json
    end
  end

  post '/logout' do
    status = @@mongo_handle.logout(@request_payload[:username])

    if status
      return {:status => "pass"}.to_json
    else
      return {:status => "fail",:message => "User not found"}.to_json
    end
  end

  post '/addstop' do
    auth_status = @@mongo_handle.authenticate(@request_payload[:username],
                                              @request_payload[:token])
    
    if !auth_status 
      return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
    end

    status = @@mongo_handle.add_stop(@request_payload[:username],
                                     @request_payload[:stop][:name],
                                     @request_payload[:stop][:code])
    if status
      return {:status => "pass" }.to_json
    else
      return {:status => "fail",:message => "Failed to add stop"}.to_json
    end
  end

  post '/getstops' do
    auth_status = @@mongo_handle.authenticate(@request_payload[:username],
                                            @request_payload[:token])
    
    if !auth_status 
      return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
    end

    stops = @@mongo_handle.get_stops(@request_payload[:username])

    if stops
      return {:status => "pass", :data => stops}.to_json
    else
      return {:status => "fail",:message => "No stops found"}.to_json
    end
  end

  post '/removestop' do
    auth_status = @@mongo_handle.authenticate(@request_payload[:username],
                                            @request_payload[:token])
    
    if !auth_status 
      return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
    end

    status = @@mongo_handle.delete_stop(@request_payload[:username],
                                     @request_payload[:key])
    if status
      return {:status => "pass" }.to_json
    else
      return {:status => "fail",:message => "Failed to remove stop"}.to_json
    end
  end

  post '/updatestop' do
    auth_status = @@mongo_handle.authenticate(@request_payload[:username],
                                            @request_payload[:token])
    
    if !auth_status 
      return {:status => "fail",:message => "Invalid Username or Session Key"}.to_json
    end

    status = @@mongo_handle.update_stop(@request_payload[:username],
                                      @request_payload[:key],
                                      @request_payload[:stop][:name],
                                      @request_payload[:stop][:code])
    if status
      return {:status => "pass" }.to_json
    else
      return {:status => "fail",:message => "Failed to update stop"}.to_json
    end
  end
#   run!
# end