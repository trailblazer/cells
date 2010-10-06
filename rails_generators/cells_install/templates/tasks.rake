namespace "test" do
  Rake::TestTask.new(:cells) do |t|
    t.libs << "test"
    t.pattern = 'test/cells/**/*_test.rb'
  end
end
