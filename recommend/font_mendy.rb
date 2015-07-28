require 'rubygems'
require 'sinatra'
require 'sinatra/cross_origin'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-serializer'
require 'json'
require 'sinatra/config_file'
config_file "./config.yml"

configure do
  enable :cross_origin
end

DataMapper.setup(:default, settings.data_source)
DataMapper.finalize

get '/' do
  content_type :json
  joins = ''
  i = 0
  params.each { |k, v|
    if v.to_i > 0 && k != 'algorithm'
      joins += " JOIN data d#{i} ON u.id = d#{i}.user_id AND d#{i}.item_id = #{v} "
      i += 1
    end
  }
  similar_table = params['algorithm'] || 'similar'
  output = []

  # get top font having same keywords
  tops = repository(:default).adapter.select("SELECT DISTINCT u.id, u.name, u.layout_md5
    FROM users u
    " + joins + "
    ORDER BY RAND()
    LIMIT 1")

  if tops.length > 0
    output << {name: tops.first.name, layout_md5: tops.first.layout_md5}
    top_id = tops.first.id
    # get similar fonts to top font
    similars = repository(:default).adapter.select("SELECT DISTINCT u.name, u.layout_md5
      FROM #{similar_table} s
      JOIN users u ON s.user2_id = u.id
      WHERE user1_id = #{top_id}
      ORDER BY s.score DESC
      LIMIT 5")


    similars.each do |similar|
      output << {name: similar.name, layout_md5: similar.layout_md5}
    end
    output.to_json
  end
end
