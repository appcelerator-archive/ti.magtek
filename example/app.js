// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
  backgroundColor:'white'
});

var logView = Titanium.UI.createTextField({
    color:'#336699',
    value:'Log View',
    height:200,
    top:10,
    borderStyle:Titanium.UI.INPUT_BORDERSTYLE_ROUNDED
});

window.add(logView);

window.open();

var buffer = '';
var cnt = 0;
var eventFireNum = 1;

// TODO: write your module tests here
var magtek = require('ti.magtek');
//alert("module is => "+magtek);
 magtek.registerDevice('com.appcelerator.magtek');

magtek.addEventListener('connected', function(e) {
    logView.value += '\n\r Connected: ' + e.name + '\n\r';
   // alert("Connected");
});
magtek.addEventListener('disconnected', function(e) {
	logView.value += '\r\n Disconnected: ' + e.name;
});
magtek.addEventListener('swipe', function(e) {
	//alert('SWIPE');
	var str = 'Name: ' + e.name + " Exp: " + e.expiration;
	alert(str);
});

magtek.addEventListener('swipeError',function(e){
	alert(e.message);
});

magtek.addEventListener('streamended', function(e) {
	alert('STREAM ENDED');
	
});