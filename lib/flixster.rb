require 'rubygems'
require 'typhoeus'
require 'json'
require 'mysql2'

module API
  class Flixster
    @@apikey = 'x59smsrpgzapb7hbrpshdsjm'
      
    @db = Mysql2::Client.new(:host => "zoolander.clhyg7sm4xmb.us-east-1.rds.amazonaws.com", :database => "derelicte", :username => "sevenminutelabs", :password => "bluesteel")
    
    def self.top_rentals
      h = Typhoeus::Hydra.new(:max_concurrency => 1)
      
      headers_hash = Hash.new
      headers_hash['Accept'] = 'application/json'

      params_hash = Hash.new
      params_hash['apikey'] = @@apikey
      params_hash['limit'] = 50
      
      movie_urls = Array.new
      movie_details = Array.new
      
      movies = Typhoeus::Request.new("http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json", :method => :get, :params => params_hash, :headers => headers_hash)
      movies.on_complete do |response|
        movies_results = JSON.parse(response.body)
        
        movies_results['movies'].each do |m|
          movie_urls << m['links']['self']
        end
        
        # make calls to movie details for each movie url
        movie_urls.each do |u|
          r = Typhoeus::Request.new("#{u}?apikey=#{@@apikey}", :method => :get)
          r.on_complete do |response|
            movie_detail = JSON.parse(response.body)
            movie_details << movie_detail
          end
          h.queue r
        end
      end
      
      h.queue movies
      h.run
      
      self.serialize_movies(movie_details, "top_rentals")
    end
    
    def self.in_theaters
      h = Typhoeus::Hydra.new(:max_concurrency => 1)
      
      headers_hash = Hash.new
      headers_hash['Accept'] = 'application/json'

      params_hash = Hash.new
      params_hash['apikey'] = @@apikey
      params_hash['page_limit'] = 50
      
      movie_urls = Array.new
      movie_details = Array.new
      
      movies = Typhoeus::Request.new("http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json", :method => :get, :params => params_hash, :headers => headers_hash)
      movies.on_complete do |response|
        movies_results = JSON.parse(response.body)
        
        movies_results['movies'].each do |m|
          movie_urls << m['links']['self']
        end
        
        # make calls to movie details for each movie url
        movie_urls.each do |u|
          r = Typhoeus::Request.new("#{u}?apikey=#{@@apikey}", :method => :get)
          r.on_complete do |response|
            movie_detail = JSON.parse(response.body)
            movie_details << movie_detail
          end
          h.queue r
        end
      end
      
      h.queue movies
      h.run
      
      self.serialize_movies(movie_details, "in_theaters")
    end
    
    def self.serialize_movies(movie_details, category)
      # bulk insert movies into database
      # p movies.handled_response
      # p movie_details
      movie_details.each do |movie|
        ratings = movie['ratings']
        posters = movie['posters']
        
        flixster_id = movie['id']
        imdb_id = movie['alternate_ids']['imdb']
        title = @db.escape(movie['title'])
        genres = @db.escape(movie['genres'].join(','))
        synopsis = @db.escape(movie['synopsis'])
        mpaa_rating = @db.escape(movie['mpaa_rating'])
        year = movie['year']
        runtime = movie['runtime']
        studio = @db.escape(movie['studio'])
        director = !movie['abridged_directors'].first.nil? ? @db.escape(movie['abridged_directors'].first['name']) : nil
        critics_consensus = !movie['critics_consensus'].nil? ? @db.escape(movie['critics_consensus']) : nil
        critics_rating = !ratings['critics_rating'].nil? ? @db.escape(ratings['critics_rating']) : nil
        critics_score = ratings['critics_score']
        audience_rating = !ratings['audience_rating'].nil? ? @db.escape(ratings['audience_rating']) : nil
        audience_score = ratings['audience_score']
        poster_thumbnail = posters['thumbnail']
        poster_profile = posters['profile']
        poster_detailed = posters['detailed']
        poster_original = posters['original']
        
        query = "
          INSERT IGNORE INTO movies (category, flixster_id, imdb_id, title, genres, synopsis, mpaa_rating, year, runtime, studio, director, critics_consensus, critics_rating, critics_score, audience_rating, audience_score, poster_thumbnail, poster_profile, poster_detailed, poster_original, created_at, updated_at)
          VALUES ('#{category}', '#{flixster_id}', '#{imdb_id}', '#{title}', '#{genres}', '#{synopsis}', '#{mpaa_rating}', '#{year}', '#{runtime}', '#{studio}', '#{director}', '#{critics_consensus}', '#{critics_rating}', '#{critics_score}', '#{audience_rating}', '#{audience_score}', '#{poster_thumbnail}', '#{poster_profile}', '#{poster_detailed}', '#{poster_original}', NOW(), NOW())
        "
        
        res = @db.query(query)
      end
    end
  end
