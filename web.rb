require 'sinatra'


helpers do
    Song = Struct.new(:title, :date, :url)

    def get_music()
    	backhere = Song.new
        backhere.title = "Back Here"
        backhere.date = "Winter 2014"
        backhere.url = "https://www.dropbox.com/s/cib5dgf3kgs3fe0/backhere%20v9.mp3?dl=1"
        
        whitechristmas = Song.new
        whitechristmas.title = "White Christmas"
        whitechristmas.date = "Winter 2014"
        whitechristmas.url = "https://www.dropbox.com/s/xek0paw8zmmsqf7/White%20Christmas%20v6.mp3?dl=1"
    
        winterwonderland = Song.new
        winterwonderland.title = "Winter Wonderland"
        winterwonderland.date = "Dec 2013"
        winterwonderland.url = "https://www.dropbox.com/s/tz330gmdmb1t2gc/Winter%20Wonderland%20v2.mp3?dl=1"

        
        missme = Song.new
        missme.title = "You're Gonna Miss Me feat. Sharon"
        missme.date = "April 2013"
        missme.url = "https://dl.dropboxusercontent.com/u/9899826/Recorded%20Music/Release%20Ready/You%27re%20Gonna%20Miss%20Me%20-%20Spring%202013.mp3"


        goodnight = Song.new
        goodnight.title = "Goodnight Sweetheart"
        goodnight.date = "April 2013"
        goodnight.url = "http://dl.dropboxusercontent.com/s/9gd0gbyjzb8srky/Goodnight%20Sweetheart%20v6.mp3"

        waffles = Song.new
        waffles.title = "Waffle Song"
        waffles.date = "Feb 2013"
        waffles.url = "https://www.dropbox.com/s/8oxfwycyfjl6pqw/Waffles%20v3.mp3?dl=1"

        mistletoe = Song.new
        mistletoe.title = "Mistletoe"
        mistletoe.date = "December 2012"
        mistletoe.url = "https://dl.dropboxusercontent.com/s/l8zpv50qwcyl2tw/Mistletoe.mp3?token_hash=AAFeRLAssG9NZryimn0Xih07JM2OZJfwPetlMe6yULuhZw&dl=1"


        me_and_julio = Song.new
        me_and_julio.title = "Me and Julio Down by the School Yard (Live) Feat. Marlena"
        me_and_julio.date = "May 2012"
        me_and_julio.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/Me%20and%20Julio%20by%20Marlena%20and%20the%20Wang.mp3"

        hero = Song.new
        hero.title = "Hero - Enrique feat. Dave"
        hero.date = "Jan 2012"
        hero.url = "https://www.dropbox.com/s/pz4fxke1cl1626s/Hero%20v11.mp3?dl=1"
        
        auld_lang_syne = Song.new
        auld_lang_syne.title = "Auld Lang Syne"
        auld_lang_syne.date = "Dec 2011"
        auld_lang_syne.url = "http://dl.dropbox.com/u/9899826/Recorded%20Music/Release%20Ready/Auld%20Lang%20Syne%20-%20Dec%202011.mp3"

        lucky = Song.new
        lucky.title = "Lucky feat. Sheryl"
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


        songs = [whitechristmas, backhere, winterwonderland, missme, goodnight, mistletoe, me_and_julio, hero, auld_lang_syne, lucky, what_i_been_looking, baobei]
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

get '/projects' do

    erb :projects 
end


