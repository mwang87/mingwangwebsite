require 'sinatra'

get '/' do
    musicfile = File.open("views/music.html", "rb")
    @music_html = musicfile.read
    @music_html = @music_html.gsub(/\n/," ") 
    erb :homepage
end



