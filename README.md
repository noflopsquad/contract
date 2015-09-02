contract
============
[![License MIT](http://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

Provides a handy way to make explicit the contract between a port and its adapters.

## Usage

```ruby
require 'contract'

class UsersRepo
  extend Contract
  # These are the methods that any adapter of this port must implement.
  methods :find_by_email, :all
end

# For instance, this adapter is fine because it respects UsersRepo contract.
class InMemoryUsersRepo
  def initialize
    @users = {'email1' => { name: "Koko", email: "email1" }}
  end

  def find_by_email email
    @users[email]
  end

  def all
    @users.values
  end
end

users_repo = UsersRepo.implemented_by(InMemoryUsersRepo.new)
=> true

# Whereas this other adapter is wrong because it does not implement :all.
class WrongUsersRepoImplementation
  def find_by_email email
    # anything
  end
end

users_repo = UsersRepo.implemented_by(WrongUsersRepoImplementation.new)
=> Contract::NotAllMethodsImplemented: Not implemented [:all]

# In this case we use a Mongoid based repository adapter.
# Notice that it doesn't fail because :all is already provided by Mongoid::Document.
class MongoidUsersRepo
  include Mongoid::Document

  field :email, type: String

  def self.find_by_email email
    find_by(email: email)
  end
end

# We pass the class because this adapter uses class methods.
users_repo = UsersRepo.implemented_by(MongoidUsersRepo)
=> true
```