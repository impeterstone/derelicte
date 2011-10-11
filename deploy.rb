#!/usr/bin/ruby

puts "-----> Precompiling Rails Assets"
`rake assets:precompile`
puts "-----> Committing new code to git"
`git add .`
`git commit -am "Quick deploy"`
puts "-----> Pushing to Github"
`git push origin master`
puts "-----> Deploying to Heroku"
`git push heroku master`