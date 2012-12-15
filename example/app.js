var window = Ti.UI.createWindow({
	backgroundColor:'#FFF'
});
window.open();

var scrollView = Ti.UI.createScrollView({
	layout:"vertical",
	contentHeight:Ti.UI.SIZE||'auto'
});
var statusBar = Ti.UI.createView({
	backgroundColor:'#F00',
	top:20,
	width:'90%',
	height:40
});
var statusLabel = Ti.UI.createLabel({
	text:'Status:',
	color:'#000',
	height:30,
	left:10
});
var responseLabel = Ti.UI.createLabel({
	text:'Response:',
	top:10,
	width:'90%',
	height:Ti.UI.SIZE||'auto'
});

statusBar.add(statusLabel);
scrollView.add(statusBar);
scrollView.add(responseLabel);
window.add(scrollView);

var Magtek = require('ti.magtek');

Magtek.addEventListener('connected', function(e) {
   statusLabel.text = 'Status: Connected';
   statusBar.backgroundColor = '#0F0';
   Ti.API.info('Connected: '+JSON.stringify(e));
});
Magtek.addEventListener('disconnected', function(e) {
	statusLabel.text = 'Status: Disconnected';
	statusBar.backgroundColor = '#F00';
   Ti.API.info('Disconnected: '+JSON.stringify(e));
});
Magtek.addEventListener('swipe', function(e) {
	responseLabel.text = 'Response: '+JSON.stringify(e);
	Ti.API.info('Swipe: '+JSON.stringify(e));
});

Magtek.addEventListener('swipeError',function(e){
	responseLabel.text = "Response: ERROR";
	Ti.API.info('Swipe Error: Please re-swipe the card');
});

// Set the protocol for your device. For example, 'com.yourcompany.magtek'
Magtek.registerDevice({
	protocol: '<YOUR PROTOCOL HERE>',
	deviceType: Magtek.DEVICE_TYPE_IDYNAMO
});
