
CD C:\Users\David\Documents\OneDrive\Documents\My Documents\GitHub\dmfbsh.github.io\_ruby
ruby generate_recents.rb

ruby convert_md_to_yml.rb

CD ..\1shropshire\updates
CALL jekyll build --verbose --config _config.yml

COPY _site\1-updateslist.html ..\..\_includes

CD ..\..
jekyll build --verbose --config _config1.yml
