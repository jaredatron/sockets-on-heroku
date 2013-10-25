browser sends an http get request for any html usl to the web server
the web server responds with a blank shim page
the page loads
the page makes a web socket connection to the web server
the page sends a publish request for the following resources ['current_user', 'current_user.messages.count', 'posts']
the binds registers these subscriptions to the web socket and then sends events back to only that socket with the full data of those resources



