namespace "test" do
  TestTaskWithoutDescription.new(:cells => "test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/cells/**/*_test.rb'
  end
end
