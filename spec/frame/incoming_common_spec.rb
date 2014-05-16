# encoding: binary
require 'spec_helper'

describe 'Incoming common frame' do
  subject { WebSocket::Frame::Incoming.new }

  its(:version) { should eql(13) }
  its(:decoded?) { should be_false }
  # Not implemented yet
  # its(:error?) { should be_false }

  it 'should allow adding data via <<' do
    expect(subject.data).to eql('')
    subject << 'test'
    expect(subject.data).to eql('test')
  end

  it 'should raise error on invalid version' do
    subject = WebSocket::Frame::Incoming.new(:version => 70)
    expect(subject.error?).to be_true
    expect(subject.error).to eql(:unknown_protocol_version)
  end
end
