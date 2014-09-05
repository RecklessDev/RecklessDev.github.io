jekyllThread = Thread.new { 
	system "bundle exec jekyll serve --config _config.yml,_config-dev.yml --watch" 
}

gruntThread = Thread.new { system "grunt watch" }

jekyllThread.join
gruntThread.join

at_exit {
  jekyllThread.exit
  gruntThread.exit
}