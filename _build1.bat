@ECHO OFF

CD C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_ruby
ruby generate_recents.rb

ruby convert_md_to_yml.rb

CD ..
jekyll build --verbose --config _config1.yml

PAUSE
