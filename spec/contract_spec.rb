require 'spec_helper'
require './lib/contract'

describe "Contract" do

  class UsersRepo
    extend Contract
    methods :find_by_id
  end

  it "generates constructor with one param" do
    expect{ UsersRepo.implemented_by }.to raise_error ArgumentError
    expect{ UsersRepo.implemented_by "bla", "ble" }.to raise_error ArgumentError
  end

  it "generates instance methods" do
    repo_impl = spy("Repo Impl", :find_by_id => "bla")
    users_repo = UsersRepo.implemented_by(repo_impl)

    expect(users_repo).to respond_to :find_by_id
  end

  it "delegates on implementation" do
    repo_impl = double("Repo Impl")
    expect(repo_impl).to receive(:find_by_id)
    users_repo = UsersRepo.implemented_by(repo_impl)

    users_repo.find_by_id()
  end

  it "passes args on delegation" do
    the_id = "objectId"
    repo_impl = double("Repo Impl", :find_by_id => "bla")
    users_repo = UsersRepo.implemented_by(repo_impl)
    expect(repo_impl).to receive(:find_by_id).with(the_id)

    users_repo.find_by_id(the_id)
  end

  it "raises error if impl does not contain all repo methods" do
    class TaskRepo
      extend Contract
      methods :find_by_id, :find_by_another_thing
    end

    class TaskRepoImpl
      def find_by_id
      end
    end

    expect do
      TaskRepo.implemented_by(TaskRepoImpl.new)
    end.to raise_error(
      Contract::NotAllMethodsImplemented, "Not implemented [:find_by_another_thing]"
    )
  end

  it "does not provide a new method (use implemented_by instead)" do
    expect { UsersRepo.new("anything") }.to raise_error(NoMethodError)
  end

end
