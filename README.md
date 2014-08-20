# Cells

*View Components for Rails.*


## Overview

Cells allow you to encapsulate parts of your page into a separate MVC component. They look and feel like controllers, can run arbitrary code in an action and render views.

While they improve your overall software architecture by abstracting logic into an encapsulated OOP instance, cells also maximise reuseability within or across projects.

Basically, cells can be rendered anywhere in your code. Most people use them in views to replace a helper/partial/filter mess, as a mailer renderer substitute or hook them to routes and completely bypass `ActionController`.


## View Models

Since version 3.9 cells comes with two "dialects": You can still use a cell like a controller. However, the new [view model](https://github.com/apotonick/cells#view-models-explained) "dialect" supercedes the traditional cell. It allows you to treat a cell more object-oriented while providing an alternative approach to helpers.

While the old dialect still works, we strongly recommend using a cell as a view model.


## Installation

Cells run with all Rails >= 3.0. For 2.3 support [see below](#rails-23-note).

```ruby
gem 'cells'
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

Creating a cell is nothing more than

```shell
rails generate cell cart show -e haml
```

```
create  app/cells/
create  app/cells/cart
create  app/cells/cart_cell.rb
create  app/cells/cart/show.html.haml
create  test/cells/cart_test.rb
```

That looks very familiar.

## Render the cell

Now, render your cart. Why not put it in `layouts/application.html.erb` for now?

```erb
<div id="header">
  <%= render_cell :cart, :show, :user => @current_user %>
```

Feels like rendering a controller action. For good encapsulation we pass the current `user` from outside into the cell - a dependency injection.

## Code

Time to improve our cell code. Let's start with `app/cells/cart_cell.rb`:

```ruby
class CartCell < Cell::Rails
  def show(args)
    user    = args[:user]
    @items  = user.items_in_cart

    render  # renders show.html.haml
  end
end
```

Is that a controller? Hell, yeah. We even got a `#render` method as we know it from the good ol' `ActionController`.


## Views

Since a plain call to `#render` will start rendering `app/cells/cart/show.html.haml` we should put some meaningful markup there.

```haml
#cart
  You have #{@items.size} items in your shopping cart.
```

### ERB? Haml? Builder?

Yes, Cells support all template types that are supported by Rails itself. Remember- it's a controller!

### Helpers

Yes, Cells have helpers just like controllers. If you need some specific helper, do

```ruby
class CartCell < Cell::Rails
  helper MyExtraHelper
```

and it will be around in your cart views.

### Partials?

In Cells, everything template file is a _view_. You're still free to render views within views (aka "partial") but we just call it "_view_". There's no need to have two different types of views. Whenever you're tempted to render a partial, use the cells term `view`.

```haml
/ app/cells/comment/show.haml

%h1 All comments

%p
  = render :view => 'items'
```

## File Structure

TODO: rails g concept Song => show.haml,

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

### Builders

Let `render_cell` take care of creating the right cell. Just configure your super-cell properly.

```ruby
class LoginCell < Cell::Rails
  build do
    UnauthorizedUserCell unless logged_in?
  end
```

A call to

```ruby
render_cell(:login, :box)
```

will render the configured `UnauthorizedUserCell` instead of the original `LoginCell` if the login test fails.


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

# View Models, Explained

View models supersede the old controller-like cells. View models feel more natural as they wrap domain models and then add decorating methods for the view.

They are also significantly faster since they don't need to copy helpers and instance variables to the view: The view model itself is the view context. That means, methods called in the view are invoked on your cell instance.


```ruby
# app/cells/song_cell.rb
class SongCell < Cell::ViewModel
end
```

### Creation

Instantiating the view model should happen in controllers and views, but you can virtually use them anywhere.

A default workflow for creating and rendering a view model looks as the following.

```ruby
song = Song.find(1)

@cell = cell(:song, song).call
```

The `#cell` helper gives you an instance of the `SongCell` cell and wraps the `song` object.

### Rendering

The `call` invocation instructs the cell to render. Internally, that runs `render_state(:show)` per default.

You can basically invoke any method you want on that cell. Nevertheless, a view model should only expose the `#show` method per convention, which is reflected by the `#call` alias.

It is important to understand this convention: Internally, you may render multiple views, combine them, use instance methods to render and format values, and so on. Externally, exposing only one "public", rendering method defines a strong interface for your view model.

```ruby
class SongCell < Cell::ViewModel
  def show
    render
  end
end
```

The `render` call will render the cell's `show` view.

### Views

```haml
- # app/cells/song/show.haml

%h1 #{title}

%p Written at #{composed_at}

= author_box
```

We strongly recommend to only invoke _methods_ in views and _not_ to use instance variables and locals. In a view model template (or, view), methods are called on the view model instance itself, meaning you can easily expose "helpers" by defining instance methods.

### Helpers

```ruby
class SongCell < Cell::ViewModel
  include TimeagoHelper

  def show
    render
  end

  def composed_at
    timeago(model.created_at)
  end
end
```

In other words, using `composed_at` in the view will call `SongCell#composed_at`. Note that you have to `include` additional helpers into the class.

The `#model` methods lets you access the wrapped `Song` instance we passed into the cell when creating it.

### Properties

Often, it is helpful to automatically expose some reader methods to the model. You can do that with `::property`.

```ruby
class SongCell < Cell::ViewModel
  include TimeagoHelper

  property :title

  # ...
end
```

You can now safely use `#title` in the view (and, in the cell class), it is delegated to `model.title`.

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

## Using Rails Gems Like simple_form Outside Of Rails

Cells can be used outside of Rails. A new module brought in 3.8.5 provides the Rails view "API" making it possible to use gems like  the popular [simple_form](https://github.com/plataformatec/simple_form) outside Rails!

All you need to do is providing the cell with some helpers, usually it's the polymorphic routing paths required by the gems.

```ruby
module RoutingHelpers
  def musician_path(model)
    "/musicians/#{model.id}"
  end
end
```

Then, use the Cell::Rails::HelperAPI module and it should work fine (depending on the quality of the gem you're desiring to use).

```ruby
require 'cell/base'
require "cell/rails/helper_api"
require "simple_form"

class BassistCell < Cell::Base
  include Cell::Rails::HelperAPI

  self._helpers = RoutingHelpers

  def show
    @musician = Musician.find(:first)
  end
end
```

Your views can now use the gem's helpers.

```erb
<%= simple_form_for @musician do |f| %>
  <%= f.input :name %>
  <%= f.button :submit %>
<% end %>
```

Note that this currently "only" works with Rails 3.2-4.0.

## Cells is Rails::Engine aware!

Now `Rails::Engine`s can contribute to Cells view paths. By default, any 'app/cells' found inside any Engine is automatically included into Cells view paths. If you need to, you can customize the view paths changing/appending to the `'app/cell_views'` path configuration. See the `Cell::EngineIntegration` for more details.


## Generator Options

By default, generated cells inherit from `Cell::Rails`. If you want to change this, specify your new class name in `config/application.rb`:

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

## Rails 2.3 note

### Installation

```shell
gem install cells -v 3.3.9
```

In order to copy the cells rake tasks to your app, run

```shell
script/generate cells_install
```

## Capture Support

If you need a global `#content_for` use the [cells-capture](https://github.com/apotonick/cells-capture) gem.

## More features

Cells can do more.

* __No Limits__. Have as many cells in your page as you need - no limitation to your `render_cell` calls.
* __Cell Nesting__. Have complex cell hierarchies as you can call `render_cell` within cells, too.

Go for it, you'll love it!


## LICENSE

Copyright (c) 2007-2014, Nick Sutterer

Copyright (c) 2007-2008, Solide ICT by Peter Bex and Bob Leers

Released under the MIT License.
