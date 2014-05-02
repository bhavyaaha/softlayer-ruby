#
# Copyright (c) 2014 SoftLayer Technologies, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib'))

require 'rubygems'
require 'softlayer_api'
require 'rspec'

describe SoftLayer::Client do
  before do
    $SL_API_USERNAME = nil
    $SL_API_KEY = nil
    $SL_API_BASE_URL = nil
  end

  it 'accepts a user name from the global variable' do
    $SL_API_USERNAME = 'sample'
    client = SoftLayer::Client.new(:api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.username.should == 'sample'
  end

  it 'accepts a username in options' do
    $SL_API_USERNAME = 'sample'
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.username.should == 'fake_user'
  end

  it 'accepts an api key from the global variable' do
    $SL_API_KEY = 'sample'
    client = SoftLayer::Client.new(:username => 'fake_user', :endpoint_url => 'http://fakeurl.org/')
    client.api_key.should == 'sample'
  end

  it 'accepts an api key in options' do
    $SL_API_KEY = 'sample'
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.api_key.should == 'fake_key'
  end

  it 'raises an error if passed an empty user name' do
    expect do
      $SL_API_USERNAME = ''
      client = SoftLayer::Client.new(:api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    end.to raise_error

    expect do
      $SL_API_USERNAME = 'good_username'
      $SL_API_KEY = 'sample'
      client = SoftLayer::Client.new(:username => '', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    end.to raise_error
  end

  it 'fails if the user name is nil' do
    expect do
      $SL_API_USERNAME = nil
      client = SoftLayer::Client.new(:username => nil, :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    end.to raise_error
  end

  it 'fails if the api_key is empty' do
    expect do
      $SL_API_KEY = ''
      client = SoftLayer::Client.new(:username => 'fake_user', :endpoint_url => 'http://fakeurl.org/')
    end.to raise_error

    expect do
      client = SoftLayer::Client.new(:username => 'fake_user', :api_key => '', :endpoint_url => 'http://fakeurl.org/')
    end.to raise_error
  end

  it 'fails if the api_key is nil' do
    expect do
      $SL_API_KEY = nil
      client = SoftLayer::Client.new(:username => 'fake_user', :endpoint_url => 'http://fakeurl.org/', :api_key => nil)
    end.to raise_error
  end

  it 'gets the default endpoint even if none is provided' do
    $SL_API_BASE_URL = nil
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key')
    client.endpoint_url.should == SoftLayer::API_PUBLIC_ENDPOINT
  end

  it 'allows the default endpoint to be overridden by globals' do
    $SL_API_BASE_URL = 'http://someendpoint.softlayer.com/from/globals'
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key')
    client.endpoint_url.should == 'http://someendpoint.softlayer.com/from/globals'
  end

  it 'allows the default endpoint to be overriden by options' do
    $SL_API_BASE_URL = 'http://this/wont/be/used'
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.endpoint_url.should == 'http://fakeurl.org/'
  end

  it 'has a read/write user_agent property' do
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.should respond_to(:user_agent)
    client.should respond_to(:user_agent=)
  end

  it 'has a reasonable default user agent string' do
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.user_agent.should == "softlayer_api gem/#{SoftLayer::VERSION} (Ruby #{RUBY_PLATFORM}/#{RUBY_VERSION})"
  end

  it 'should allow the user agent to change' do
    client = SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    client.user_agent = "Some Random User Agent"
    client.user_agent.should == "Some Random User Agent"
  end

  describe "obtaining services" do
    let(:test_client) {
      SoftLayer::Client.new(:username => 'fake_user', :api_key => 'fake_key', :endpoint_url => 'http://fakeurl.org/')
    }

    it "should have a service_named method" do
      test_client.should respond_to(:service_named)
    end

    it "should reject empty or nil service names" do
      expect { test_client.service_named('') }.to raise_error
      expect { test_client.service_named(nil) }.to raise_error
    end

    it "should be able to construct a service" do
      test_service = test_client.service_named('Account')
      test_service.should_not be_nil
      test_service.service_name.should == "SoftLayer_Account"
      test_service.client.should be(test_client)
    end

    it "allows bracket dereferences as an alternate service syntax" do
      test_service = test_client['Account']
      test_service.should_not be_nil
      test_service.service_name.should == "SoftLayer_Account"
      test_service.client.should be(test_client)
    end

    it "returns the same service repeatedly when asked more than once" do
      first_account_service = test_client['Account']
      second_account_service = test_client.service_named('Account')

      first_account_service.should be(second_account_service)
    end
  end
end