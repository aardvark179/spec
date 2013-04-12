# -*- encoding: ascii-8bit -*-
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../shared/cover_and_include', __FILE__)
require File.expand_path('../shared/include', __FILE__)
require File.expand_path('../shared/cover', __FILE__)

describe "Range#member?" do
  it_behaves_like :range_cover_and_include, :member?

  ruby_version_is ""..."1.9" do
    it_behaves_like :range_cover, :member?
  end

  ruby_version_is "1.9" do
    it_behaves_like :range_include, :member?
  end
end