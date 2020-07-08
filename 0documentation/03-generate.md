---
layout: documentation
title: Generate the Web Pages
---

## Generate the Web Pages
{: .mt-4}

1. Convert the MD files into the YML data files - there is a Ruby script to do this:

   `convert_md_to_yml.rb`

2. Generate a YML data file of recent photos - there is a Ruby script to do this:

   `generate_recents.rb`

3. Generate the local copy of the statis Web Site:

   `jekyll build`

4. Commit the changes to the GitHub repository (master branch) - this is done using the GitHub desktop application
