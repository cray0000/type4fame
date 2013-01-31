if (process.env.NODE_ENV === 'production') {
  require('./src/bootstrap').listen(80);
} else {
  require('./src/bootstrap').listen(3000);
//  require('derby').run(__dirname + '/src/bootstrap', 3000);
}
