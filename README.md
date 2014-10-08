# Cells

*View Components for Rails.*


## Overview

Cells allow you to encapsulate parts of your page into separate MVC components. These components are called _view models_.

You can render view models anywhere in your code. Mostly, cells are used in views to replace a helper/partial/filter mess, as a mailer renderer substitute or they get hooked to routes to completely bypass `ActionController`.

As you have already noticed we use _cell_ and _view model_ interchangeably here.

## No ActionView

Starting with Cells 4.0 we no longer use `ActionView` as a template engine. Removing this jurassic dependency cuts down Cells' rendering code to less than 50 lines and improves rendering speed by 300%!

**Note for Cells 3.x:** This README only documents Cells 4.0. Please [read the old README if you're using Cells 3.x](https://github.com/apotonick/cells/tree/31f6ed82b87b3f92613698442fae6fd61cc16de9#cells).


## Installation

Cells run with all Rails >= 3.2. Lower versions of Rails will still run with Cells, but you will get in trouble with the helpers.

```ruby
gem 'cells', "~> 4.0.0"
```

## File Layout

Cells are placed in `app/cells`.

```
app
├── cells
│   ├── comment_cell.rb
│   ├── comment
│   │   ├── show.haml
│   │   ├── list.haml
```


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


## Rendering View Models

Cells brings you one helper method `#cell` to be used in your controller views or layouts.

```haml
= cell(:comment, Comment.find(1))
```

This is the short form of rendering a cell. Simple, isn't it?

Note that a view model _always_ requires a model in the constructor (or a composition). This doesn't have to be an `ActiveRecord` object but can be any type of Ruby object you want to present.

To understand invoking cells, here's the long form of it.

```haml
= cell(:comment, Comment.find(1)).call(:show)
```

1. `#cell(..)` simply returns the cell instance. You can do whatever you want with it.
2. `.call(:show)` will invoke the `#show` method respecting any caching settings.

When rendering cells in views, you can skip the `call` part as this is implicitely done by the template.

Please [refer to the docs](#invocation-styles) for different ways of invoking view models.


## View Model Classes

A view model is always implemented as a class. This gives you encapsulation, proper inheritance and namespacing out-of-the-box.

```ruby
class CommentCell < Cell::ViewModel
  def show
    render
  end
end
```

Calling `#render` will render the cell's `show.haml` template, located in `app/cells/comment`. Invoking `render` is explicit: this means, it really returns the rendered view string, allowing you to modify the HTML afterwards.

```ruby
def show
  "<div>" + render + "</div>"
end
```

## Views In Theory

In Cells, we don't distinguish between _view_ or _partial_. Every view you render is a partial, every partial a view. You can render views inside views, compose complex UI blocks with multiple templates and go crazy. This is what cells _views_ are made for.

Cells supports all template engines that are supported by the excellent [tilt](https://github.com/rtomayko/tilt) gem - namely, this is ERB, HAML, Slim, and many more.

In these examples, we're using HAML.

BTW, Cells doesn't include the format into the view name. 99% of all cells render HTML anyway, so we prefer short names like `show.haml`.


## Views In Practice

Let's check out the `show.haml` view to see how they work.

```haml
-# app/cells/comment/show.haml

%h1 Comment

= model.body
By
= link_to model.author.name, model.author
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


## Invocation styles

The explicit, long form allows you rendering cells in views, in controllers, mailers, etc.

```ruby
cell(:comment, Comment.find(1)).call(:show)
```

As `:show` is the default action, you don't have to specify it.

```ruby
cell(:comment, Comment.find(1)).call
```

In views, the template engine will automatically call `cell.to_s`. It does that for every object passed in as a placeholder. `ViewModel#to_s` exists and is aliased to `#call`, which allows to omit that part in a view.

```haml
= cell(:comment, Comment.find(1))
```

If you want, you can also call methods directly on your cell. Note that this does _not_ respect caching, though.

```haml
= cell(:comment, Comment.find(1)).avatar
```

## Passing Options

There's several ways to inject additional state into your cell.

### Object Style

Cells can receive any set of options you need. Usually, a hash containing additional options is passed as the last argument.

```ruby
cell(:comment, @comment, layout: :fancy)
```

The third argument is accessable via `#options` in the instance.

```ruby
def show
  render layout: options[:layout]
end
```

### Functional Style

You can also pass options to the action method itself, making your cell a bit more functional with less state.

```ruby
cell(:comment, @comment).call(:show, layout: :fancy)
```

Make sure the method is ready to process those arguments.

```ruby
def show(layout=:default)
  render layout: layout
end
```

## Collections

You can render a collection of models where each item is rendered using a cell.

```ruby
= cell(:song, collection: Song.all)
```

Note that there is _no_ `.call` needed. This is identical to the following snippet.

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

Often, it is good practice to replace decider code from views or classes into separate sub-cells. Or in case you want to render a polymorphic collection, builders come in handy. They allow instantiating different cell classes for input values.

```ruby
class SongCell < Cell::ViewModel
  builder do |model, options|
    HitCell if model.is_a?(Hit)
    EverGreenCell if model.is_a?(Evergreen)
  end

  def show
    # ..
end
```

The `#cell` helpers takes care of instantiating the right cell class for you.

```ruby
cell(:song, Hit.find(1)) #=> creates an EvergreenCell.
```

This also works with collections.

```ruby
cell(:song, collection: [@hit, @song]) #=> renders HitCell, then SongCell.
```

Multiple calls to `::builder` will be ORed. If no block returns a class, the original class will be used (`SongCell`).


## View Inheritance



# TODO: merge stuff below!

## File Structure

In Cells 3.10 we introduce a new _optional_ file structure integrating with [Trailblazer](https://github.com/apotonick/trailblazer)'s "concept-oriented" layout.

This new file layout makes a cell fully **self-contained** so it can be moved around just by grabbing one single directory.

Activate it with

```ruby
class Comment::Cell
  self_contained!

  # ...
end
```

Now, the cell directory ideally looks like the following.

```
app
├── cells
│   ├── comment
│   │   ├── cell.rb
│   │   ├── views
│   │   │   ├── show.haml
│   │   │   ├── list.haml
```


Here, cell class and associated views are in the same self-contained `comment` directory.

You can use the new views directory along with leaving your cell _class_ at `app/cells/comment_cell.rb`, if you fancy that.


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

### Rendering Global Partials

Sometimes you need to render a global partial from `app/views` within a cell. For instance, the `gmaps4rails` helper depends on a global partial. While this breaks encapsulation it's still possible in cells - just add the global view path.

```ruby
class MapCell < Cell::Rails
  append_view_path "app/views"

  def show
    render partial: 'shared/map_form'
  end
```

Note that you have to use `render partial:` which will then look in the global view directory and render the partial found at `app/views/shared/map_form.html.haml`.


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


## Testing

Another big advantage compared to monolithic controller/helper/partial piles is the ability to test your cells isolated.

### Test::Unit

So what if you wanna test the cart cell? Use the generated `test/cells/cart_cell_test.rb` test.

```ruby
class CartCellTest < Cell::TestCase
  test "show" do
    invoke :show, :user => @user_fixture
    assert_select "#cart", "You have 3 items in your shopping cart."
  end
```

Don't forget to put `require 'cell/test_case'` in your project's `test/test_helper.rb` file.

Then, run your tests with

```shell
rake test:cells
```

That's easy, clean and strongly improves your component-driven software quality. How'd you do that with partials?


### RSpec

If you prefer RSpec examples, use the [rspec-cells](http://github.com/apotonick/rspec-cells) gem for specing.

```ruby
it "should render the posts count" do
  render_cell(:posts, :count).should have_selector("p", :content => "4 posts!")
end
```

To run your specs we got a rake task, too!

```shell
rake spec:cells
```


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

### Encapsulation

If in doubt, encapsulate nested parts of your view into a separate cell. You can use the `#cell` method in your cell to instantiate a nested cell.

Designing view models to create kickass UIs for your domain layer is discussed in 50+ pages in [my upcoming book](http://nicksda.apotomo.de).

### Alternative Instantiation

You don't need to pass in a model, it can also be a hash for a composition.

```ruby
  cell(album, song: song, composer: album.composer)
```

This will create two readers in the cell for you automatically: `#song` and `#composer`.


Note that we are still working on a declarative API for compositions. It will be similar to the one found in Reform, Disposable::Twin and Representable:

```ruby
  property :title, on: :song
  property :last_name, on: :composer
```


## Mountable Cells

Cells 3.8 got rid of the ActionController dependency. This essentially means you can mount Cells to routes or use them like a Rack middleware. All you need to do is derive from Cell::Base.

```ruby
class PostCell < Cell::Base
  ...
end
```

In your `routes.rb` file, mount the cell like a Rack app.

```ruby
match "/posts" => proc { |env|
  [ 200, {}, [ Cell::Base.render_cell_for(:post, :show) ]]
}
```

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

### Base Path

You can configure the cells path in case your cells don't reside in `app/cells`.

```ruby
config.generators do |g|
  g.base_cell_path "app/widgets"
end
```


## Capture Support

If you need a global `#content_for` use the [cells-capture](https://github.com/apotonick/cells-capture) gem.

Go for it, you'll love it!


## LICENSE

Copyright (c) 2007-2014, Nick Sutterer

Copyright (c) 2007-2008, Solide ICT by Peter Bex and Bob Leers

Released under the MIT License.
