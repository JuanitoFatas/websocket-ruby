# encoding: binary

require 'spec_helper'

RSpec.describe 'Outgoing common frame' do
  subject { WebSocket::Frame::Outgoing.new }

  its(:version) { is_expected.to be(13) }
  its(:error?) { is_expected.to be false }

  it 'raises error on invalid version' do
    subject = WebSocket::Frame::Incoming.new(version: 70)
    expect(subject.error?).to be true
    expect(subject.error).to be(:unknown_protocol_version)
  end
end
