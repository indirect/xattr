# frozen_string_literal: true

RSpec.describe Xattr do
  it "has a version number" do
    expect(Xattr::VERSION).not_to be nil
  end

  describe "list" do
    it "lists all xattrs" do
      expect(Xattr.new(".bundle/ruby").list).to eq("abc")
    end
  end

end
