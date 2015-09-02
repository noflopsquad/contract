contract
============
[![License MIT](http://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)

A simple module providing a way to define duck type contracts.

## Usage

```ruby
require 'contract'

class UsersRepo
  extend Contract
  methods :find_by_email, :delete
end

class MongoidUsersRepo

  include Mongoid::Document

  field :email, type: String

  def find_by_email email
    find_by(email: email)
  end

end

users_repo = UsersRepo.new(MongoidUsersRepo)

```
