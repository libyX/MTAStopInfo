require 'mongo'
require 'json'
require "base64"
require 'securerandom'
require 'bcrypt'

class Mongo_DB
  def initialize
    # # client_host = ['127.0.0.1:12345, 127.0.0.1:12346']
    # # client_host = ['127.0.0.1:12345',
    # #                          user: 'rx294',
    # #                          password: 'cloudproject123',database: 'mtaprofiles']
    # # client_options = {
    # #   database: 'mtaprofiles',
    # #   # replica_set: '3d62adc37bad4f628cf5e8db921ce445',
    # #   user: 'rx294',
    # #   password: 'cloudproject123'
    # # }
    # # @client = Mongo::Client.new(['ds113626.mlab.com:13626'],
    # #                          user: 'rx294',
    # #                          password: 'cloudproject123',database: 'mtaprofiles')
    @client = Mongo::Client.new(['127.0.0.1:27017'],
                             user: 'rx294',
                             password: 'cloudproject123',
                             # replica_set: 'rs-ds113626',
                             database: 'mtaprofiles')

    # @saas_client = Mongo::Client.new(['ds113626.mlab.com:13626'],
    #                          user: 'rx294',
    #                          password: 'cloudproject123',
    #                          database: 'mtaprofiles')
    # @client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mtaprofiles')
  end

  def test
    return 'asd'
  end

  def signup(username,password)
    coll = @client[username]
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    doc = {"passwordhash" => password_hash,"salt" => password_salt, "token"=> generate_token ,"data":{}}
    coll.insert_one(doc)
    doc["token"]
  end

  def logout(username)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first
    doc['token'] = nil
    coll.update_one({"_id" => doc["_id"]}, doc)
    return true
  end

  def get_user(username)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    coll.find.first
  end

  def login(username,password)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first

    if doc['passwordhash'] == BCrypt::Engine.hash_secret(password, doc['salt'])
      doc['token'] = generate_token
      coll.update_one({"_id" => doc["_id"]}, doc)
      doc["token"]
    else
      return false
    end
  end

  def authenticate(username,token)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first

    if doc['token'] == token
      return true
    else
      return false
    end
  end

  def get_stops(username)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    coll.find.first['data']
  end

  def add_stop(username,stop_name,stop_code)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first
    # stop.JSON.parse!
    # puts stop
    doc['data'][SecureRandom.urlsafe_base64(8)] = {'name'=>stop_name,'code'=>stop_code}
    coll.update_one({"_id" => doc["_id"]}, doc)
    return true
  end

  def update_stop(username,key,stop_name,stop_code)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first
    doc['data'][key] = {'name'=>stop_name,'code'=>stop_code}
    coll.update_one({"_id" => doc["_id"]}, doc)
    return true
  end

  def delete_stop(username,key)
    return false unless @client.database.collection_names.include?(username)
    coll = @client[username]
    doc = coll.find.first
    doc['data'].delete(key)
    coll.update_one({"_id" => doc["_id"]}, doc)
    return true
  end

  def drop_all_collections
    json = {'collections' => []}
    db = @client.database
    db.collection_names.each do |collection|
      db[collection].drop()
    end
  end

  def generate_token
    SecureRandom.urlsafe_base64(64)
  end
end

db = Mongo_DB.new
# # db.test
# # db.drop_all_collections
db.signup('test4','Test3')
# # token = db.login('test3','Test3')
# # puts db.authenticate('test3',token)
# # doc = db.get_user('test')
# # stop = {"name"=>"name2","code"=>"10002"}
# # db.add_stop('test3',stop)
# # doc = db.update_stop('test','s7i6BS5clCM',stop)
# puts db.get_stops('test3')