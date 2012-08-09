def client_handshake_75(args = {})
  <<-EOF
GET #{args[:path] || "/demo"} HTTP/1.1\r
Upgrade: WebSocket\r
Connection: Upgrade\r
Host: #{args[:host] || "example.com"}#{":#{args[:port]}" if args[:port]}\r
Origin: http://example.com\r
\r
  EOF
end

def server_handshake_75(args = {})
  <<-EOF
HTTP/1.1 101 Web Socket Protocol Handshake\r
Upgrade: WebSocket\r
Connection: Upgrade\r
WebSocket-Origin: http://example.com\r
WebSocket-Location: ws#{args[:secure] ? "s" : ""}://#{args[:host] || "example.com"}#{":#{args[:port]}" if args[:port]}#{args[:path] || "/demo"}\r
\r
  EOF
end

def client_handshake_76(args = {})
  request = <<-EOF
GET #{args[:path] || "/demo"} HTTP/1.1\r
Host: #{args[:host] || "example.com"}#{":#{args[:port]}" if args[:port]}\r
Connection: Upgrade\r
Sec-WebSocket-Key2: 12998 5 Y3 1  .P00\r
Upgrade: WebSocket\r
Sec-WebSocket-Key1: 4 @1  46546xW%0l 1 5\r
Origin: http://example.com\r
\r
^n:ds[4U
  EOF
  request.rstrip
end

def server_handshake_76(args = {})
  request = <<-EOF
HTTP/1.1 101 WebSocket Protocol Handshake\r
Upgrade: WebSocket\r
Connection: Upgrade\r
Sec-WebSocket-Origin: http://example.com\r
Sec-WebSocket-Location: ws#{args[:secure] ? "s" : ""}://#{args[:host] || "example.com"}#{":#{args[:port]}" if args[:port]}#{args[:path] || "/demo"}\r
\r
8jKS'y:G*Co,Wxa-
  EOF
  request.rstrip
end

def client_handshake_04(args = {})
  <<-EOF
GET #{args[:path] || "/demo"} HTTP/1.1\r
Host: #{args[:host] || "example.com"}#{":#{args[:port]}" if args[:port]}\r
Upgrade: websocket\r
Connection: Upgrade\r
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r
Sec-WebSocket-Origin: http://example.com\r
Sec-WebSocket-Version: 4\r
\r
  EOF
end

def server_handshake_04(args = {})
  <<-EOF
HTTP/1.1 101 Switching Protocols\r
Upgrade: websocket\r
Connection: Upgrade\r
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=\r
\r
  EOF
end
