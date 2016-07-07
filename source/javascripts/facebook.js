$(document).ready(
	function() {
		// facebookシェアボタン初期化
		facebookShare();
		facebookShare2();
	}
);

// facebookシェアボタン初期化
function facebookShare() {
	var url = encodeURIComponent(location.href);
	document.getElementById("fb-share-button").innerHTML = '<iframe src="//www.facebook.com/v2.0/plugins/like.php?href=' + url + '&width&amp;layout=button&amp;action=like&amp;show_faces=false&amp;share=true&amp;height=90&amp;appId=1679223382318515" scrolling="no" frameborder="0" style="border:none; overflow:hidden; height:90px;" allowTransparency="true"></iframe>';
}

function facebookShare2() {
	var url = encodeURIComponent(location.href);
	document.getElementById("fb-share-button2").innerHTML = '<iframe src="//www.facebook.com/v2.0/plugins/like.php?href=' + url + '&width&amp;layout=button&amp;action=like&amp;show_faces=false&amp;share=true&amp;height=90&amp;appId=1679223382318515" scrolling="no" frameborder="0" style="border:none; overflow:hidden; height:90px;" allowTransparency="true"></iframe>';
}
