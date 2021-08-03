({
	afterRender: function(cmp, helper){
		this.superAfterRender();

		setTimeout(function(){
			console.log('PAGE_NAME: ' + window.document.title);
			cmp.set("v.pageName",window.document.title);
		},0);
	}
})