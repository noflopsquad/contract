contract
============
[![License MIT](http://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

Provides a handy way to make explicit the contract between a port and its adapters.

## Usage

```ruby
require 'contract'

class UsersRepo
  extend Contract
  methods :find_by_email, :delete # these are the methods
                                  # that any adapter of this port
                                  # must implement
end

class MongoidUsersRepo
  include Mongoid::Document

  field :email, type: String

  def find_by_email email
    find_by(email: email)
  end

  def delete id
    find(id).destroy
  end
end

# this adapter is fine because it respects UsersRepo contract
users_repo = UsersRepo.implemented_by(MongoidUsersRepo)
=> true

class WrongUsersRepoImplementation
  def find_by_email email
    # anything
  end
end

# this adapter is wrong because it does not implement delete
users_repo = UsersRepo.implemented_by(WrongUsersRepoImplementation)
=> Contract::NotAllMethodsImplemented: Not implemented [:delete]

```
