# encoding: binary

require 'spec_helper'

RSpec.describe 'Incoming common frame' do
  subject { WebSocket::Frame::Incoming.new }

  its(:version) { is_expected.to be(13) }
  its(:decoded?) { is_expected.to be false }
  its(:error?) { is_expected.to be false }

  it 'allows adding data via <<' do
    expect(subject.data).to eql('')
    subject << 'test'
    expect(subject.data).to eql('test')
  end

  it 'raises error on invalid version' do
    subject = WebSocket::Frame::Incoming.new(version: 70)
    expect(subject.error?).to be true
    expect(subject.error).to be(:unknown_protocol_version)
  end
end
