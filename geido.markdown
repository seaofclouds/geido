Geido is the aesthetic of process:
  *Minimal* title, tag, body, save.
  *Modular* plugins make it easy to create custom content and enable additional functionality.
  *Themeable* tweak the default theme, or create your own and share it on github.
  *Self Hosted* Up and running on Heroku in five minutes or less.
  *Open* create commons license http://creativecommons.org/licenses/by-sa/3.0/us/


### CURRENT GEIDO ARCHITECTURE:
* right now, each post is a linear conglomerate of content that's defined in each post, and within a tag.
* a tag is currently representative of both content type and means of organization.
* maybe this is okay, maybe it's convoluted.

# RETHINKING GEIDO ARCHITECTURE:
* change nomenclature: current tags/plugins become content types.
* we still have tags, but they are for organization of content, and stylistically implemented as a subset of themes.
* content is only one image, or one block of text, or one X
* multiple content items can be included in a post, (which is a type of content) using special tags, or a post builder.
* new post form has top tabs (like tumblr) allowing user to shift content types.
* default content type is configurable (for news it could be press release, for status it could be status, etc)

## content:
* content is what we now consider a tag and a post.
* content defines the information that is displayed. this may be an image, or video, or text, or link, sidebar items, home page widgets, etc.
* each content type may have a _form.haml, _content.haml, _name.sass, name.rb, and readme.
* each content type has an auto generated tiny url that can be customized by user.
* _form.haml is included in the create a post form.
* _content.haml is displayed to users and amended to the theme _post.haml
* _name.sass is the stylesheet
* name.rb is used to configure the content-type if necessary.
* path: /content_type/d3wa

## posts:
* posts are a type of content that are a conglomerate of one or more content-types. this is one of a default content types that ships with geido.
* example: you may create a post that is composed of several types of content - a video, 4 images, and several text blocks. (email newsletter)
* you can include content items within a post with simple mustache-like tags that get processed: {{url #d3wa}} or {{image #logo, small}} would embed the html for url with id d3wa, or the small logo, respectively.
* alternatively, we can create posts using a post builder, which is similar to our current post form, except it allows for adding multiple redundant content types instead of just one.

## themes:
* themes are the default layout, style and functionality for a site.
* themes have an index.haml, list.haml, show.haml, _post.haml, themename.sass and themename.rb
* themename.rb has any routes and custom handlings necessary to support the look and functionality of the theme.
* themes can be overridden by tags

## tags:
* tags are used to organize content, and to customize the display of a series of posts within the context of the selected tag.
* visually, tags are a subset of themes, and are structured and defined the same way.
* tags override the layout style and functionality of themes.
* themename.rb overrides theme.rb (formerly routes.rb ?)
* index.haml overrides the theme index.haml
* _tag.sass can be included within the theme.sass to amend/alter the style 
* tagname.haml can be included to override the theme list.haml view replacement

## plugins:
* plugins are a way to extend the functionality of geido.
* plugins can manipulate content. example: pull content from vimeo and populate the screencast type"
* maybe plugins are the same as content types...


## creating a post:
* click "new post (+)" from the admin menu
* choose the content-type you would like to add from the "select content-type" menu, and click (+).
* a form is displayed specific to the content-type you have chosen, and the  "select content-type" menu is displayed beneath.
* enter information in the content-type form.
* click save or save as draft. draft items are hidden to unauthenticated users.
* repeat this process for each content type you would like to add.
* users can 
* this process creates a post that is formatted linearly according to the order that each content type was added. an example may be [text] [image] [video] [text]
* advanced usage may permit directly editing the