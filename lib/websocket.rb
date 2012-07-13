# WebSocket protocol implementation in Ruby
# This module does not provide a WebSocket server or client, but is made for using
# in http servers or clients to provide WebSocket support.
# @author Bernard "Imanel" Potocki
# @see http://github.com/imanel/websocket-ruby main repository
module WebSocket
  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Frame,     "#{ROOT}/websocket/frame"
  autoload :Handshake, "#{ROOT}/websocket/handshake"

end
