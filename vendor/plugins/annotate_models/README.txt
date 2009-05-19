  _
 /_|      _/__/_   /|/|   _/_ / _
(  |/)/)()/(//(-  /   |()(/(-(_)
________________________________

Add a comment summarizing the current schema to the
bottom of each ActiveRecord model, Test File,
Exemplar, Fixture and Factory source file:

 # == Schema Info
 # Schema version: 20081001061831
 #
 # Table name: line_item
 #
 #  id                  :integer(11)    not null, primary key
 #  order_id            :integer(11)
 #  product_id          :integer(11)    not null
 #  quantity            :integer(11)    not null
 #  unit_price          :float

  class LineItem < ActiveRecord::Base
    belongs_to :product
   . . .

Note that this code will blow away the initial/final comment
block in your models if it looks like it was previously added
by annotate models, so you don't want to add additional text
to an automatically created comment block.

        * * Back up your model files before using... * *

== HOW TO USE:

To annotate all your models:

  rake db:annotate

To migrate & annotate:

  rake db:update


Options:

Annotate on the head of the file:

  rake db:annotate POSITION='top'

Annotate models in non-standard directories:

  rake db:annotate MODEL_DIR='vendor/plugins/example_engine/app/models'


== LICENSE:

Original code by:
   Dave Thomas
   Pragmatic Programmers, LLC

Refactored, improved by
   Alexander Semyonov (http://github.com/rotuka/annotate_models)
   Marcos Piccinini (http://github.com/nofxx/annotate_models)
   Stephen Anderson (http://github.com/bendycode/annotate_models)
   Lightning Dave Bolton (http://github.com/lightningdb/annotate_models)

Released under the same license as Ruby. No Support. No Warranty.
