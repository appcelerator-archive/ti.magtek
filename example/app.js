// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
  backgroundColor:'white'
});
window.open();

// TODO: write your module tests here
var magtek = require('ti.magtek');
Ti.API.info("module is => "+magtek);

magtek.addEventListener('connected', function(e) {
	Ti.API.log('Device connected: ' + e.name);
});
magtek.addEventListener('disconnected', function(e) {
	Ti.API.log('Device disconnected: ' + e.name);
});
magtek.addEventListener('swipe', function(e) {
	Ti.API.log('Swiped card: '+e.cardnumber);
});