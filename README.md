# Cells

*View Components for Ruby and Rails.*

## Overview

Cells allow you to encapsulate parts of your UI into components into _view models_. View models, or cells, are simple ruby classes that can render templates.

Nevertheless, a cell gives you more than just a template renderer. They allow proper OOP, polymorphic builders, [nesting](#nested-cells), view inheritance, using Rails helpers, [asset packaging](http://trailblazerb.org/gems/cells/rails.html#asset-pipeline) to bundle JS, CSS or images, simple distribution via gems or Rails engines, encapsulated testing, [caching](#caching), and [integrate with Trailblazer](#concept-cells).

## This is not Cells 3.x!

Temporary note: This is the README and API for Cells 4. Many things have improved. If you want to upgrade, [follow this guide](https://github.com/apotonick/cells/wiki/From-Cells-3-to-Cells-4---Upgrading-Guide). When in trouble, join us on the IRC (Freenode) #trailblazer channel.


## Rendering Cells

You can render cells anywhere and as many as you want, in views, controllers, composites, mailers, etc.

Rendering a cell in Rails ironically happens via a helper.

```ruby
<%= cell(:comment, @comment) %>
```

This boils down to the following invocation, that can be used to render cells in *any other Ruby* environment.

```ruby
CommentCell.(@comment).()
```

In Rails you have the same helper API for views and controllers.

```ruby
class DasboardController < ApplicationController
  def dashboard
    @comments = cell(:comment, collection: Comment.recent)
    @traffic  = cell(:report, TrafficReport.find(1)).()
  end
```

Usually, you'd pass in one or more objects you want the cell to present. That can be an ActiveRecord model, a ROM instance or any kind of PORO you fancy.

## Cell Class

A cell is a light-weight class with one or multiple methods that render views.

```ruby
class CommentCell < Cell::ViewModel
  property :body
  property :author

  def show
    render
  end

private
  def author_link
    link_to "#{author.email}", author
  end
end
```

Here, `show` is the only public method. By calling `render` it will invoke rendering for the `show` view.


## Logicless Views

Views come packaged with the cell and can be ERB, Haml, or Slim.

```erb
<h3>New Comment</h3>
  <%= body %>

By <%= author_link %>
```

The concept of "helpers" that get strangely copied from modules to the view does not exist in Cells anymore.

Methods called in the view are directly called _on the cell instance_. You're free to use loops and deciders in views, even instance variables are allowed, but Cells tries to push you gently towards method invocations to access data in the view.

## File Structure

In Rails, cells are placed in `app/cells` or `app/concepts/`. Every cell has their own directory where it keeps views, assets and code.

```
app
├── cells
│   ├── comment_cell.rb
│   ├── comment
│   │   ├── show.haml
│   │   ├── list.haml
```

The discussed `show` view would reside in `app/cells/comment/show.haml`. However, you can set [any set of view paths](#view-paths) you want.


## Invocation Styles

In order to make a cell render, you have to call the rendering methods. While you could call the method directly, the prefered way is the _call style_.

```ruby
cell(:comment, @song).()       # calls CommentCell#show.
cell(:comment, @song).(:index) # calls CommentCell#index.
```

The call style respects caching.

Keep in mind that `cell(..)` really gives you the cell object. In case you want to reuse the cell, need setup logic, etc. that's completely up to you.

## Parameters

You can pass in as many parameters as you need. Per convention, this is a hash.

```ruby
cell(:comment, @song, volume: 99, genre: "Jazz Fusion")
```

Options can be accessed via the `@options` instance variable.

Naturally, you may also pass arbitrary options into the call itself. Those will be simple method arguments.

```ruby
cell(:comment, @song).(:show, volume: 99)
```

Then, the `show` method signature changes to `def show(options)`.


## Testing

A huge benefit from "all this encapsulation" is that you can easily write tests for your components. The API does not change and everything is exactly as it would be in production.

```ruby
html = CommentCell.(@comment).()
Capybara.string(html).must_have_css "h3"
```

It is completely up to you how you test, whether it's RSpec, MiniTest or whatever. All the cell does is return HTML.

[In Rails, there's support](http://trailblazerb.org/gems/cells/testing.html) for TestUnit, MiniTest and RSpec available, along with Capybara integration.

## Properties

The cell's model is available via the `model` reader. You can have automatic readers to the model's fields by uing `::property`.

```ruby
class CommentCell < Cell::ViewModel
  property :author # delegates to model.author

  def author_link
    link_to author.name, author
  end
end
```

## HTML Escaping

Cells per default does no HTML escaping, anywhere. Include `Escaped` to make property readers return escaped strings.

```ruby
class CommentCell < Cell::ViewModel
  include Escaped

  property :title
end

song.title                 #=> "<script>Dangerous</script>"
Comment::Cell.(song).title #=> &lt;script&gt;Dangerous&lt;/script&gt;
```

Properties and escaping are [documented here](http://trailblazerb.org/gems/cells/api.html#html-escaping).

## Installation

Cells run with all Rails >= 4.0. Lower versions of Rails will still run with Cells, but you will get in trouble with the helpers.

```ruby
gem 'cells', "~> 4.0.0"
```

(Note: we use Cells in production with Rails 3.2 and Haml and it works great.)

Various template engines are supported but need to be added to your Gemfile.

* [cells-erb](https://github.com/trailblazer/cells-erb)
* [cells-haml](https://github.com/trailblazer/cells-haml) Make sure to bundle Haml 4.1: `gem "haml", github: "haml/haml", ref: "7c7c169"`.
* [cells-slim](https://github.com/trailblazer/cells-slim)

```ruby
gem "cells-erb"
```

In Rails, this is all you need to do. In other environments, you need to include the respective module into your cells.

```ruby
class CommentCell < Cell::ViewModel
  include ::Cell::Erb # or Cell::Haml, or Cell::Slim
end
```

## Generators

In Rails, you can generate cells and concept cells.

```shell
rails generate cell comment
```

Or.

```shell
rails generate concept comment
```


## Concept Cells

To have real self-contained cells you should use the new _concept cell_ which follows the [Trailblazer](http://trailblazerb.org) naming style. Concept cells need to be derived from `Cell::Concept`, sit in a namespace and are usually named `Cell`.

```ruby
class Comment::Cell < Cell::Concept
  # ..
end
```

Their directory structure looks as follows.

```
app
├── concepts
│   ├── comment
│   │   ├── cell.rb
│   │   ├── views
│   │   │   ├── show.haml
```

This integrates with Trailblazer where classes for one _concept_ sit in the same directory. Please [read the book](http://leanpub.com/trailblazer) to learn how to use cells with Trailblazer.

Concept cells are rendered using the `concept` helper.

```erb
<%= concept("comment/cell", @comment) %>
```

Other than that, normal cells and concept cells are identical.

## Namespaces

Cells can be namespaced as well. This is used for [concept cells](#concept-cells), too.

```ruby
module Admin
  class CommentCell < Cell::ViewModel
```

Invocation in Rails would happen as follows.

```ruby
cell("admin/comment", @comment).()
```

Views will be searched in `app/cells/admin/comment` per default.


## Rails Helper API

Even in a non-Rails environment, Cells provides the Rails view API and allows using all Rails helpers.

You have to include all helper modules into your cell class. You can then use `link_to`, `simple_form_for` or whatever you feel like.

```ruby
class CommentCell < Cell::ViewModel
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper

  def author_link
    content_tag :div, link_to(author.name, author)
  end
```

As always, you can use helpers in cells and in views.

You might run into problems with wrong escaping or missing URL helpers. This is not Cells' fault but Rails suboptimal way of implementing and interfacing their helpers. Please open the actionview gem helper code and try figuring out the problem yourself before bombarding us with issues because helper `xyz` doesn't work.


## View Paths

In Rails, the view path is automatically set to `app/cells/` or `app/concepts/`. You can append or set view paths by using `::view_paths`. Of course, this works in any Ruby environment.

```ruby
class CommentCell < Cell::ViewModel
  self.view_paths = "lib/views"
end
```

## Asset Packaging

Cells can easily ship with their own JavaScript, CSS and more and be part of Rails' asset pipeline. Bundling assets into a cell allows you to implement super encapsulated widgets that are stand-alone. Asset pipeline is [documented here](http://trailblazerb.org/gems/cells/rails.html#asset-pipeline).

## Render API

Unlike Rails, the `#render` method only provides a handful of options you gotta learn.

```ruby
def show
  render
end
```

Without options, this will render the state name, e.g. `show.erb`.

You can provide a view name manually. The following calls are identical.

```ruby
render :index
render view: :index
```

If you need locals, pass them to `#render`.

```ruby
render locals: {style: "border: solid;"}
```

## Layouts

Every view can be wrapped by a layout. Either pass it when rendering.

```ruby
render layout: :default
```

Or configure it on the class-level.

```ruby
class CommentCell < Cell::ViewModel
  layout :default
```

The layout is treated as a view and will be searched in the same directories.


## Nested Cells

Cells love to render. You can render as many views as you need in a cell state or view.

```ruby
<%= render :index %>
```

The `#render` method really just returns the rendered template string, allowing you all kind of modification.

```ruby
def show
  render + render(:additional)
end
```

You can even render other cells _within_ a cell using the exact same API.

```ruby
def about
  cell(:profile, model.author).()
end
```

This works both in cell views and on the instance, in states.


## View Inheritance

Cells can inherit code from each other with Ruby's inheritance.

```ruby
class CommentCell < Cell::ViewModel
end

class PostCell < CommentCell
end
```

Even cooler, `PostCell` will now inherit views from `CommentCell`.

```ruby
PostCell.prefixes #=> ["app/cells/post", "app/cells/comment"]
```

When views can be found in the local `post` directory, they will be looked up in `comment`. This starts to become helpful when using [composed cells](#nested-cells).

If you only want to inherit views, not the entire class, use `::inherit_views`.

```ruby
class PostCell < Cell::ViewModel
  inherit_views Comment::Cell
end

PostCell.prefixes #=> ["app/cells/post", "app/cells/comment"]
```

## Collections

In order to render collections, Cells comes with a shortcut.

```ruby
comments = Comment.all #=> three comments.
cell(:comment, collection: comments)
```

This will invoke `cell(:comment, song).()` three times and concatenate the rendered output automatically. In case you don't want `show` but another state rendered, use `:method`.

```ruby
cell(:comment, collection: comments, method: :list)
```

Note that you _don't_ need to invoke call here, the `:collection` behavior internally handles that for you.

Additional options are passed to every cell constructor.

```ruby
cell(:comment, collection: comments, style: "awesome", volume: "loud")
```

## Builder

Often, it is good practice to replace decider code from views or classes into separate sub-cells. Or in case you want to render a polymorphic collection, builders come in handy.

Builders allow instantiating different cell classes for different models and options.

```ruby
class CommentCell < Cell::ViewModel
  builds do |model, options|
    PostCell       if model.is_a?(Post)
    CommentCell    if model.is_a?(Comment)
  end
```

The `#cell` helper takes care of instantiating the right cell class for you.

```ruby
cell(:comment, Post.find(1)) #=> creates a PostCell.
```

This also works with collections.

```ruby
cell(:comment, collection: [@post, @comment]) #=> renders PostCell, then CommentCell.
```

Multiple calls to `::builds` will be ORed. If no block returns a class, the original class will be used (`CommentCell`). Builders are inherited.


## Caching

For every cell class you can define caching per state. Without any configuration the cell will run and render the state once. In following invocations, the cached fragment is returned.

```ruby
class CommentCell < Cell::ViewModel
  cache :show

  # ..
end
```

The `::cache` method will forward options to the caching engine.

```ruby
cache :show, expires_in: 10.minutes
```

You can also compute your own cache key, use dynamic keys, cache tags, and so on.

```ruby
cache :show { |model, options| "comment/#{model.id}/#{model.updated_at}" }
cache :show, :if => lambda { |*| has_changed? }
cache :show, :tags: lambda { |model, options| "comment-#{model.id}" }
```

Caching is documented [here](http://trailblazerb.org/gems/cells/caching.html) and in chapter 8 of the [Trailblazer book](http://leanpub.com/trailblazer).


## The Book

Cells is part of the [Trailblazer project](https://github.com/apotonick/trailblazer). Please [buy my book](https://leanpub.com/trailblazer) to support the development and to learn all the cool stuff about Cells. The book discusses the following.

<a href="https://leanpub.com/trailblazer">
![](https://raw.githubusercontent.com/apotonick/trailblazer/master/doc/trb.jpg)
</a>

* Basic view models, replacing helpers, and how to structure your view into cell components (chapter 2 and 4).
* Advanced Cells API (chapter 4 and 6).
* Testing Cells (chapter 4 and 6).
* Cells Pagination with AJAX (chapter 6).
* View Caching and Expiring (chapter 8).

More chapters are coming.

The book picks up where the README leaves off. Go grab a copy and support us - it talks about object- and view design and covers all aspects of the API.


## Undocumented Features

*(Please don't read this section!)*

### Rendering Global Partials

Although not recommended, you can also render global partials from a cell. Be warned, though, that they will be rendered using our stack, and you might have to include helpers into your view model.

This works by including `Partial` and the corresponding `:partial` option.

```ruby
class Cell < Cell::ViewModel
  include Partial

  def show
    render partial: "../views/shared/map.html" # app/views/shared/map.html.haml
  end
```

The provided path is relative to your cell's `::view_paths` directory. The format has to be added to the file name, the template engine suffix will be used from the cell.

You can provide the format in the `render` call, too.

```ruby
render partial: "../views/shared/map", formats: [:html]
```

This was mainly added to provide compatibility with 3rd-party gems like [Kaminari and Cells](https://github.com/apotonick/kaminari-cells) that rely on rendering partials within a cell.

## LICENSE

Copyright (c) 2007-2015, Nick Sutterer

Copyright (c) 2007-2008, Solide ICT by Peter Bex and Bob Leers

Released under the MIT License.
