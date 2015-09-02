contract
============
[![License MIT](http://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

Provides a handy way to make explicit the contract between a port and its adapters.

## Usage

```ruby
require 'contract'

class Library
  extend Contract
  # These are the methods that any adapter of this port must implement.
  methods :find_by_isbn, :all
end

# For instance, this adapter is fine because it respects
# the Library repository contract.
class InMemoryLibrary
  def initialize
    @books = {'isbn1' => { name: "The Martian", isbn: "isbn1" }}
  end

  def find_by_isbn isbn
    @books[isbn]
  end

  def all
    @books.values
  end
end

library = Library.implemented_by(InMemoryLibrary.new)
=> true

# Whereas this other adapter is wrong because it does not implement :all.
class WrongLibraryImplementation
  def find_by_isbn isbn
    # anything
  end
end

library = Library.implemented_by(WrongLibraryImplementation.new)
=> Contract::NotAllMethodsImplemented: Not implemented [:all]

# In this case we use a Mongoid based repository adapter.
# Notice that it doesn't fail because :all is already provided by Mongoid::Document.
class MongoidLibrary
  include Mongoid::Document

  field :isbn, type: String

  def self.find_by_isbn isbn
    find_by(isbn: isbn)
  end
end

# We pass the class because this adapter uses class methods.
library = Library.implemented_by(MongoidLibrary)
=> true
```