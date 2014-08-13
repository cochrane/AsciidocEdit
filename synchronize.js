++++
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>

<script>

function keep_place() {
    
    var position = localStorage.getItem("scroll_position");
    
    $("body").scrollTop(position)

}

$(document).ready(function(){

  $("#b1").click(function(){
	 
	keep_place()

  });

$(document).ready(function(){

    $(window).scroll(function(){

       var scroll_position = $("body").scrollTop();

       localStorage.setItem("scroll_position", scroll_position);
 
	      document.getElementById('report').innerHTML= scroll_position + " px"
    
    })

});

 
});

</script>

<span id="report" style="position:fixed; top:10px;right:75px">Position</span>

++++
