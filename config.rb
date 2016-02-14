###
# Blog settings
###


# Time.zone = "UTC"

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  # blog.permalink = "{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  blog.summary_length = 100
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  # blog.page_link = "page/{num}"

end

page "/feed.xml", layout: false

###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", layout: false
#
# With alternative layout
# page "/path/to/file.html", layout: :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
 helpers do

  def find_author(author_slug)
    author_slug = author_slug.downcase
    result = data.authors.select {|author| author.keys.first == author_slug }
    raise ArgumentError unless result.any?
    result.first
  end

  def author_path(author)
    "/#{author.keys.first}.html"
  end

 end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Markdown settings
set :markdown_engine, :redcarpet
set :markdown, hard_wrap: true, \
               no_intra_emphasis: true, \
               fenced_code_blocks: true, \
               gh_blockcode: true, \
               autolink: true, \
               tables: true, \
               with_toc_data: true, \
               strikethrough: true, \
               superscript: true

# Syntax highlight settings
# activate :syntax
activate :rouge_syntax


# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

end


###
# Site Settings
###
set :site_url, 'http://blog.proudit.jp/'
set :site_author, 'Proudit'
set :site_title, 'Proud Blog'
set :site_description, 'Proudit Inc. Main Blog Site'

Slim::Engine.disable_option_validator!

set :fonts_dir,  "fonts"

ready do
  sitemap.resources.group_by {|p| p.data["author"] }.each do |author, pages|
    proxy "/#{author}.html", "author.html",
      locals: { author_slug: author, pages: pages },
      ignore: true
  end
end

ignore "/.html"
