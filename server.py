import http.server
import socketserver

# Define the port we want to listen on
PORT = 8080

class SimpleHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Send a 200 OK response
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        
        # The message that will be displayed in the browser or terminal
        message = f"Success! The Python server is running on port {PORT}.\n"
        self.wfile.write(message.encode("utf-8"))

# Set up the server
with socketserver.TCPServer(("", PORT), SimpleHandler) as httpd:
    print(f"Serving at port {PORT}...")
    # Keep the server running indefinitely
    httpd.serve_forever()
