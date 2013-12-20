# Cells

**View Components for Rails.**

## Overview

Say you're writing a Rails online shop - the shopping cart is reappearing again and again in every view. You're thinking about a clean solution for that part. A mixture of controller code, before-filters, partials and helpers?

No. That sucks. Take Cells.

Cells are View Components for Rails. They look and feel like controllers. They don't have no `DoubleRenderError`. They can be rendered everywhere in your controllers or views. They are cacheable, testable, fast and wonderful. They bring back OOP to your view and improve your software design.

And the best: You can have as many cells in your page as you need!


Note: Since version 3.9 cells comes with two "dialects": You can still use a cell like a controller. However, the new [view model](https://github.com/apotonick/cells#view-models) "dialect" allows you to treat a cell more object-oriented while providing an alternative approach to helpers.

## Installation

It's a gem!

Rails >= 3.0:

```shell
gem install cells
```

Rails 2.3:

```shell
gem install cells -v 3.3.9
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

Yeah, we do support rendering partials in views. Nevertheless, we discourage _partials_ at all.

The distinction between partials and views is making things more complex, so why should we have two kinds of view types? Use ordinary views instead, they're fine.

```haml
%p
  = render :view => 'items'
```

### Rendering Global Partials

Sometimes you need to render a global partial from `app/views` within a cell. For instance, the `gmaps4rails` helper depends on a global partial. While this breaks encapsulation it's still possible in cells - just add the global view path.

```ruby
class MapCell < Cell::Rails
  append_view_path "app/views"
```


## View Inheritance

This is where OOP comes back to your view.

* __Inherit code__ into your cells by deriving more abstract cells.
* __Inherit views__ from parent cells.

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

Cells do strict view caching. No cluttered fragment caching. Add

```ruby
class CartCell < Cell::Rails
  cache :show, :expires_in => 10.minutes
```

and your cart will be re-rendered after 10 minutes.

You can expand the state's cache key - why not use a versioner block to do just this?

```ruby
class CartCell < Cell::Rails
  cache :show do |cell, options|
    options[:items].md5
  end
```

The block's return value is appended to the state key: `"cells/cart/show/0ecb1360644ce665a4ef"`.

Check the [API to learn more](http://rdoc.info/gems/cells/Cell/Caching/ClassMethods#cache-instance_method).

*Reminder*: If you want to test it in `development`, you need to put `config.action_controller.perform_caching = true` in `development.rb` to see the effect

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

# View Models

Cells 3.9 brings a new dialect to cells: view models (still experimental!).

Think of a view model as a cell decorating a model or a collection. In this mode, helpers are nothing more than instance methods of your cell class, making helpers predictable and scoped.

```ruby
class SongCell < Cell::Rails
  include Cell::Rails::ViewModel

  property :title


  def show
    render
  end

  def self_link
    link_to(title, song_url(model))
  end
end
```

### Creation

Creating the view model should usually happen in the controller.

```ruby
class DashboardController < ApplicationController

  def index
    @song = Song.find(1)

    @cell = cell(:song, @song)
  end
```

You can now grab an instance of your cell using the `#cell` method. The 2nd argument will be the cell's decorated model.

Have a look at how to use this cell in your controller view.

```haml
= @cell.show # renders its show view.
```

You no longer use the `#render_cell` helper but call any method on that cell. Usually, this is a state (or "action") like `show`.

### Helpers

Note that this doesn't have to be a rendering state, it could be any instance method (aka "helper").

```haml
= @cell.self_link
```

As all helpers are now instance methods, the `#self_link` example can use any existing helper (as the URL helpers) on the instance level.

Attributes declared using ``::property` are automatically delegated to the decorated model.

```ruby
@cell.title # delegated to @song.title
```

### Views

This greatly reduces wiring in the cell view (which is still in `app/cells/song/show.haml`).

```haml
%h1
  = title

Bookmark! #{self_link}
```

Making the cell instance itself the view context should be an interesting alternative for many views.


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

Copyright (c) 2007-2013, Nick Sutterer

Copyright (c) 2007-2008, Solide ICT by Peter Bex and Bob Leers

Released under the MIT License.
