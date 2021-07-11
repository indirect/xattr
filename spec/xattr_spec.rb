# frozen_string_literal: true

RSpec.describe Xattr do
  subject(:xattr) { described_class.new(path) }

  let(:path) { "spec/fixture/backup_excluded" }
  let(:exclude_key) { "com.apple.metadata:com_apple_backup_excludeItem" }
  let(:exclude_value) { "bplist00_\x10\x11com.apple.backupd\b" }

  describe "list" do
    it "lists all xattrs" do
      expect(xattr.list).to eq([exclude_key])
    end
  end

  describe "get" do
    it "gets a named xattr" do
      expect(xattr.get(exclude_key)).to eq(exclude_value)
    end
  end

  describe "[]" do
    it "gets a named xattr" do
      expect(xattr[exclude_key]).to eq(exclude_value)
    end
  end

  describe "set" do
    after { `/usr/bin/xattr -d test #{path}` }

    it "sets a given xattr name to a given value" do
      xattr.set("test", "test value")
      expect(`/usr/bin/xattr -p test #{path}`.chomp).to eq("test value")
    end
  end

  describe "[]=" do
    after { `/usr/bin/xattr -d test #{path}` }

    it "sets a given xattr name to a given value" do
      xattr["test"] = "test value"
      expect(`/usr/bin/xattr -p test #{path}`.chomp).to eq("test value")
    end
  end

  describe "remove" do
    before do
      # create an xattr using apple's tooling
      `/usr/bin/xattr -w to_remove "test value" #{path}`
    end

    it "removes a given xattr" do
      expect do
        xattr.remove("to_remove")
      end.to change { `/usr/bin/xattr #{path}` }
    end
  end
end
