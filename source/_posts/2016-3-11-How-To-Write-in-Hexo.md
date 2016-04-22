---
title: Hexo
date: 2016-03-11 19:35:30
author: yosef gao
tags: hexo
categories: Others
---

Starting the server
-------------------
To view your newly created site in a browser, start the local server:
```
$ hexo server --draft --open

INFO  Hexo is running at http://0.0.0.0:4000/. Press Ctrl+C to stop.
```
This starts the server with a few extra options:

* --draft : Enables viewable "draft" posts (by default, drafts are hidden)
* --open : Open the local site in your browser

<!--more-->

Creating your first post
------------------
A good practice when starting new posts is to use the "draft" feature. Drafts will not be published by default, so you are free to make changes to other posts while keeping unfinished drafts hidden from public.

Create a new draft post with the hexo new draft command:
```
$ hexo new draft "My First Blog Post"
# creates -> ./source/_drafts/My-First-Blog-Post.md
```
To edit your draft, navigate to <font color="#c7254e">./source/_drafts/My-First-Blog-Post.md</font> and open the file with your favorite Markdown editor.

Lets add a subheading and some paragraph content to your new post...
```
---
title: My First Blog Post
tags:
---
## Hello there
This is some content.
```

{% callout info %}
#### {% fa info-circle %} Tip
The stuff between the dashes --- at the top of the markdown file is called "front-matter". It is metadata that is used by Hexo and the active theme. See the [Hexo documentation on Front-Matter](https://hexo.io/docs/front-matter.html) for more information.
{% endcallout %}

Saving changes to your Markdown files will be automatically detected by the running <font color="#c7254e">hexo server </font>and regenerated as static HTML files, **but you must refresh the browser to view the changes.**

Publishing drafts
-----------------------
When it's time to move the draft to a "live" post for the world to see, use the <font color="#c7254e">hexo publish </font>command:
```
$ hexo publish My-First-Blog-Post
```

A few things will happen when this command is run:
1. The markdown file <font color="#c7254e"> My-First-Blog-Post.md</font> moves from <font color="#c7254e">./source/_drafts/ to ./source/_posts.</font>
2. The file's "front-matter" changes to include a publish date:
```
 ---
 title: My First Blog Post
 date: 2015-12-30 00:53:15  # <-
 tags:
 ---
 ...
```

Finally, prepare the entire site for deployment. Run the hexo generate command:
```
$ hexo generate
# generates -> ./public/
```

Everything that is required to run the website will be placed inside the <font color="#c7254e">./public</font>folder. You are all set to take this folder and transfer it to your public webserver or CDN.

The correct way to reference the image
----------------------------
The correct way to reference the image will thus be to use tag plugin syntax rather than markdown:
```
{% asset_path slug %}
{% asset_img slug [title] %}
{% asset_link slug [title] %}
eg.:
{% asset_img example.jpg This is an example image %}
{% asset_img "spaced asset.jpg" "spaced title" %}
```

Cheatsheet
--------------
Here is a reference of the components that produce Bootstrap markup with this theme...
### Responsive tables
Markdown:
```
| Table Header 1 | iTable Header 2 | Table Header 3 |
| - | - | - |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
```

...outputs:

| Table Header 1 | Table Header 2 | Table Header 3 |
| - | - | - |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |

Bootstrap Callouts
-------------------
A custom tag for the [Bootstrap "callout" style](http://cpratt.co/twitter-bootstrap-callout-css-styles/) is available for use:

In the Markdown:
```
{% callout info %}
#### {% fa info-circle %} Info
This is some info content
{% endcallout %}

{% callout warning %}
#### {% fa exclamation-triangle %} Warning
This is some warning content
{% endcallout %}

{% callout danger %}
#### {% fa exclamation-triangle %} Danger
This is some danger content
{% endcallout %}
```
...outputs:
{% callout info %}
#### {% fa info-circle %} Info
This is some info content
{% endcallout %}

{% callout warning %}
#### {% fa exclamation-triangle %} Warning
This is some warning content
{% endcallout %}

{% callout danger %}
#### {% fa exclamation-triangle %} Danger
This is some danger content
{% endcallout %}

Font-Awesome-icons
------------------
The following code brings up a spinning icon:
```
{% fa refresh spin %}
```
...outputs
{% fa refresh spin %}

The following code brings up a fixed width icon:
```
{% fa home fw %}
```
{% fa home fw %}

Visit [Font Awesome Icons](https://fortawesome.github.io/Font-Awesome/icons/) to find icons you like.

Tag Plugins For Relative Path Referencing
-----------------------------------------
Referencing images or other assets using normal markdown syntax and relative paths may cause them to display incorrectly on archive or index pages. Plugins have been created by the community to address this issue in Hexo 2. However, with the release of Hexo 3, several new tag plugins were added to core. These enable you to reference your assets more easily in posts:

```
{% asset_path slug %}
{% asset_img slug [title] %}
{% asset_link slug [title] %}
```
For example, with post asset folders enabled, if you place an image example.jpg into your asset folder, it will not appear on the index page if you reference it using a relative path with regular `![](/example.jpg)` markdown syntax (however, it will work as expected in the post itself).

The correct way to reference the image will thus be to use tag plugin syntax rather than markdown:

```
{% asset_img example.jpg This is an example image %}
{% asset_img "spaced asset.jpg" "spaced title" %}
```

Markdown editor
---------------
[stackedit is very nice](https://stackedit.io)

Reference
---------------
[Hexo Docs](https://hexo.io/docs/)
[hexo-theme-bootstrap-blog](https://github.com/cgmartin/hexo-theme-bootstrap-blog)
