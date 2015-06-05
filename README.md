# Cells

*View Components for Ruby and Rails.*


## Overview

Cells allow you to encapsulate parts of your UI into components into _view models_. View models, or cells, are simple ruby classes that can render templates.

Nevertheless, a cell gives you more than just a template renderer. They allow proper OOP, polymorphic builders, nesting, view inheritance, using Rails helpers, [asset packaging](http://trailblazerb.org/gems/cells/rails.html#asset-pipeline) to bundle JS, CSS or images, simple distribution via gems or Rails engines, encapsulated testing

## Rendering Cells

You can render cells anywhere and as many as you want, in views, controllers, composites, mailers, etc.

Rendering a cell in Rails ironically happens via a helper.

```ruby
<%= cell(:comment, @comment) %>
```

This boils down to the following invocation, that can be used to render cells in *any other Ruby* environment.

```ruby
CommentCell.build(@comment).()
```

In Rails you have the same helper API for views and controllers.

```ruby
class DasboardController < ApplicationController
  def dashboard
    @comments = cell(:comment, Comment.recent).()
    @traffic  = cell(:report, TrafficReport.find(1))
  end
```

Usually, you'd pass in one or more objects you want the cell to present. That can be an ActiveRecord model, a ROM instance or any kind of PORO you fancy.

## Cell Class

A cell is a light-weight class with one or multiple methods that render views.

```ruby
class Comment::Cell < Cell::ViewModel
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
html = CommentCell.build(@comment).()
Capybara.string(html).must_have_css "h3"
```

It is completely up to you how you test, whether it's RSpec, MiniTest or whatever. All the cell does is return HTML.

[In Rails, there's support](http://trailblazerb.org/gems/cells/testing.html) for TestUnit, MiniTest and RSpec available, along with Capybara integration.

## Installation

Cells run with all Rails >= 4.0. Lower versions of Rails will still run with Cells, but you will get in trouble with the helpers.

```ruby
gem 'cells', "~> 4.0.0"
```

(Note: we use Cells in production with Rails 3.2 and Haml and it works great.)

Various template engines are supported but need to be added to your Gemfile.

* [cells-erb](https://github.com/trailblazer/cells-erb)
* [cells-haml](https://github.com/trailblazer/cells-haml)
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

## Namespaces

Cells can be namespaced as well.

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

including helpers.
link_to in cell


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



 This is available via the `model` method. Declarative `::property`s give you readers to the model.


Cells allow you to encapsulate parts of your page into separate MVC components. These components are called _view models_.

You can render view models anywhere in your code. Mostly, cells are used in views to replace a helper/partial/filter mess, as a mailer renderer substitute or they get hooked to routes to completely bypass `ActionController`.

As you have already noticed we use _cell_ and _view model_ interchangeably here.


## The Book

Cells is part of the [Trailblazer project](https://github.com/apotonick/trailblazer). Please [buy my book](https://leanpub.com/trailblazer) to support the development and to learn all the cool stuff about Cells. The book discusses the following.

<a href="https://leanpub.com/trailblazer">
![](https://raw.githubusercontent.com/apotonick/trailblazer/master/doc/trb.jpg)
</a>

* Basic view models, replacing helpers, and how to structure your view into cell components (chapter 2 and 4).
* Advanced Cells API (chapter 4 and 6).
* Testing Cells (chapter 4 and 6).
* Cells Pagination with AJAX (chapter 6).
* View Caching and Expiring (chapter 7).

More chapters are coming.

The book picks up where the README leaves off. Go grab a copy and support us - it talks about object- and view design and covers all aspects of the API.

## No ActionView

Starting with Cells 4.0 we no longer use `ActionView` as a template engine. Removing this jurassic dependency cuts down Cells' rendering code to less than 50 lines and improves rendering speed by 300%!

**Note for Cells 3.x:** This README only documents Cells 4.0. Please [read the old README if you're using Cells 3.x](https://github.com/apotonick/cells/tree/31f6ed82b87b3f92613698442fae6fd61cc16de9#cells).


## Installation

Cells run with all Rails >= 3.2. Lower versions of Rails will still run with Cells, but you will get in trouble with the helpers.

```ruby
gem 'cells', "~> 4.0.0"
```

## Prerequisites

Cells comes bundled with ERB support. To render HAML, you have to include the [cells-haml](https://github.com/trailblazer/cells-haml) gem. The same for [cells-slim](https://github.com/trailblazer/cells-slim). Currently, they are only available as github dependencies, they will be released soon (early 2015).

```ruby
gem "cells-haml", github: 'trailblazer/cells-haml'
```

The template engine extensions fix severe bugs in combination with Rails helpers and the respective engine. Time will tell if we can convince the template teams to merge these fixes.



## Generate

Use the bundled generator to set up a cell.

```shell
rails generate cell comment
```

```
create  app/cells/
create  app/cells/comment
create  app/cells/comment_cell.rb
create  app/cells/comment/show.erb
```



Cells provides you the view _model_ via the `#model` method. Here, this returns the `Comment` instance passed into the constructor.

Of course, this view is a mess and needs be get cleaned up!

## Logicless Views

This is how a typical view looks in a view model.

```haml
-# app/cells/comment/show.haml

%h1 Comment

= body
By
= author_link
```

The methods we call in the view now need to be defined in the cell instance.

```ruby
class CommentCell < Cell::ViewModel
  def show
    render
  end

private

  def body
    model.body
  end

  def author_link
    link_to model.author.name, model.author
  end
end
```

See how you can use helpers in a cell instance?

## No Helpers

The difference to conventional Rails views is that every method called in a view is directly called on the cell instance. The cell instance _is_ the rendering context. This allows a very object-oriented and clean way to implement views.

Helpers as known from conventional Rails where methods and variables get copied between view and controller no longer exist in Cells.

Note that you can still use helpers like `link_to` and all the other friends - you have to _include_ them into the cell class, though.

## Automatic Properties

Often, as in the `#body` method, you simply need to delegate properties from the model. This can be done automatically using `::property`.

```ruby
class CommentCell < Cell::ViewModel
  def show
    render
  end

private
  property :body
  property :author

  def author_link
    link_to author.name, author
  end
end
```

Readers are automatically created when defined with `::property`.


## Render

multiple times allowed
:view
:format ".html"
template_engine
view_paths






## Collections

You can render a collection of models where each item is rendered using a cell.

```ruby
= cell(:song, collection: Song.all)
```

Note that there is no `.call` needed. This is identical to the following snippet.

```ruby
- Song.all.each do |song|
  = cell(:song, song).call(:show)
```

Options are passed to every cell.

```ruby
= cell(:song, collection: Song.all, genre: "Heavy Metal", user: current_user)
```

The collection invocation per default calls `#show`. Use `:method` if you need another method to be called.

```ruby
= cell(:song, collection: Song.all, method: :detail)
```

## Builder

Often, it is good practice to replace decider code from views or classes into separate sub-cells. Or in case you want to render a polymorphic collection, builders come in handy.

Builders allow instantiating different cell classes for different models and options.

```ruby
class SongCell < Cell::ViewModel
  builds do |model, options|
    HitCell       if model.is_a?(Hit)
    EverGreenCell if model.is_a?(Evergreen)
  end

  def show
    # ..
end
```

The `#cell` helpers takes care of instantiating the right cell class for you.

```ruby
cell(:song, Hit.find(1)) #=> creates a HitCell.
```

This also works with collections.

```ruby
cell(:song, collection: [@hit, @song]) #=> renders HitCell, then SongCell.
```

Multiple calls to `::builds` will be ORed. If no block returns a class, the original class will be used (`SongCell`). Builders are inherited.


## View Inheritance



## Asset Pipeline

Cells can also package their own assets like JavaScript, CoffeeScript, Sass and stylesheets. When configured, those files go directly into Rails' asset pipeline. This is a great way to clean up your assets by pushing scripts and styles into the component they belong to. It makes it so much easier to find out which files are actually involved per "widget".

Note: This feature is **still experimental** and the API (file name conventions, configuration, etc.) might change.

Assets per default sit in the cell's `assets/` directory.

```
app
├── cells
│   ├── comment
│   │   ├── views
│   │   ├── ..
│   │   ├── assets
│   │   │   ├── comment.js.coffee
│   │   │   ├── comment.css.sass
```

Adding the assets files to the asset pipeline currently involves two steps (I know it feels a bit clumsy, but I'm sure we'll find a way to make it better soon).

1. Tell Rails that this cell provides its own self-contained assets.

    ```ruby
    Gemgem::Application.configure do
      # ...

      config.cells.with_assets = %w(comment)
    ```

    This will add `app/cells/comment/assets/` to the asset pipeline's paths.

2. Include the assets in `application.js` and `application.css.sass`

    In `app/assets/application.js`, you have to add the cell assets manually.

    ```javascript
    //=# require comments
    ```

    Same goes into `app/assets/application.css.sass`.

    ```sass
    @import 'comments';
    ```

In future versions, we wanna improve this by automatically including cell assets and avoiding name clashes. If you have ideas, suggestions, I'd love to hear them.

## View Inheritance

This is where OOP comes back to your view.

* __Inherit code__ into your cells by deriving more abstract cells.
* __Inherit views__ from parent cells.


### Sharing Views

Sometimes it is handy to reuse an existing view directory from another cell, to avoid a growing number of directories. You could derive the new cell and thus inherit the view paths.

```ruby
class Comment::FormCell < CommentCell
```

This does not only allow view inheritance, but will also inherit all the code from `CommentCell`. This might not be what you want.

If you're just after inheriting the _views_, use `::inherit_views`.

```ruby
class Comment::FormCell < Cell::Rails
  inherit_views CommentCell
```

When rendering views in `FormCell`, the view directories to look for templates will be inherited.


## Caching

Cells allow you to cache per state. It's simple: the rendered result of a state method is cached and expired as you configure it.

To cache forever, don't configure anything

```ruby
class CartCell < Cell::Rails
  cache :show

  def show
    render
  end
```

This will run `#show` only once, after that the rendered view comes from the cache.


### Cache Options

Note that you can pass arbitrary options through to your cache store. Symbols are evaluated as instance methods, callable objects (e.g. lambdas) are evaluated in the cell instance context allowing you to call instance methods and access instance variables. All arguments passed to your state (e.g. via `render_cell`) are propagated to the block.

```ruby
cache :show, :expires_in => 10.minutes
```

If you need dynamic options evaluated at render-time, use a lambda.

```ruby
cache :show, :tags => lambda { |*args| tags }
```

If you don't like blocks, use instance methods instead.

```ruby
class CartCell < Cell::Rails
  cache :show, :tags => :cache_tags

  def cache_tags(*args)
    # do your magic..
  end
```

### Conditional Caching

The +:if+ option lets you define a condition. If it doesn't return a true value, caching for that state is skipped.

```ruby
cache :show, :if => lambda { |*| has_changed? }
```

### Cache Keys

You can expand the state's cache key by appending a versioner block to the `::cache` call. This way you can expire state caches yourself.

```ruby
class CartCell < Cell::Rails
  cache :show do |options|
    order.id
  end
```

The versioner block is executed in the cell instance context, allowing you to access all stakeholder objects you need to compute a cache key. The return value is appended to the state key: `"cells/cart/show/1"`.

As everywhere in Rails, you can also return an array.

```ruby
class CartCell < Cell::Rails
  cache :show do |options|
    [id, options[:items].md5]
  end
```

Resulting in: `"cells/cart/show/1/0ecb1360644ce665a4ef"`.


### Debugging Cache

When caching is turned on, you might wanna see notifications. Just like a controller, Cells gives you the following notifications.

* `write_fragment.action_controller` for cache miss.
* `read_fragment.action_controller` for cache hits.

To activate notifications, include the `Notifications` module in your cell.

```ruby
class Comment::Cell < Cell::Rails
  include Cell::Caching::Notifications
```

### Inheritance

Cache configuration is inherited to derived cells.



### A Note On Fragment Caching

Fragment caching is [not implemented in Cells per design](http://nicksda.apotomo.de/2011/02/rails-misapprehensions-caching-views-is-not-the-views-job/) - Cells tries to move caching to the class layer enforcing an object-oriented design rather than cluttering your views with caching blocks.

If you need to cache a part of your view, implement that as another cell state.


### Testing Caching

If you want to test it in `development`, you need to put `config.action_controller.perform_caching = true` in `development.rb` to see the effect.




### Call

The `#call` method also accepts a block and yields `self` (the cell instance) to it. This is extremely helpful for using `content_for` outside of the cell.

```ruby
  = cell(:song, Song.last).call(:show) do |cell|
    content_for :footer, cell.footer
```

Note how the block is run in the global view's context, allowing you to use global helpers like `content_for`.


## Using Decorators (Twins)

You need to include the `disposable` gem in order to use this.

````ruby
gem "disposable"
```

With Cells 3.12, a new experimental concept enters the stage: Decorators in view models. As the view model should only contain logic related to presentation (which can get quite a bit), decorators - called _Twins_ -  can be defined and automatically setup for your model.

Twins are a general concept in Trailblazer and are used everywhere where representers, forms, operations or cells need additional logic that has to be shared between layers. So, this extra step allows re-using your decorator for presentations other than the cell, e.g. in a JSON API, tests, etc.

Also, logic that simply doesn't belong to in a view-related class goes into a twin. That could be code to figure out if a user in logged in.

```ruby
class SongCell < Cell::ViewModel
  include Properties

  class Twin < Cell::Twin # this is your decorator
    property :title
    property :id
    option :in_stock?
  end

  properties Twin

  def show
    if in_stock?
      "You're lucky #{title} (#{id}) is in stock!"
    end
  end
end
```

In this example, we define the twin _in_ the cell itself. That could be done anywhere, as long as you tell the cell where to find the twin (`properties Twin`).

### Creating A Twin Cell

You create your cell as follows.

```ruby
cell("song", Song.find(1), in_stock?: true)
```

Internally, a twin is created from the arguments and passed to the view model. The view model cell now only works on the twin, not on the model anymore.

The twin simply acts as a delegator between the cell and the model: attributes defined with `property` are copied from the model, `option` values _have_ to be passed explicitely to the constructor. The twin defines an _interface_ for using your cell.

Another awesome thing is that you can now easily test your cell by "mocking" values.

```ruby
it "renders nicely" do
  cell("song", song, in_stock?: true, title: "Mocked Song Title").must_match ...
end
```

The twin will simply use the passed `:title` and not copy the title from the song model, making it really easy to test edge cases in your view model.

### Extending Decorators

A decorator without any logic only gives you a tiny improvement, they become really helpful when including your own decorator logic.

```ruby
class Twin < Cell::Twin # this is your decorator
  property :title
  property :id
  option :in_stock?

  def title
    super.downcase # super to retrieve the original title from model!
  end
end
```

The same logic can now be used in a cell, a JSON or XML API endpoint or in the model layer.

Note: If there's enough interest, this could also be extended to work with draper and other decoration gems.

### Nested Rendering

When extracting parts of your view into a partial, as we did for the author section, you're free to render additional views using `#render`. Again, wrap render calls in instance methods, otherwise you'll end up with too much logic in your view.

```ruby
class SongCell < Cell::ViewModel
  include TimeagoHelper

  property :title

  # ...

  def author_box
    render :author # same as render view: :author
  end
end
```

This will simply render the `author.haml` template in the same context as the `show` view, meaning you might use helpers, again.



### Cells in ActionMailer

ActionMailer doesn't have request object, so if you inherit from Cell::Rails you will receive an error. Cell::Base will fix that problem, but you will not be able to use any of routes inside your cells.

You can fix that with [actionmailer_with_request](https://github.com/weppos/actionmailer_with_request) which (suprise!) brings request object to the ActionMailer.



## Cells is Rails::Engine aware!

Now `Rails::Engine`s can contribute to Cells view paths. By default, any 'app/cells' found inside any Engine is automatically included into Cells view paths. If you need to, you can customize the view paths changing/appending to the `'app/cell_views'` path configuration. See the `Cell::EngineIntegration` for more details.


## Generator Options

By default, generated cells inherit from `Cell::ViewModel`. If you want to change this, specify your new class name in `config/application.rb`:

### Base Class

```ruby
module MyApp
  class Application < Rails::Application
    config.generators do |g|
      g.base_cell_class "ApplicationCell"
    end
  end
end
```


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
