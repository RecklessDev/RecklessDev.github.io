gruntThread = Thread.new { system "grunt watch" }
sleep(2.0)
jekyllThread = Thread.new { system "bundle exec jekyll serve --config _config.yml,_config-dev.yml --watch" }
