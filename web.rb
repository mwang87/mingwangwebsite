require 'sinatra'


helpers do
  Song = Struct.new(:title, :date, :url)
  
  def get_music()
    missme = Song.new
    missme.title = "You're Gonna Miss Me feat. Sharon"
    missme.date = "April 2013"
    missme.url = "https://dl.dropboxusercontent.com/u/9899826/Recorded%20Music/Release%20Ready/You%27re%20Gonna%20Miss%20Me%20-%20Spring%202013.mp3"
    
    
    mistletoe = Song.new
    mistletoe.title = "Mistletoe"
    mistletoe.date = "December 2012"
    mistletoe.url = "https://dl.dropboxusercontent.com/s/l8zpv50qwcyl2tw/Mistletoe.mp3?token_hash=AAFeRLAssG9NZryimn0Xih07JM2OZJfwPetlMe6yULuhZw&dl=1"
    
    
    me_and_julio = Song.new
    me_and_julio.title = "Me and Julio Down by the School Yard (Live)"
    me_and_julio.date = "May 2012"
    me_and_julio.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/Me%20and%20Julio%20by%20Marlena%20and%20the%20Wang.mp3"
    
    auld_lang_syne = Song.new
    auld_lang_syne.title = "Auld Lang Syne"
    auld_lang_syne.date = "Dec 2011"
    auld_lang_syne.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/Auld%20Lang%20Syne%20-%20Dec%202011.mp3"
    
    lucky = Song.new
    lucky.title = "Lucky"
    lucky.date = "Spring 2010"
    lucky.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/Lucky%20Spring%202010.mp3"
    
    what_i_been_looking = Song.new
    what_i_been_looking.title = "What I've Been Looking For"
    what_i_been_looking.date = "Spring 2010"
    what_i_been_looking.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/What%20I've%20Been%20Looking%20For%20-%20Spring%202010.mp3"
    
    
    baobei = Song.new
    baobei.title = "Baobei"
    baobei.date = "Dec 2008"
    baobei.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Working%20Bounces/Baobei%20Revisited%20v2.mp3"
    
    
    songs = [missme, mistletoe, me_and_julio, auld_lang_syne, lucky, what_i_been_looking, baobei]
    return songs
    
  end
end

get '/' do
    erb :homepage
end

get '/about' do
    erb :about
end


get '/music' do
    @songs = get_music
    erb :music 
end

get '/academic' do

    erb :academic 
end


