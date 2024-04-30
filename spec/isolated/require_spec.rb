shared_examples "require 'dm-transactions'" do
  %w[ Repository Model Resource ].each do |name|
    it "should include the transaction api in DataMapper::#{name}" do
      expect((DataMapper.const_get(name) < DataMapper::Transaction.const_get(name))).to be(true)
    end
  end

  it "should include the transaction api into the adapter" do
    expect(@adapter.respond_to?(:push_transaction)).to be(true)
    expect(@adapter.respond_to?(:pop_transaction)).to be(true)
    expect(@adapter.respond_to?(:current_transaction)).to be(true)
  end
end