end

# {
#   "id": 770672122,
#   "title": "Toy Story 3",
#   "year": 2010,
#   "genres": [
#     "Animation",
#     "Kids & Family",
#     "Science Fiction & Fantasy",
#     "Comedy"
#   ],
#   "mpaa_rating": "G",
#   "runtime": 103,
#   "critics_consensus": "Deftly blending comedy, adventure, and honest emotion, Toy Story 3 is a rare second sequel that really works.",
#   "release_dates": {
#     "theater": "2010-06-18",
#     "dvd": "2010-11-02"
#   },
#   "ratings": {
#     "critics_rating": "Certified Fresh",
#     "critics_score": 99,
#     "audience_rating": "Upright",
#     "audience_score": 91
#   },
#   "synopsis": "Pixar returns to their first success with Toy Story 3. The movie begins with Andy leaving for college and donating his beloved toys -- including Woody (Tom Hanks) and Buzz (Tim Allen) -- to a daycare. While the crew meets new friends, including Ken (Michael Keaton), they soon grow to hate their new surroundings and plan an escape. The film was directed by Lee Unkrich from a script co-authored by Little Miss Sunshine scribe Michael Arndt. ~ Perry Seibert, Rovi",
#   "posters": {
#     "thumbnail": "http://content6.flixster.com/movie/11/13/43/11134356_mob.jpg",
#     "profile": "http://content6.flixster.com/movie/11/13/43/11134356_pro.jpg",
#     "detailed": "http://content6.flixster.com/movie/11/13/43/11134356_det.jpg",
#     "original": "http://content6.flixster.com/movie/11/13/43/11134356_ori.jpg"
#   },
#   "abridged_cast": [
#     {
#       "name": "Tom Hanks",
#       "characters": ["Woody"]
#     },
#     {
#       "name": "Tim Allen",
#       "characters": ["Buzz Lightyear"]
#     },
#     {
#       "name": "Joan Cusack",
#       "characters": ["Jessie the Cowgirl"]
#     },
#     {
#       "name": "Don Rickles",
#       "characters": ["Mr. Potato Head"]
#     },
#     {
#       "name": "Wallace Shawn",
#       "characters": ["Rex"]
#     }
#   ],
#   "abridged_directors": [{"name": "Lee Unkrich"}],
#   "studio": "Walt Disney Pictures",
#   "alternate_ids": {"imdb": "0435761"},
#   "links": {
#     "self": "http://api.rottentomatoes.com/api/public/v1.0/movies/770672122.json",
#     "alternate": "http://www.rottentomatoes.com/m/toy_story_3/",
#     "cast": "http://api.rottentomatoes.com/api/public/v1.0/movies/770672122/cast.json",
#     "clips": "http://api.rottentomatoes.com/api/public/v1.0/movies/770672122/clips.json",
#     "reviews": "http://api.rottentomatoes.com/api/public/v1.0/movies/770672122/reviews.json",
#     "similar": "http://api.rottentomatoes.com/api/public/v1.0/movies/770672122/similar.json"
#   }
# }


API::Flixster.top_rentals
API::Flixster.in_theaters