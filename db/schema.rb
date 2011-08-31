# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 0) do

  create_table "dumps", :force => true do |t|
    t.text "metadata", :limit => 2147483647
  end

  create_table "movies", :force => true do |t|
    t.string   "category"
    t.integer  "flixster_id"
    t.integer  "imdb_id"
    t.string   "title"
    t.string   "genres"
    t.text     "synopsis"
    t.string   "mpaa_rating"
    t.integer  "year"
    t.integer  "runtime"
    t.string   "studio"
    t.string   "director"
    t.string   "critics_consensus"
    t.string   "critics_rating"
    t.integer  "critics_score"
    t.string   "audience_rating"
    t.integer  "audience_score"
    t.string   "poster_thumbnail"
    t.string   "poster_profile"
    t.string   "poster_detailed"
    t.string   "poster_original"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "movies", ["flixster_id"], :name => "idx_unique_flixster_id", :unique => true

  create_table "photos", :force => true do |t|
    t.string   "biz"
    t.string   "src"
    t.string   "caption"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["src"], :name => "idx_unique_photos_src", :unique => true

  create_table "places", :force => true do |t|
    t.string   "biz"
    t.string   "name"
    t.decimal  "rating",                   :precision => 10, :scale => 1
    t.string   "phone"
    t.integer  "numreviews"
    t.string   "price"
    t.string   "category"
    t.string   "city"
    t.string   "country",    :limit => 45
    t.string   "address"
    t.decimal  "latitude",                 :precision => 20, :scale => 16
    t.decimal  "longitude",                :precision => 20, :scale => 16
    t.string   "hours"
    t.integer  "numphotos"
    t.decimal  "score",                    :precision => 10, :scale => 1
    t.text     "bizinfo"
    t.text     "snippets"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["biz"], :name => "idx_unique_places_biz", :unique => true

  create_table "reviews", :force => true do |t|
    t.string   "srid"
    t.string   "biz"
    t.decimal  "rating",     :precision => 10, :scale => 0
    t.string   "date"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["srid"], :name => "idx_unique_reviews_srid", :unique => true

  create_table "users", :force => true do |t|
    t.string   "facebook_access_token"
    t.string   "facebook_id"
    t.string   "facebook_name"
    t.boolean  "facebook_can_publish"
    t.string   "udid"
    t.text     "metadata"
    t.datetime "joined_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["facebook_id"], :name => "idx_unique_facebook_id", :unique => true

end
