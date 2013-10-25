Events = {

  publish: function(event){
    this.connection.send(JSON.stringify(event));
    return this;
  },

  subscriptions: [],

  // Events.subscribe(function(event){ ... });
  // Events.subscribe('session.signin', function(event){ ... });
  // Events.subscribe('session', function(event){ ... });
  // Events.subscribe('post.new', 'comment.new', function(event){ ... });
  // Events.subscribe(, function(event){ ... });
  subscribe: function(){
    var events = [].slice.apply(arguments);
    var callback = events.pop();
    this.subscriptions.push(callback);
  },

  unsubscribe: function(callback){
    var index = this.subscriptions.indexOf(callback)
    if (index !== -1) this.subscriptions.splice(index, 1);
    return this;
  }


};


Events.Connection = (function(){
  function Connection(callback){
    this.openCallbacks = [];
    this.host = location.origin.replace(/^http/, 'ws');
    this.open();
  }

  Connection.prototype.open = function(callback){
    this.stayConnected = true;
    createSocket(this, callback);
    return this;
  };

  Connection.prototype.close = function(){
    this.stayConnected = false;
    if (this.socket){
      this.socket.close();
      delete this.socket;
    }
    return this;
  };

  Connection.prototype.send = function(message){
    this.open(function(){
      this.socket.send(JSON.stringify(message));
    });
    return this;
  };

  Connection.prototype.onmessage = function(message){};

  function createSocket(connection, callback) {
    connection.openCallbacks.push(callback);

    var socket = connection.socket;
    if (socket){
      if (socket.readyState == 1) callOpenCallbacks(connection);
      if ([0,1].indexOf(socket.readyState) !== -1) return connection;
    }
    console.log('reconnecting...')
    socket = new WebSocket(connection.host);

    socket.onopen = function onopen() {
      console.log('connected');
      connection.socket = socket;
      callOpenCallbacks(connection);
    }

    socket.onclose = function(){
      console.log('connection closed');
      if (connection.stayConnected) setTimeout(function(){
        connection.open();
      }, 500)
    }

    socket.onmessage = function(message) {
      console.log('MESSAGE RECIEVED:', message);
      connection.onmessage(message);
    };

    return connection;
  };

  function callOpenCallbacks(connection) {
    while(connection.openCallbacks.length > 0){
      var callback = connection.openCallbacks.shift();
      if (typeof callback === 'function') callback.call(connection);
    };
  };

  return Connection;
})();


Events.connection = new Events.Connection;

Events.connection.onmessage = function(message) {
  var event = JSON.parse(message.data)
  Events.subscriptions.forEach(function(subscription){
    subscription(event)
  });
}


Events.subscribe('session.signin', function(){

});

Events.publish('session.signin', {
  email: 'jared@deadlyicon.com',
  password: 'password'
});

Events.publish('user.create', {user:
  {
    name: 'Jared Grippe',
    email: 'jared@deadlyicon.com',
    password: 'password'
  }
});
