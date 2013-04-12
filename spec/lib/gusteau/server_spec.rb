require './spec/spec_helper.rb'

describe Gusteau::Server do
  let(:config) do
    {
      'host'     => 'demo.com',
      'port'     => 2222,
      'platform' => 'ubuntu'
    }
  end

  let(:server) { Gusteau::Server.new(config) }

  before do
    def server.log(msg, opts={})
      yield if block_given?
    end

    def server.log_error(msg, opts={})
    end
  end

  describe "Default user" do
    subject { server.user }

    context "User not specified in node config" do
      it { subject.must_equal 'root' }
    end

    context "User specified in node config" do
      let(:config) do
      {
        'host'     => 'demo.com',
        'port'     => 2222,
        'user'     => 'oneiric',
        'platform' => 'ubuntu',
      }
      end
      it { subject.must_equal 'oneiric' }
    end
  end

  describe "#run" do
    it "should raise if one of the commands fails" do
      server.stub(:send_command, false) do
        proc { server.run('failure') }.must_raise RuntimeError
      end
    end

    it "should return true if all command succeed" do
      server.stub(:send_command, true) do
        server.run('uname').must_equal true
      end
    end
  end

  describe "#prepared_cmd" do
    subject { server.send(:prepared_cmd, 'cd /etc/chef && touch test') }

    context "user is root" do
      it { subject.must_equal 'cd /etc/chef && touch test' }
    end

    context "user is not root" do
      before { server.stubs(:user).returns('vaskas') }
      it     { subject.must_equal "sudo -- sh -c 'cd /etc/chef && touch test'" }
    end
  end
end
