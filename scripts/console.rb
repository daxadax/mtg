ENV['test'] = '1'

system "bundle exec irb -I. -r lib/mtg.rb"
