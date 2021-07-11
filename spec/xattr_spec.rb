RSpec.describe Xattr do
  subject(:xattr) { Xattr.new(path) }
  let(:path) { "spec/fixture/backup_excluded" }
  let(:exclude_value) { "bplist00_\x10\x11com.apple.backupd\b" }

  describe "list" do
    it "lists all xattrs" do
      expect(xattr.list).to eq(["com.apple.metadata:com_apple_backup_excludeItem"])
    end
  end

  describe "get" do
    it "gets a named xattr" do
      value = xattr.get("com.apple.metadata:com_apple_backup_excludeItem")
      expect(value).to eq(exclude_value)
    end
  end

  describe "set" do
    after do
      `xattr -d test #{path}`
    end

    it "sets a given xattr name to a given value" do
      expect {
        xattr.set("test", "test value")
        expect(`xattr -p test #{path}`.chomp).to eq("test value")
      }.to change { `xattr #{path}` }
    end
  end

  describe "remove" do
    before do
      `xattr -w to_remove "test value" #{path}`
    end

    it "removes a given xattr" do
      expect(xattr.get("to_remove")).to eq("test value")
      expect {
        xattr.remove("to_remove")
      }.to change { `xattr #{path}` }
    end
  end

end
